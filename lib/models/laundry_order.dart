/// The five stages shown to customers and managed by staff.
enum LaundryStatus {
  received,
  washing,
  drying,
  readyForPickup,
  claimed,
}

extension LaundryStatusLabel on LaundryStatus {
  String get label {
    switch (this) {
      case LaundryStatus.received:
        return 'Received';
      case LaundryStatus.washing:
        return 'Washing';
      case LaundryStatus.drying:
        return 'Drying';
      case LaundryStatus.readyForPickup:
        return 'Ready for Pickup';
      case LaundryStatus.claimed:
        return 'Claimed / Completed';
    }
  }

  /// Short helper line shown under each stage.
  String get hint {
    switch (this) {
      case LaundryStatus.received:
        return 'Laundry recorded at the counter';
      case LaundryStatus.washing:
        return 'Loads are being washed';
      case LaundryStatus.drying:
        return 'Loads are being dried and folded';
      case LaundryStatus.readyForPickup:
        return 'Visit the shop to collect your laundry';
      case LaundryStatus.claimed:
        return 'Laundry released and the order is closed';
    }
  }
}

/// Payment recorded by staff at the shop counter.
class Payment {
  const Payment({
    required this.amount,
    required this.method,
    required this.recordedAt,
  });

  final double amount;
  final String method;
  final DateTime recordedAt;
}

class LaundryOrder {
  const LaundryOrder({
    required this.orderId,
    required this.customerName,
    required this.contactNumber,
    required this.weightKg,
    required this.status,
    required this.receivedAt,
    this.reservationReference,
    this.payment,
    this.isDemo = false,
  });

  final String orderId;
  final String customerName;
  final String contactNumber;
  final double weightKg;
  final LaundryStatus status;
  final DateTime receivedAt;
  final String? reservationReference;
  final Payment? payment;

  /// True for the seeded sample order used to preview the app.
  final bool isDemo;

  bool get isPaid => payment != null;

  bool get isReadyForPickup => status == LaundryStatus.readyForPickup;

  bool get isCompleted => status == LaundryStatus.claimed;

  LaundryOrder copyWith({
    LaundryStatus? status,
    double? weightKg,
    Payment? payment,
  }) {
    return LaundryOrder(
      orderId: orderId,
      customerName: customerName,
      contactNumber: contactNumber,
      weightKg: weightKg ?? this.weightKg,
      status: status ?? this.status,
      receivedAt: receivedAt,
      reservationReference: reservationReference,
      payment: payment ?? this.payment,
      isDemo: isDemo,
    );
  }
}
