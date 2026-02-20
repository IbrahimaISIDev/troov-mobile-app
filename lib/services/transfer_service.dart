import '../models/transfer_model.dart';
import 'dart:math';

class TransferService {
  Future<double> calculateFees(double amount, TransferMethod method) async {
    // Simple fee logic: 1% for internal, 2% for external
    double percentage = 0.01;
    if (method == TransferMethod.mobile_money ||
        method == TransferMethod.cash_pickup) {
      percentage = 0.02;
    }
    return amount * percentage;
  }

  Future<TransferTransaction> initiateTransfer({
    required String senderId,
    required String recipientName,
    required String recipientPhone,
    required double amount,
    required TransferMethod method,
    String? destinationCountry, // Added to fix lint
    String? serviceSlug, // Added to fix lint
    String? userId, // Added to fix lint
  }) async {
    await Future.delayed(Duration(seconds: 1)); // Validate balance etc.

    final fees = await calculateFees(amount, method);

    return TransferTransaction(
      id: 'TRX-${Random().nextInt(100000)}',
      senderId: senderId,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      amount: amount,
      fees: fees,
      totalAmount: amount + fees,
      method: method,
      status: TransferStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  Future<TransferTransaction> confirmTransfer(String transactionId) async {
    await Future.delayed(Duration(seconds: 2)); // Simulate processing

    // In a real app, we would fetch the transaction by ID and update it.
    // Here we return a success mock.
    return TransferTransaction(
      id: transactionId,
      senderId: 'current_user',
      recipientName: 'Destinataire',
      recipientPhone: '+221...',
      amount: 5000,
      fees: 50,
      totalAmount: 5050,
      method: TransferMethod.mobile_money,
      status: TransferStatus.completed,
      createdAt: DateTime.now(),
      completedAt: DateTime.now(),
      referenceNumber: 'REF-${Random().nextInt(999999)}',
    );
  }

  /// Mocked method to fix lint error
  Future<List<TransferTransaction>> getTransactionHistory(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return [
      TransferTransaction(
        id: 'TRX-123456',
        senderId: userId,
        recipientName: 'Moussa Diop',
        recipientPhone: '+221 77 123 45 67',
        amount: 5000,
        fees: 50,
        totalAmount: 5050,
        method: TransferMethod.mobile_money,
        status: TransferStatus.completed,
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        referenceNumber: 'REF-987654',
      ),
      TransferTransaction(
        id: 'TRX-789012',
        senderId: userId,
        recipientName: 'Fatou Ndiaye',
        recipientPhone: '+221 70 987 65 43',
        amount: 10000,
        fees: 100,
        totalAmount: 10100,
        method: TransferMethod.mobile_money,
        status: TransferStatus.pending,
        createdAt: DateTime.now().subtract(Duration(hours: 5)),
        referenceNumber: 'REF-123098',
      ),
    ];
  }

  /// Mocked method to fix lint error
  Future<List<Map<String, dynamic>>> getCountries() async {
    return [
      {'code': 'SN', 'name': 'Sénégal', 'flag': '🇸🇳', 'currency': 'XOF'},
      {
        'code': 'CI',
        'name': 'Côte d\'Ivoire',
        'flag': '🇨🇮',
        'currency': 'XOF'
      },
      {'code': 'ML', 'name': 'Mali', 'flag': '🇲🇱', 'currency': 'XOF'},
    ];
  }

  /// Mocked method to fix lint error
  Future<List<Map<String, dynamic>>> getOperators(
      {required String country}) async {
    if (country == 'SN') {
      return [
        {
          'slug': 'orange-money',
          'name': 'Orange Money',
          'logo': 'assets/images/om.png'
        },
        {'slug': 'wave', 'name': 'Wave', 'logo': 'assets/images/wave.png'},
      ];
    }
    return [
      {'slug': 'mtn', 'name': 'MTN', 'logo': 'assets/images/mtn.png'},
    ];
  }

  /// Mocked method to fix lint error
  Future<bool> deposit({
    required String operatorId,
    required double amount,
    required String phone,
    required String userId,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }

  /// Mocked method to fix lint error
  Future<bool> withdraw({
    required String operatorId,
    required double amount,
    required String phone,
    required String userId,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return true;
  }
}
