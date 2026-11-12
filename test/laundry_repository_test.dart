import 'package:flutter_test/flutter_test.dart';
import 'package:foldflow/data/laundry_repository.dart';
import 'package:foldflow/models/laundry_order.dart';
import 'package:foldflow/models/reservation.dart';
import 'package:foldflow/models/transaction_record.dart';

void main() {
  group('DemoLaundryRepository', () {
    late DemoLaundryRepository repository;

    setUp(() {
      repository = DemoLaundryRepository();
    });

    test('prepares a local reservation request, not an order ticket', () async {
      final request = await repository.submitReservation(
        customerName: 'Taylor Reed',
        contactNumber: '+1 555 010 1234',
        dropOffDate: DateTime(2026, 10, 27),
        dropOffTime: '9:00 AM',
      );

      expect(request.reference, startsWith('REQ-'));
      expect(request.reference, isNot(startsWith('ORD-')));
      expect(request.status, ReservationStatus.pending);
      expect(request.customerName, 'Taylor Reed');
      expect(request.contactNumber, '+1 555 010 1234');

      // A booking request never creates a trackable order.
      expect(repository.orderById(request.reference), isNull);
      expect(
        repository.reservations
            .any((element) => element.reference == request.reference),
        isTrue,
      );
    });

    test('returns the labeled demo order and nothing else', () async {
      final order = await repository.findOrder('ord-1042');

      expect(order?.orderId, 'ORD-1042');
      expect(order?.status, LaundryStatus.readyForPickup);
      expect(order?.isDemo, isTrue);
      expect(await repository.findOrder('ORD-9999'), isNull);
    });

    test('staff confirm, receive, update, pay and release an order', () async {
      final confirmed = await repository.confirmReservation('REQ-DEMO-001');
      expect(confirmed?.isConfirmed, isTrue);
      expect(confirmed?.orderId, isNull);

      // The next Order ID is generated at the counter, not at booking.
      expect(repository.previewOrderId(), 'ORD-1043');

      final order = await repository.receiveLaundry(
        reservationReference: 'REQ-DEMO-001',
        customerName: 'Sample Customer',
        contactNumber: '+1 555 010 1042',
        weightKg: 4.5,
      );

      expect(order.orderId, 'ORD-1043');
      expect(order.status, LaundryStatus.received);
      expect(repository.previewOrderId(), 'ORD-1044');
      expect(
        repository.reservationByReference('REQ-DEMO-001')?.orderId,
        'ORD-1043',
      );

      await repository.updateOrderStatus('ORD-1043', LaundryStatus.washing);
      await repository.updateOrderStatus('ORD-1043', LaundryStatus.drying);
      await repository.updateOrderStatus(
        'ORD-1043',
        LaundryStatus.readyForPickup,
      );
      await repository.recordPayment('ORD-1043', amount: 144, method: 'Cash');
      await repository.releaseOrder('ORD-1043');

      final updated = repository.orderById('ORD-1043');
      expect(updated?.status, LaundryStatus.claimed);
      expect(updated?.payment?.amount, 144);
      expect(updated?.payment?.method, 'Cash');

      final types = repository.transactions
          .where((record) => record.orderId == 'ORD-1043')
          .map((record) => record.type)
          .toSet();
      expect(
        types,
        containsAll(<TransactionType>[
          TransactionType.orderReceived,
          TransactionType.statusChanged,
          TransactionType.paymentRecorded,
          TransactionType.orderReleased,
        ]),
      );
    });
  });
}
