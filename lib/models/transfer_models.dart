// models/transfer_models.dart
class TransferService {
  final String name;
  final String iconPath;
  final String color;
  final double maxAmount;
  final double minAmount;
  final double fees;

  TransferService({
    required this.name,
    required this.iconPath,
    required this.color,
    required this.maxAmount,
    required this.minAmount,
    required this.fees,
  });
}

class Country {
  final String name;
  final String code;
  final String flag;
  final String currency;
  final List<String> supportedServices;

  Country({
    required this.name,
    required this.code,
    required this.flag,
    required this.currency,
    required this.supportedServices,
  });
}

class TransferHistory {
  final String id;
  final String recipientName;
  final String recipientPhone;
  final double amount;
  final String currency;
  final DateTime date;
  final String service;
  final String country;
  final TransferStatus status;
  final TransferType type;
  final double fees;
  final String? scheduleId;

  TransferHistory({
    required this.id,
    required this.recipientName,
    required this.recipientPhone,
    required this.amount,
    required this.currency,
    required this.date,
    required this.service,
    required this.country,
    required this.status,
    required this.type,
    required this.fees,
    this.scheduleId,
  });
}

class PaymentHistory {
  final String id;
  final String merchantName;
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final PaymentStatus status;
  final PaymentType type;
  final String? reference;

  PaymentHistory({
    required this.id,
    required this.merchantName,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    required this.status,
    required this.type,
    this.reference,
  });
}

class ScheduledTransfer {
  final String id;
  final String recipientName;
  final String recipientPhone;
  final double amount;
  final String service;
  final String country;
  final DateTime nextExecution;
  final ScheduleFrequency frequency;
  final bool isActive;
  final DateTime createdAt;

  ScheduledTransfer({
    required this.id,
    required this.recipientName,
    required this.recipientPhone,
    required this.amount,
    required this.service,
    required this.country,
    required this.nextExecution,
    required this.frequency,
    required this.isActive,
    required this.createdAt,
  });
}

class MultipleTransfer {
  final String id;
  final List<TransferRecipient> recipients;
  final DateTime date;
  final double totalAmount;
  final String service;
  final TransferStatus status;

  MultipleTransfer({
    required this.id,
    required this.recipients,
    required this.date,
    required this.totalAmount,
    required this.service,
    required this.status,
  });
}

class TransferRecipient {
  final String name;
  final String phone;
  final double amount;
  final String country;

  TransferRecipient({
    required this.name,
    required this.phone,
    required this.amount,
    required this.country,
  });
}

class PaymentCategory {
  final String name;
  final String icon;
  final String color;
  final List<String> merchants;

  PaymentCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.merchants,
  });
}

enum TransferStatus { pending, completed, failed, cancelled }
enum PaymentStatus { pending, completed, failed, cancelled }
enum TransferType { simple, multiple, scheduled }
enum PaymentType { bill, merchant, subscription, topup }
enum ScheduleFrequency { daily, weekly, monthly, quarterly }