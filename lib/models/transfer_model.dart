enum TransferStatus { pending, processing, completed, failed, cancelled }

enum TransferMethod { bank_account, mobile_money, wallet, cash_pickup }

class TransferTransaction {
  final String id;
  final String senderId;
  final String recipientName;
  final String recipientPhone;
  final double amount;
  final String currency;
  final double fees;
  final double totalAmount;
  final TransferMethod method;
  final TransferStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? referenceNumber;

  TransferTransaction({
    required this.id,
    required this.senderId,
    required this.recipientName,
    required this.recipientPhone,
    required this.amount,
    this.currency = 'XOF',
    required this.fees,
    required this.totalAmount,
    required this.method,
    this.status = TransferStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.referenceNumber,
  });

  factory TransferTransaction.fromJson(Map<String, dynamic> json) {
    return TransferTransaction(
      id: json['id'],
      senderId: json['senderId'],
      recipientName: json['recipientName'],
      recipientPhone: json['recipientPhone'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      fees: (json['fees'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      method: TransferMethod.values.firstWhere(
          (e) => e.toString().split('.').last == json['method'],
          orElse: () => TransferMethod.mobile_money),
      status: TransferStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
          orElse: () => TransferStatus.pending),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      referenceNumber: json['referenceNumber'],
    );
  }
}
