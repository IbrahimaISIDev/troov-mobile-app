// models/app_data.dart

import 'transfer_models.dart';
class AppData {
  static final List<TransferService> transferServices = [
    TransferService(
      name: 'Orange Money',
      iconPath: 'assets/icons/orange_money.png',
      color: '#FF7900',
      maxAmount: 2000000,
      minAmount: 100,
      fees: 0.02,
    ),
    TransferService(
      name: 'Wave',
      iconPath: 'assets/icons/wave.png',
      color: '#0066FF',
      maxAmount: 1500000,
      minAmount: 50,
      fees: 0.01,
    ),
    TransferService(
      name: 'Free Money',
      iconPath: 'assets/icons/free_money.png',
      color: '#E31837',
      maxAmount: 1000000,
      minAmount: 100,
      fees: 0.015,
    ),
    TransferService(
      name: 'Wari',
      iconPath: 'assets/icons/wari.png',
      color: '#00A651',
      maxAmount: 3000000,
      minAmount: 200,
      fees: 0.025,
    ),
  ];

  static final List<Country> countries = [
    Country(
      name: 'Sénégal',
      code: 'SN',
      flag: '🇸🇳',
      currency: 'FCFA',
      supportedServices: ['Orange Money', 'Wave', 'Free Money', 'Wari'],
    ),
    Country(
      name: 'Mali',
      code: 'ML',
      flag: '🇲🇱',
      currency: 'FCFA',
      supportedServices: ['Orange Money', 'Wave', 'Wari'],
    ),
    Country(
      name: 'Burkina Faso',
      code: 'BF',
      flag: '🇧🇫',
      currency: 'FCFA',
      supportedServices: ['Orange Money', 'Wari'],
    ),
    Country(
      name: 'Côte d\'Ivoire',
      code: 'CI',
      flag: '🇨🇮',
      currency: 'FCFA',
      supportedServices: ['Orange Money', 'Wave', 'Wari'],
    ),
  ];

  static final List<PaymentCategory> paymentCategories = [
    PaymentCategory(
      name: 'Factures',
      icon: 'receipt',
      color: '#FF6B6B',
      merchants: ['SENELEC', 'SDE', 'Sonatel', 'Canal+'],
    ),
    PaymentCategory(
      name: 'Abonnements',
      icon: 'subscriptions',
      color: '#4ECDC4',
      merchants: ['Netflix', 'Spotify', 'YouTube Premium', 'Adobe'],
    ),
    PaymentCategory(
      name: 'Transport',
      icon: 'directions_bus',
      color: '#45B7D1',
      merchants: ['DDD', 'Tata Bus', 'Taxi Rapide'],
    ),
    PaymentCategory(
      name: 'Shopping',
      icon: 'shopping_cart',
      color: '#96CEB4',
      merchants: ['Auchan', 'Casino', 'Carrefour', 'Jumia'],
    ),
    PaymentCategory(
      name: 'Éducation',
      icon: 'school',
      color: '#FFEAA7',
      merchants: ['Université Cheikh Anta Diop', 'École Française', 'Cours Sainte Marie'],
    ),
    PaymentCategory(
      name: 'Santé',
      icon: 'local_hospital',
      color: '#DDA0DD',
      merchants: ['Hôpital Principal', 'Clinique Pasteur', 'Pharmacie'],
    ),
  ];

  static final List<TransferHistory> mockTransferHistory = [
    TransferHistory(
      id: 'TXN001',
      recipientName: 'Moussa Diallo',
      recipientPhone: '+221 77 123 45 67',
      amount: 25000,
      currency: 'FCFA',
      date: DateTime.now().subtract(Duration(days: 1)),
      service: 'Orange Money',
      country: 'Sénégal',
      status: TransferStatus.completed,
      type: TransferType.simple,
      fees: 500,
    ),
    TransferHistory(
      id: 'TXN002',
      recipientName: 'Fatou Sarr',
      recipientPhone: '+221 76 987 65 43',
      amount: 15500,
      currency: 'FCFA',
      date: DateTime.now().subtract(Duration(days: 2)),
      service: 'Wave',
      country: 'Sénégal',
      status: TransferStatus.completed,
      type: TransferType.simple,
      fees: 155,
    ),
    TransferHistory(
      id: 'TXN003',
      recipientName: 'Multi-transfert (3)',
      recipientPhone: 'Multiple',
      amount: 75000,
      currency: 'FCFA',
      date: DateTime.now().subtract(Duration(days: 3)),
      service: 'Orange Money',
      country: 'Multiple',
      status: TransferStatus.completed,
      type: TransferType.multiple,
      fees: 1500,
    ),
  ];

  static final List<PaymentHistory> mockPaymentHistory = [
    PaymentHistory(
      id: 'PAY001',
      merchantName: 'SENELEC',
      category: 'Factures',
      amount: 45000,
      currency: 'FCFA',
      date: DateTime.now().subtract(Duration(days: 1)),
      status: PaymentStatus.completed,
      type: PaymentType.bill,
      reference: 'ELC123456',
    ),
    PaymentHistory(
      id: 'PAY002',
      merchantName: 'Netflix',
      category: 'Abonnements',
      amount: 8500,
      currency: 'FCFA',
      date: DateTime.now().subtract(Duration(days: 5)),
      status: PaymentStatus.completed,
      type: PaymentType.subscription,
    ),
  ];

  static final List<ScheduledTransfer> mockScheduledTransfers = [
    ScheduledTransfer(
      id: 'SCH001',
      recipientName: 'Maman',
      recipientPhone: '+221 77 999 88 77',
      amount: 50000,
      service: 'Orange Money',
      country: 'Sénégal',
      nextExecution: DateTime.now().add(Duration(days: 7)),
      frequency: ScheduleFrequency.monthly,
      isActive: true,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
    ),
  ];
}