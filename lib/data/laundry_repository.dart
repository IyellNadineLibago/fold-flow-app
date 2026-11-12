import 'package:flutter/foundation.dart';

import '../models/laundry_order.dart';
import '../models/reservation.dart';
import '../models/transaction_record.dart';

/// The boundary between the FoldFlow screens and the data source.
///
/// Screens only talk to this interface, so the data source (Firebase in the
/// real app, memory in demo mode and tests) can change without touching the
/// UI. The customer app has no staff actions: staff work on the web dashboard.
///
/// The repository extends [ChangeNotifier] so customer tracking screens can
/// rebuild automatically whenever staff update an order.
abstract class LaundryRepository extends ChangeNotifier {
  /// True when data stays in this session's memory only (demo mode).
  /// Screens use it to word their banners correctly; the Firebase-backed
  /// repository overrides it to false.
  bool get isDemoDataOnly => true;

  /// The reservation requests made from this phone.
  List<ReservationRequest> get reservations;

  /// Orders this phone has looked up with "Track My Laundry".
  List<LaundryOrder> get orders;

  /// Looks an order up by its Order ID (e.g. ORD-1043). Returns null when no
  /// such order exists.
  Future<LaundryOrder?> findOrder(String orderId);

  /// Synchronous lookup used by screens that are already open.
  LaundryOrder? orderById(String orderId);

  ReservationRequest? reservationByReference(String reference);

  /// Creates a booking *request*. It is not a confirmed reservation and it
  /// does not create an Order ID. Staff confirm it on the web dashboard.
  Future<ReservationRequest> submitReservation({
    required String customerName,
    required String contactNumber,
    required DateTime dropOffDate,
    required String dropOffTime,
  });
}

/// The sample Order ID shown on the home screen and used for tracking demos.
const String kDemoOrderId = 'ORD-1042';

