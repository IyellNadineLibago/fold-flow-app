import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/laundry_order.dart';
import '../models/reservation.dart';
import 'laundry_repository.dart';

/// Customer side of FoldFlow, backed by Cloud Firestore.
///
/// There is no login: the app signs in anonymously so Firestore can tell which
/// reservations belong to this phone. What the app may do is decided by
/// `firestore.rules` (in the web project):
///
///  * create a reservation that belongs to this phone and read it back
///    (`reservations/{REQ-xxxxxx}`),
///  * read one tracking card at a time by Order ID (`tracking/{ORD-1001}`).
///    A tracking card carries the status, weight and total, but only a short
///    name ("Maria S.") and a masked phone number.
///
/// Both are live: when staff change a status on the web dashboard the card
/// changes, this repository notifies its listeners, and the tracking screen
/// rebuilds with the new status.
class FirebaseLaundryRepository extends LaundryRepository {
  FirebaseLaundryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance {
    _ready = _signInAndListen();
    // Failures are reported to whoever awaits _ready (a screen action); this
    // just keeps an unawaited failure from becoming an unhandled error.
    _ready.catchError((Object error) {
      debugPrint('FoldFlow sign-in failed: $error');
    });
  }

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  late final Future<void> _ready;

  final List<ReservationRequest> _reservations = [];
  final Map<String, LaundryOrder> _tracked = {};
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
      _orderSubscriptions = {};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _reservationSub;

  static final RegExp _orderIdPattern = RegExp(r'^ORD-\d+$');

  @override
  bool get isDemoDataOnly => false;

  @override
  List<ReservationRequest> get reservations =>
      List<ReservationRequest>.unmodifiable(_reservations);

  @override
  List<LaundryOrder> get orders =>
      List<LaundryOrder>.unmodifiable(_tracked.values);

  static String _normalize(String value) => value.trim().toUpperCase();

  // ---------------------------------------------------------------------------
  // Sign-in and live reservation list
  // ---------------------------------------------------------------------------

