import 'package:flutter/material.dart';
import '../../utils/localization.dart';
import '../../utils/theme.dart';
import '../../models/service.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import '../../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final Service service;
  final ServiceProvider provider;
  final Map<String, dynamic> bookingData;
  final double totalAmount;

  const PaymentScreen({
    Key? key,
    required this.service,
    required this.provider,
    required this.bookingData,
    required this.totalAmount,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _bookingService = BookingService();
  final _paymentService = PaymentService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  PaymentMethod _selectedMethod = PaymentMethod.wave;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_validatePaymentInfo()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Créer la réservation d'abord
      final booking = await _bookingService.createBooking(widget.bookingData);

      // Traiter le paiement
      PaymentInfo? paymentInfo;
      
      switch (_selectedMethod) {
        case PaymentMethod.wave:
        case PaymentMethod.orangeMoney:
          paymentInfo = await _paymentService.processMobilePayment(
            method: _selectedMethod,
            phoneNumber: _phoneController.text.trim(),
            amount: widget.totalAmount,
            bookingId: booking.id,
          );
          break;
        case PaymentMethod.creditCard:
          paymentInfo = await _paymentService.processCreditCardPayment(
            cardNumber: _cardNumberController.text.trim(),
            expiryDate: _expiryController.text.trim(),
            cvv: _cvvController.text.trim(),
            amount: widget.totalAmount,
            bookingId: booking.id,
          );
          break;
        case PaymentMethod.cash:
          paymentInfo = await _paymentService.processCashPayment(
            amount: widget.totalAmount,
            bookingId: booking.id,
          );
          break;
      }

      if (paymentInfo != null) {
        // Paiement réussi
        _showPaymentSuccess(booking, paymentInfo);
      } else {
        throw Exception('Échec du paiement');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de paiement: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  bool _validatePaymentInfo() {
    switch (_selectedMethod) {
      case PaymentMethod.wave:
      case PaymentMethod.orangeMoney:
        if (_phoneController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Veuillez entrer votre numéro de téléphone'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
      case PaymentMethod.creditCard:
        if (_cardNumberController.text.trim().isEmpty ||
            _expiryController.text.trim().isEmpty ||
            _cvvController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Veuillez remplir tous les champs de la carte'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        break;
      case PaymentMethod.cash:
        // Pas de validation nécessaire pour le paiement en espèces
        break;
    }
    return true;
  }

  void _showPaymentSuccess(Booking booking, PaymentInfo paymentInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'Paiement réussi !',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Votre réservation a été confirmée',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Numéro de réservation:', style: TextStyle(fontSize: 12)),
                  Text(
                    booking.id.substring(0, 8).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Retour à l\'accueil'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Naviguer vers les détails de la réservation
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: Text('Voir la réservation', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Paiement'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Résumé de la commande
                    _buildOrderSummary(),
                    
                    SizedBox(height: 24),
                    
                    // Méthodes de paiement
                    _buildPaymentMethods(),
                    
                    SizedBox(height: 24),
                    
                    // Formulaire de paiement
                    _buildPaymentForm(),
                    
                    SizedBox(height: 32),
                    
                    // Bouton de paiement
                    _buildPaymentButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé de la commande',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppTheme.primaryBlue,
                    size: 25,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Par ${widget.provider.user.fullName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total à payer:',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.totalAmount.toStringAsFixed(0)} FCFA',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Méthode de paiement',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildPaymentMethodTile(
              method: PaymentMethod.wave,
              title: 'Wave',
              subtitle: 'Paiement mobile Wave',
              icon: Icons.phone_android,
            ),
            _buildPaymentMethodTile(
              method: PaymentMethod.orangeMoney,
              title: 'Orange Money',
              subtitle: 'Paiement mobile Orange',
              icon: Icons.phone_android,
            ),
            _buildPaymentMethodTile(
              method: PaymentMethod.creditCard,
              title: 'Carte bancaire',
              subtitle: 'Visa, MasterCard',
              icon: Icons.credit_card,
            ),
            _buildPaymentMethodTile(
              method: PaymentMethod.cash,
              title: 'Espèces',
              subtitle: 'Paiement à la livraison',
              icon: Icons.money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return RadioListTile<PaymentMethod>(
      value: method,
      groupValue: _selectedMethod,
      onChanged: (value) {
        setState(() {
          _selectedMethod = value!;
        });
      },
      title: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
      activeColor: AppTheme.primaryBlue,
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedMethod) {
      case PaymentMethod.wave:
      case PaymentMethod.orangeMoney:
        return _buildMobilePaymentForm();
      case PaymentMethod.creditCard:
        return _buildCreditCardForm();
      case PaymentMethod.cash:
        return _buildCashPaymentInfo();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildMobilePaymentForm() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de paiement',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: 'Ex: 77 123 45 67',
                prefixIcon: Icon(Icons.phone, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.primaryBlue),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vous recevrez un code de confirmation par SMS',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardForm() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de carte',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Numéro de carte',
                hintText: '1234 5678 9012 3456',
                prefixIcon: Icon(Icons.credit_card, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.primaryBlue),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'MM/AA',
                      hintText: '12/25',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPaymentInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paiement en espèces',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(Icons.money, color: Colors.orange, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Vous paierez directement au prestataire lors de la prestation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Montant: ${widget.totalAmount.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Traitement en cours...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Payer ${widget.totalAmount.toStringAsFixed(0)} FCFA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