/// Local demo mode: everything is kept in memory for the current app session.
///
/// Used when Firebase is not configured yet, and by the tests. The staff-side
/// helpers below (receiveLaundry, updateOrderStatus, ...) exist only to
/// simulate the web dashboard locally; the real staff tools live in the web app.
///
/// Nothing is sent to a server and nothing survives a restart. The seeded
/// records are clearly marked with `isDemo` so they can never be mistaken for
/// a real customer order.
class DemoLaundryRepository extends LaundryRepository {
  DemoLaundryRepository() {
    final now = DateTime.now();
    _reservations.add(
      ReservationRequest(
        reference: 'REQ-DEMO-001',
        customerName: 'Sample Customer',
        contactNumber: '+1 555 010 1042',
        dropOffDate: DateTime(now.year, now.month, now.day + 1),
        dropOffTime: '9:00 AM',
        isDemo: true,
      ),
    );
    _orders.add(
      LaundryOrder(
        orderId: kDemoOrderId,
        customerName: 'Sample Customer',
        contactNumber: '+1 555 010 1042',
        weightKg: 2.4,
        status: LaundryStatus.readyForPickup,
        receivedAt: now.subtract(const Duration(days: 1)),
        isDemo: true,
      ),
    );
    _transactions.add(
      TransactionRecord(
        id: 'TX-DEMO-001',
        orderId: kDemoOrderId,
        type: TransactionType.orderReceived,
        message: 'Sample order received at the counter (demo data)',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    );
  }

  final List<ReservationRequest> _reservations = [];
  final List<LaundryOrder> _orders = [];
  final List<TransactionRecord> _transactions = [];

  int _orderSequence = 1042;
  int _referenceSequence = 0;
  int _transactionSequence = 0;

  @override
  List<ReservationRequest> get reservations =>
      List<ReservationRequest>.unmodifiable(_reservations);

  @override
  List<LaundryOrder> get orders => List<LaundryOrder>.unmodifiable(_orders);

  List<TransactionRecord> get transactions =>
      List<TransactionRecord>.unmodifiable(_transactions);

  static String _normalize(String value) => value.trim().toUpperCase();

  String previewOrderId() => 'ORD-${_orderSequence + 1}';

  @override
  LaundryOrder? orderById(String orderId) {
    final wanted = _normalize(orderId);
    for (final order in _orders) {
      if (order.orderId == wanted) return order;
    }
    return null;
  }

  @override
  ReservationRequest? reservationByReference(String reference) {
    final wanted = reference.trim().toUpperCase();
    for (final request in _reservations) {
      if (request.reference.toUpperCase() == wanted) return request;
    }
    return null;
  }

  @override
  Future<LaundryOrder?> findOrder(String orderId) async =>
      orderById(orderId);

  @override
  Future<ReservationRequest> submitReservation({
    required String customerName,
    required String contactNumber,
    required DateTime dropOffDate,
    required String dropOffTime,
  }) async {
    final request = ReservationRequest(
      reference: 'REQ-${DateTime.now().millisecondsSinceEpoch}'
          '-${++_referenceSequence}',
      customerName: customerName.trim(),
      contactNumber: contactNumber.trim(),
      dropOffDate: dropOffDate,
      dropOffTime: dropOffTime,
    );
    _reservations.insert(0, request);
    notifyListeners();
    return request;
  }

  Future<ReservationRequest?> confirmReservation(String reference) async {
    final index = _reservations.indexWhere(
      (request) => request.reference.toUpperCase() == _normalize(reference),
    );
    if (index == -1) return null;

    final updated = _reservations[index].copyWith(
      status: ReservationStatus.confirmed,
    );
    _reservations[index] = updated;
    notifyListeners();
    return updated;
  }

  Future<LaundryOrder> receiveLaundry({
    String? reservationReference,
    required String customerName,
    required String contactNumber,
    required double weightKg,
  }) async {
    final order = LaundryOrder(
      orderId: previewOrderId(),
      customerName: customerName.trim(),
      contactNumber: contactNumber.trim(),
      weightKg: weightKg,
      status: LaundryStatus.received,
      receivedAt: DateTime.now(),
      reservationReference: reservationReference,
    );

    _orderSequence++;
    _orders.insert(0, order);
    _record(
      orderId: order.orderId,
      type: TransactionType.orderReceived,
      message: 'Laundry received from ${order.customerName}'
          ' · ${weightKg.toStringAsFixed(1)} kg',
    );

    if (reservationReference != null) {
      final index = _reservations.indexWhere(
        (request) => request.reference == reservationReference,
      );
      if (index != -1) {
        _reservations[index] = _reservations[index].copyWith(
          status: ReservationStatus.confirmed,
          orderId: order.orderId,
        );
      }
    }

    notifyListeners();
    return order;
  }

  Future<LaundryOrder> updateOrderStatus(
    String orderId,
    LaundryStatus status,
  ) async {
    final index = _orders.indexWhere(
      (order) => order.orderId == _normalize(orderId),
    );
    if (index == -1) throw StateError('Order $orderId was not found.');

    final current = _orders[index];
    if (current.status == status) return current;

    final updated = current.copyWith(status: status);
    _orders[index] = updated;

    if (status == LaundryStatus.claimed) {
      _record(
        orderId: updated.orderId,
        type: TransactionType.orderReleased,
        message: 'Laundry released to ${updated.customerName}',
      );
    } else {
      _record(
        orderId: updated.orderId,
        type: TransactionType.statusChanged,
        message: 'Status changed to ${status.label}',
      );
    }

    notifyListeners();
    return updated;
  }

  Future<LaundryOrder> recordPayment(
    String orderId, {
    required double amount,
    required String method,
  }) async {
    final index = _orders.indexWhere(
      (order) => order.orderId == _normalize(orderId),
    );
    if (index == -1) throw StateError('Order $orderId was not found.');

    final updated = _orders[index].copyWith(
      payment: Payment(
        amount: amount,
        method: method,
        recordedAt: DateTime.now(),
      ),
    );
    _orders[index] = updated;
    _record(
      orderId: updated.orderId,
      type: TransactionType.paymentRecorded,
      message: 'Payment of ${amount.toStringAsFixed(2)} recorded'
          ' via $method',
    );

    notifyListeners();
    return updated;
  }

  Future<LaundryOrder> releaseOrder(String orderId) =>
      updateOrderStatus(orderId, LaundryStatus.claimed);

  void _record({
    required String orderId,
    required TransactionType type,
    required String message,
  }) {
    _transactions.insert(
      0,
      TransactionRecord(
        id: 'TX-${DateTime.now().millisecondsSinceEpoch}'
            '-${++_transactionSequence}',
        orderId: orderId,
        type: type,
        message: message,
        timestamp: DateTime.now(),
      ),
    );
  }
}