  Future<void> _signInAndListen() async {
    User? user = _auth.currentUser;
    user ??= (await _auth.signInAnonymously()).user;
    if (user == null) {
      throw StateError('Could not sign in to FoldFlow.');
    }

    _reservationSub = _db
        .collection('reservations')
        .where('customerUid', isEqualTo: user.uid)
        .snapshots()
        .listen(
      (snapshot) {
        final items = snapshot.docs
            .map((doc) => _reservationFromDoc(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => b.dropOffDate.compareTo(a.dropOffDate));
        _reservations
          ..clear()
          ..addAll(items);
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('FoldFlow reservation listener failed: $error');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Reads
  // ---------------------------------------------------------------------------

  @override
  LaundryOrder? orderById(String orderId) => _tracked[_normalize(orderId)];

  @override
  ReservationRequest? reservationByReference(String reference) {
    final wanted = _normalize(reference);
    for (final request in _reservations) {
      if (request.reference.toUpperCase() == wanted) return request;
    }
    return null;
  }

  @override
  Future<LaundryOrder?> findOrder(String orderId) async {
    final wanted = _normalize(orderId);
    if (!_orderIdPattern.hasMatch(wanted)) return null;

    await _ready;

    final snapshot = await _db.collection('tracking').doc(wanted).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;

    _tracked[wanted] = _orderFromTracking(data);
    _watchOrder(wanted);
    notifyListeners();
    return _tracked[wanted];
  }

  /// Keeps one looked-up order live, so its status follows the shop's updates.
  void _watchOrder(String orderId) {
    if (_orderSubscriptions.containsKey(orderId)) return;

    _orderSubscriptions[orderId] =
        _db.collection('tracking').doc(orderId).snapshots().listen(
      (snapshot) {
        final data = snapshot.data();
        if (!snapshot.exists || data == null) return;
        _tracked[orderId] = _orderFromTracking(data);
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('FoldFlow order listener failed ($orderId): $error');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Customer action
  // ---------------------------------------------------------------------------

  @override
  Future<ReservationRequest> submitReservation({
    required String customerName,
    required String contactNumber,
    required DateTime dropOffDate,
    required String dropOffTime,
  }) async {
    await _ready;

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Not signed in. Please restart the app.');
    }

    final reference = _newReference();
    final name = customerName.trim();
    final phone = contactNumber.trim();
    final dateText = _dateText(dropOffDate);

    try {
      await _db.collection('reservations').doc(reference).set({
        'reference': reference,
        'customerUid': uid,
        'customerName': name,
        'contactNumber': phone,
        'dropOffDate': dateText,
        'dropOffTime': dropOffTime,
        'status': 'pending',
        'orderId': null,
        'source': 'app',
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw Exception(
        'The shop could not be reached. Check your internet connection '
        'and try again.',
      );
    }

    final request = ReservationRequest(
      reference: reference,
      customerName: name,
      contactNumber: phone,
      dropOffDate: DateTime(dropOffDate.year, dropOffDate.month, dropOffDate.day),
      dropOffTime: dropOffTime,
    );
    if (!_reservations.any((item) => item.reference == reference)) {
      _reservations.insert(0, request);
    }
    notifyListeners();
    return request;
  }

  // ---------------------------------------------------------------------------
  // Mapping
  // ---------------------------------------------------------------------------

  static String _newReference() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final code = List.generate(
      6,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
    return 'REQ-$code';
  }

  static String _dateText(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime? _dateOf(Object? value) =>
      value is Timestamp ? value.toDate() : null;

  static LaundryStatus _statusFromDb(String value) {
    switch (value) {
      case 'washing':
        return LaundryStatus.washing;
      case 'drying':
        return LaundryStatus.drying;
      case 'ready_for_pickup':
        return LaundryStatus.readyForPickup;
      case 'claimed':
        return LaundryStatus.claimed;
      default:
        return LaundryStatus.received;
    }
  }

  static ReservationStatus _reservationStatusFromDb(String value) {
    switch (value) {
      case 'confirmed':
      case 'checked_in':
        return ReservationStatus.confirmed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }

  static ReservationRequest _reservationFromDoc(
    String id,
    Map<String, dynamic> data,
  ) {
    return ReservationRequest(
      reference: (data['reference'] as String?) ?? id,
      customerName: (data['customerName'] as String?) ?? '',
      contactNumber: (data['contactNumber'] as String?) ?? '',
      dropOffDate:
          DateTime.tryParse((data['dropOffDate'] as String?) ?? '') ??
              DateTime.now(),
      dropOffTime: (data['dropOffTime'] as String?) ?? '',
      status: _reservationStatusFromDb((data['status'] as String?) ?? ''),
      orderId: data['orderId'] as String?,
    );
  }

  static LaundryOrder _orderFromTracking(Map<String, dynamic> data) {
    final paid = data['paymentStatus'] == 'paid';
    final amount =
        ((data['paidAmount'] ?? data['totalAmount'] ?? 0) as num).toDouble();

    return LaundryOrder(
      orderId: (data['orderId'] as String?) ?? '',
      customerName: (data['customerName'] as String?) ?? '',
      contactNumber: (data['contactNumber'] as String?) ?? '',
      weightKg: ((data['weightKg'] ?? 0) as num).toDouble(),
      status: _statusFromDb((data['status'] as String?) ?? 'received'),
      receivedAt: _dateOf(data['receivedAt']) ?? DateTime.now(),
      reservationReference: data['reservationReference'] as String?,
      payment: paid
          ? Payment(
              amount: amount,
              method: (data['paymentMethod'] as String?) ?? '',
              recordedAt: _dateOf(data['updatedAt']) ?? DateTime.now(),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _reservationSub?.cancel();
    for (final subscription in _orderSubscriptions.values) {
      subscription.cancel();
    }
    _orderSubscriptions.clear();
    super.dispose();
  }
}
