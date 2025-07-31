import 'enums.dart';
import 'service.dart';
import 'user.dart';

class Booking {
  final String id;
  final String clientId;
  final String providerId;
  final String serviceId;
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final BookingStatus status;
  final double totalPrice;
  final String? notes;
  final BookingLocation? location;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final PaymentInfo? payment;
  final List<String> attachments;

  Booking({
    required this.id,
    required this.clientId,
    required this.providerId,
    required this.serviceId,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.totalPrice,
    this.notes,
    this.location,
    required this.createdAt,
    this.confirmedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.payment,
    this.attachments = const [],
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      clientId: json['clientId'],
      providerId: json['providerId'],
      serviceId: json['serviceId'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: TimeOfDay(
        hour: json['scheduledTime']['hour'],
        minute: json['scheduledTime']['minute'],
      ),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
      ),
      totalPrice: json['totalPrice'].toDouble(),
      notes: json['notes'],
      location: json['location'] != null 
          ? BookingLocation.fromJson(json['location']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      confirmedAt: json['confirmedAt'] != null 
          ? DateTime.parse(json['confirmedAt']) 
          : null,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt']) 
          : null,
      cancellationReason: json['cancellationReason'],
      payment: json['payment'] != null 
          ? PaymentInfo.fromJson(json['payment']) 
          : null,
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'providerId': providerId,
      'serviceId': serviceId,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': {
        'hour': scheduledTime.hour,
        'minute': scheduledTime.minute,
      },
      'status': status.toString().split('.').last,
      'totalPrice': totalPrice,
      'notes': notes,
      'location': location?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'payment': payment?.toJson(),
      'attachments': attachments,
    };
  }

  String get statusText {
    switch (status) {
      case BookingStatus.pending:
        return 'En attente';
      case BookingStatus.confirmed:
        return 'Confirmée';
      case BookingStatus.inProgress:
        return 'En cours';
      case BookingStatus.completed:
        return 'Terminée';
      case BookingStatus.cancelled:
        return 'Annulée';
      case BookingStatus.disputed:
        return 'Litige';
    }
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.green[700]!;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.disputed:
        return Colors.purple;
    }
  }
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  cancelled,
  disputed
}

class BookingLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? additionalInfo;

  BookingLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.additionalInfo,
  });

  factory BookingLocation.fromJson(Map<String, dynamic> json) {
    return BookingLocation(
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      address: json['address'],
      additionalInfo: json['additionalInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'additionalInfo': additionalInfo,
    };
  }
}

class PaymentInfo {
  final String id;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final DateTime? paidAt;
  final String? transactionId;
  final String? failureReason;

  PaymentInfo({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
    this.currency = 'XOF',
    this.paidAt,
    this.transactionId,
    this.failureReason,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'],
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${json['method']}',
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
      ),
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'XOF',
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      transactionId: json['transactionId'],
      failureReason: json['failureReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'paidAt': paidAt?.toIso8601String(),
      'transactionId': transactionId,
      'failureReason': failureReason,
    };
  }

  String get methodText {
    switch (method) {
      case PaymentMethod.wave:
        return 'Wave';
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.creditCard:
        return 'Carte bancaire';
      case PaymentMethod.cash:
        return 'Espèces';
    }
  }

  String get statusText {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.processing:
        return 'En cours';
      case PaymentStatus.completed:
        return 'Payé';
      case PaymentStatus.failed:
        return 'Échec';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }
}

enum PaymentMethod {
  wave,
  orangeMoney,
  creditCard,
  cash
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  String format() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() => format();
}

// Extension pour les couleurs
extension ColorExtension on BookingStatus {
  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.green[700]!;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.disputed:
        return Colors.purple;
    }
  }
}

