/// Kind of staff action recorded in the transaction history.
enum TransactionType {
  orderReceived,
  statusChanged,
  paymentRecorded,
  orderReleased,
}

extension TransactionTypeLabel on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.orderReceived:
        return 'Order received';
      case TransactionType.statusChanged:
        return 'Status updated';
      case TransactionType.paymentRecorded:
        return 'Payment recorded';
      case TransactionType.orderReleased:
        return 'Laundry released';
    }
  }
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.orderId,
    required this.type,
    required this.message,
    required this.timestamp,
  });

  final String id;
  final String orderId;
  final TransactionType type;
  final String message;
  final DateTime timestamp;
}
