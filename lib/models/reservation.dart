/// Lifecycle of a customer booking request.
///
/// A reservation is only a request until staff confirm it, and it becomes an
/// order only after staff receive the laundry and issue an Order ID.
enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
}

extension ReservationStatusLabel on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'Awaiting confirmation';
      case ReservationStatus.confirmed:
        return 'Confirmed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class ReservationRequest {
  const ReservationRequest({
    required this.reference,
    required this.customerName,
    required this.contactNumber,
    required this.dropOffDate,
    required this.dropOffTime,
    this.status = ReservationStatus.pending,
    this.orderId,
    this.isDemo = false,
  });

  final String reference;
  final String customerName;
  final String contactNumber;
  final DateTime dropOffDate;
  final String dropOffTime;
  final ReservationStatus status;

  /// Set by staff when the laundry is received and an Order ID is issued.
  final String? orderId;

  /// True for the seeded sample records shown in the local demo mode.
  final bool isDemo;

  bool get isConfirmed => status == ReservationStatus.confirmed;

  ReservationRequest copyWith({
    ReservationStatus? status,
    String? orderId,
  }) {
    return ReservationRequest(
      reference: reference,
      customerName: customerName,
      contactNumber: contactNumber,
      dropOffDate: dropOffDate,
      dropOffTime: dropOffTime,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      isDemo: isDemo,
    );
  }
}
