import 'package:flutter/material.dart';
import '../../utils/localization.dart';
import '../../utils/theme.dart';
import '../../models/service.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Service service;
  final ServiceProvider provider;

  const BookingScreen({
    Key? key,
    required this.service,
    required this.provider,
  }) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();
  final _bookingService = BookingService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  double _totalPrice = 0.0;
  int _quantity = 1;
  int _estimatedHours = 1;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _calculatePrice();
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

  void _calculatePrice() {
    switch (widget.service.priceType) {
      case PriceType.hourly:
        _totalPrice = widget.service.price * _estimatedHours;
        break;
      case PriceType.fixed:
        _totalPrice = widget.service.price;
        break;
      case PriceType.perItem:
        _totalPrice = widget.service.price * _quantity;
        break;
      case PriceType.perKm:
        _totalPrice = widget.service.price * 10; // Distance estimée
        break;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _proceedToPayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Créer les données de réservation
    final bookingData = {
      'serviceId': widget.service.id,
      'providerId': widget.provider.id,
      'scheduledDate': _selectedDate!.toIso8601String(),
      'scheduledTime': {
        'hour': _selectedTime!.hour,
        'minute': _selectedTime!.minute,
      },
      'totalPrice': _totalPrice,
      'notes': _notesController.text.trim(),
      'location': {
        'address': _addressController.text.trim(),
        'latitude': 0.0, // TODO: Obtenir la géolocalisation
        'longitude': 0.0,
      },
      'quantity': _quantity,
      'estimatedHours': _estimatedHours,
    };

    // Naviguer vers l'écran de paiement
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          service: widget.service,
          provider: widget.provider,
          bookingData: bookingData,
          totalAmount: _totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Réserver le service'),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations du service
                      _buildServiceInfo(),
                      
                      SizedBox(height: 24),
                      
                      // Sélection de date et heure
                      _buildDateTimeSelection(),
                      
                      SizedBox(height: 24),
                      
                      // Quantité/Durée
                      _buildQuantitySelection(),
                      
                      SizedBox(height: 24),
                      
                      // Adresse
                      _buildAddressInput(),
                      
                      SizedBox(height: 24),
                      
                      // Notes
                      _buildNotesInput(),
                      
                      SizedBox(height: 24),
                      
                      // Résumé du prix
                      _buildPriceSummary(),
                      
                      SizedBox(height: 32),
                      
                      // Bouton de réservation
                      _buildBookingButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service sélectionné',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppTheme.primaryBlue,
                    size: 30,
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
                      SizedBox(height: 4),
                      Text(
                        'Par ${widget.provider.user.fullName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '${widget.provider.profile.rating.toStringAsFixed(1)} (${widget.provider.profile.reviewCount})',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date et heure',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppTheme.primaryBlue),
                          SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Sélectionner une date',
                            style: TextStyle(
                              color: _selectedDate != null ? Colors.black : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: AppTheme.primaryBlue),
                          SizedBox(width: 12),
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format()
                                : 'Heure',
                            style: TextStyle(
                              color: _selectedTime != null ? Colors.black : Colors.grey[600],
                            ),
                          ),
                        ],
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

  Widget _buildQuantitySelection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.service.priceType == PriceType.hourly ? 'Durée estimée' : 'Quantité',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (widget.service.priceType == PriceType.hourly) {
                        if (_estimatedHours > 1) _estimatedHours--;
                      } else {
                        if (_quantity > 1) _quantity--;
                      }
                    });
                    _calculatePrice();
                  },
                  icon: Icon(Icons.remove_circle_outline, color: AppTheme.primaryBlue),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.service.priceType == PriceType.hourly
                          ? '$_estimatedHours heure${_estimatedHours > 1 ? 's' : ''}'
                          : '$_quantity',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (widget.service.priceType == PriceType.hourly) {
                        _estimatedHours++;
                      } else {
                        _quantity++;
                      }
                    });
                    _calculatePrice();
                  },
                  icon: Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInput() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adresse du service',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Entrez l\'adresse complète',
                prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.primaryBlue),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une adresse';
                }
                return null;
              },
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesInput() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notes supplémentaires (optionnel)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Ajoutez des détails ou instructions spéciales...',
                prefixIcon: Icon(Icons.note, color: AppTheme.primaryBlue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.primaryBlue),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé du prix',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Prix unitaire:'),
                Text('${widget.service.price.toStringAsFixed(0)} FCFA'),
              ],
            ),
            if (widget.service.priceType == PriceType.hourly) ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Durée:'),
                  Text('$_estimatedHours heure${_estimatedHours > 1 ? 's' : ''}'),
                ],
              ),
            ],
            if (widget.service.priceType == PriceType.perItem) ...[
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quantité:'),
                  Text('$_quantity'),
                ],
              ),
            ],
            Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_totalPrice.toStringAsFixed(0)} FCFA',
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

  Widget _buildBookingButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _proceedToPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Procéder au paiement',
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

