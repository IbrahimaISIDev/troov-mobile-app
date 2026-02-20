import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import '../../utils/theme.dart';
import '../history/history_screen.dart';

import '../../services/transfer_service.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../models/transfer_model.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  _TransferScreenState createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  bool _isBalanceVisible = false;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  // ignore: unused_field
  final TextEditingController _nameController =
      TextEditingController(); // For optional name

  String _selectedService = ''; // Will be set dynamically
  dynamic _selectedOperator; // Store full operator object
  double _operatorFeeAmount = 0.0;
  double _totalFees = 0.0;
  double _totalAmount = 0.0;
  String _currentCountryCode = 'SN'; // Default Source Country (Simulation)

  // Country State
  List<dynamic> _countries = [];
  String? _selectedCountryCode;
  String _selectedCallingCode = '';

  String _selectedCurrency = '';

  final TransferService _transferService = TransferService();
  final AuthService _authService = AuthService();

  List<dynamic> _transferServices = [];
  bool _isLoadingOperators = true;
  User? _currentUser;

  List<dynamic> _recentTransfers = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadCountries(); // Load countries and then operators
    _loadUser(); // Loads user and triggers history fetch
    _detectLocation();
  }

  // Permission handling and Location detection
  Future<void> _detectLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    // Get position (simplified)
    // Position position = await Geolocator.getCurrentPosition();
    // In a real app, use coordinates to reverse geocode and find Country

    // For DEMO/SIMULATION: Assume User is in Senegal
    setState(() {
      _currentCountryCode = 'SN';
    });
    _calculateFees();
  }

  Future<void> _pickContact() async {
    if (await FlutterContacts.requestPermission()) {
      // Fetch all contacts (simplified for demo, might need pagination for large lists)
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      _showContactPickerModal(contacts);
    }
  }

  void _showContactPickerModal(List<Contact> contacts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                SizedBox(height: 15),
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Sélectionner un contact',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      if (contact.phones.isEmpty) return SizedBox.shrink();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.primaryBlue.withOpacity(0.1),
                          child: Text(
                            contact.displayName.isNotEmpty
                                ? contact.displayName[0]
                                : '?',
                            style: TextStyle(color: AppTheme.primaryBlue),
                          ),
                        ),
                        title: Text(contact.displayName),
                        subtitle: Text(contact.phones.first.number),
                        onTap: () {
                          setState(() {
                            _nameController.text = contact.displayName;
                            String phone = contact.phones.first.number;
                            phone =
                                phone.replaceAll(' ', '').replaceAll('-', '');
                            _phoneController.text = phone;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadUser({bool forceRefresh = false}) async {
    final user = forceRefresh
        ? await _authService.refreshUser()
        : await _authService.getCurrentUser();
    print('DEBUG: Loaded User: $user (ForceRefresh: $forceRefresh)');

    if (mounted) {
      setState(() {
        _currentUser = user;
      });
      if (user != null) {
        _fetchHistory(user.id);
      } else {
        // User is null, stop history loading
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _fetchHistory(String userId) async {
    try {
      final history = await _transferService.getTransactionHistory(userId);
      if (mounted) {
        setState(() {
          _recentTransfers = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      print('Error loading history: $e');
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _loadCountries() async {
    print('DEBUG: _loadCountries called');
    try {
      final countries = await _transferService.getCountries();
      print('DEBUG: Countries loaded: ${countries.length}');
      if (mounted) {
        setState(() {
          _countries = countries;
          if (_countries.isNotEmpty) {
            final senegal = _countries.firstWhere((c) => c['code'] == 'SN',
                orElse: () => _countries.first as Map<String, dynamic>);
            print('DEBUG: Selecting country: ${senegal['name']}');
            _selectCountry(senegal);
          } else {
            print('DEBUG: No countries found');
            _isLoadingOperators = false; // Stop spinner if no countries
          }
        });
      }
    } catch (e) {
      print('DEBUG: Error loading countries: $e');
      if (mounted) setState(() => _isLoadingOperators = false);
    }
  }

  void _selectCountry(dynamic country) {
    print('DEBUG: _selectCountry: ${country['code']}');
    setState(() {
      _selectedCountryCode = country['code'];
      _selectedCallingCode = country['callingCode'] ?? '';
      _selectedCurrency = country['currency'] ?? '';

      if (_phoneController.text.isEmpty) {
        _phoneController.text = _selectedCallingCode;
      }
    });
    _loadOperators(); // Load operators IS called here
    _calculateFees();
  }

  Future<void> _loadOperators() async {
    print('DEBUG: _loadOperators called. Country: $_selectedCountryCode');
    if (_selectedCountryCode == null) {
      print('DEBUG: _selectedCountryCode is null, returning.');
      return;
    }

    setState(() {
      _isLoadingOperators = true;
    });

    try {
      print('DEBUG: Fetching operators from service...');
      final operators = await _transferService.getOperators(
          country: _selectedCountryCode ?? 'SN');
      print('DEBUG: Operators loaded: ${operators.length}');

      if (mounted) {
        setState(() {
          _transferServices = operators;
          _isLoadingOperators = false;
          if (_transferServices.isNotEmpty) {
            _selectedService = _transferServices[0]['name'];
            _selectedOperator = _transferServices[0];
            _calculateFees();
          }
        });
      }
    } catch (e) {
      print('DEBUG: Error loading operators: $e');
      if (mounted) {
        setState(() {
          _isLoadingOperators = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32),

            // Header avec titre
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transfert d\'argent',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Envoyez de l\'argent facilement',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.history,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Solde disponible
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryBlue,
                    AppTheme.primaryBlue.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Solde disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isBalanceVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isBalanceVisible = !_isBalanceVisible;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    _isBalanceVisible
                        ? '${_currentUser?.balance ?? 0.0} FCFA' // Dynamic balance
                        : '******',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      _buildBalanceAction(Icons.add, 'Recharger',
                          () => _showTransactionModal(context, 'Recharger')),
                      SizedBox(width: 20),
                      _buildBalanceAction(Icons.remove, 'Retirer',
                          () => _showTransactionModal(context, 'Retirer')),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Services de transfert
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Depuis mon compte',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    height: 100,
                    child: _isLoadingOperators
                        ? Center(child: CircularProgressIndicator())
                        : _transferServices.isEmpty
                            ? Center(child: Text("Aucun opérateur disponible"))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _transferServices.length,
                                itemBuilder: (context, index) {
                                  final service = _transferServices[index];
                                  final name = service['name'];
                                  final logoUrl =
                                      service['logoUrl'] ?? service['logo'];
                                  final isSelected = _selectedService == name;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedService = name;
                                        _selectedOperator = service;
                                        _calculateFees();
                                      });
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(right: 15),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryBlue
                                                .withOpacity(0.05)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryBlue
                                              : Colors.grey.shade300,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.05),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 40,
                                            width: 40,
                                            child: logoUrl != null &&
                                                    logoUrl.startsWith('http')
                                                ? Image.network(
                                                    logoUrl,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (_, __, ___) => Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/${name.toString().toLowerCase().replaceAll(" ", "_")}.png', // Fallback
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (_, __, ___) => Icon(
                                                      Icons
                                                          .account_balance_wallet,
                                                      color: isSelected
                                                          ? AppTheme.primaryBlue
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4),
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? AppTheme.primaryBlue
                                                    : Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Formulaire de transfert
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nouveau transfert',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Sélection du pays
                  // Dropdown construction
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCountryCode,
                        hint: Text('Sélectionner un pays'),
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF0091EA)),
                        items:
                            _countries.map<DropdownMenuItem<String>>((country) {
                          return DropdownMenuItem<String>(
                            value: country['code'], // Use code as value
                            child: Row(
                              children: [
                                // Optional: Add Flag image here if available in country['flagUrl']
                                Text(country['name']),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCountryCode = newValue;
                            _transferServices = []; // Clear previous operators
                          });
                          _loadOperators(); // Load for new country
                        },
                      ),
                    ),
                  ),

                  // Nom du destinataire
                  _buildTextField(
                    'Nom du destinataire',
                    _nameController,
                    'Nom complet',
                    Icons.person,
                  ),
                  SizedBox(height: 15),

                  // Numéro de téléphone
                  _buildTextField('Numéro de téléphone', _phoneController,
                      '${_selectedCallingCode} ...', Icons.phone,
                      keyboardType: TextInputType.phone,
                      suffixIcon: IconButton(
                        icon: Icon(Icons.contacts, color: AppTheme.primaryBlue),
                        onPressed: _pickContact,
                      )),

                  SizedBox(height: 15),

                  // Montant
                  _buildTextField(
                    'Montant (FCFA)',
                    _amountController,
                    '10,000',
                    Icons.monetization_on,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      _calculateFees();
                    },
                  ),

                  // Display converted amount indication if needed (simplified for now)
                  if (_amountController.text.isNotEmpty &&
                      _selectedCurrency.isNotEmpty &&
                      _selectedCurrency != 'XOF')
                    Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          "Le destinataire recevra environ: ... $_selectedCurrency",
                          style: TextStyle(
                              color: AppTheme.primaryBlue, fontSize: 12),
                        ))
                  else if (_selectedCurrency.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          "Devise de réception: $_selectedCurrency",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )),

                  SizedBox(height: 15),

                  // Fee Breakdown
                  if (_amountController.text.isNotEmpty &&
                      _selectedOperator != null)
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          _buildFeeRow("Montant envoyé",
                              "${_amountController.text} FCFA", false),
                          SizedBox(height: 8),
                          _buildFeeRow("Frais",
                              "${_totalFees.toStringAsFixed(0)} FCFA", false),
                          Divider(height: 20),
                          _buildFeeRow("Total à payer",
                              "${_totalAmount.toStringAsFixed(0)} FCFA", true),
                        ],
                      ),
                    ),

                  SizedBox(height: 25),

                  // Bouton d'envoi
                  Container(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_amountController.text.isNotEmpty &&
                            _selectedOperator != null &&
                            _phoneController.text.isNotEmpty) {
                          _showTransferConfirmationDialog();
                        } else {
                          // Show toast or snackbar
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Veuillez remplir tous les champs"),
                              backgroundColor: Colors.red));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'Envoyer l\'argent',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Transferts récents
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transferts récents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Voir tout',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  SizedBox(height: 15),
                  if (_isLoadingHistory)
                    Center(child: CircularProgressIndicator())
                  else if (_recentTransfers.isEmpty)
                    Center(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text('Aucune transaction récente'),
                    ))
                  else
                    ..._recentTransfers
                        .asMap()
                        .entries
                        .map((entry) => _buildTransferItem(
                            entry.value as TransferTransaction, entry.key))
                        .toList(),
                ],
              ),
            ),

            SizedBox(height: 100), // Espace pour la navigation
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String hint, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      Widget? suffixIcon,
      Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.grey.shade500),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferItem(TransferTransaction item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.status == TransferStatus.completed
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.status == TransferStatus.completed
                  ? Icons.check
                  : Icons.access_time,
              color: item.status == TransferStatus.completed
                  ? Colors.green
                  : Colors.orange,
              size: 20,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.recipientName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year} • ${item.method.toString().split('.').last}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${item.amount.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                item.status == TransferStatus.completed ? 'Succès' : 'En cours',
                style: TextStyle(
                  fontSize: 12,
                  color: item.status == TransferStatus.completed
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionModal(BuildContext context, String initialOperation) {
    String selectedOperation = initialOperation;
    // Ensure we have operators; if so, default to the first one, else empty string
    String selectedOperatorName = _transferServices.isNotEmpty
        ? (_transferServices[0]['name'] as String)
        : '';
    final TextEditingController amountCtrl = TextEditingController();
    final TextEditingController phoneCtrl =
        TextEditingController(); // Added for phone input
    bool isLoading = false; // Local loading state for the modal
    String? errorMessage;

    if (_currentUser?.phone != null) {
      phoneCtrl.text = _currentUser!.phone!;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Opération',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  _buildDropdownField(
                    'Type d\'opération',
                    selectedOperation,
                    ['Recharger', 'Retirer'],
                    (value) {
                      setModalState(() {
                        selectedOperation = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  if (_transferServices.isNotEmpty)
                    _buildDropdownField(
                      'Opérateur',
                      selectedOperatorName,
                      _transferServices
                          .map((e) => e['name'] as String)
                          .toSet() // Ensure uniqueness if needed
                          .toList(),
                      (value) {
                        setModalState(() {
                          selectedOperatorName = value!;
                        });
                      },
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text('Aucun opérateur disponible'),
                    ),
                  SizedBox(height: 20),
                  _buildTextField(
                    'Numéro de téléphone',
                    phoneCtrl,
                    '77 000 00 00',
                    Icons.phone,
                  ),
                  SizedBox(height: 20),
                  _buildTextField(
                    'Montant (FCFA)',
                    amountCtrl,
                    '0',
                    Icons.attach_money,
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                              if (amountCtrl.text.isEmpty ||
                                  phoneCtrl.text.isEmpty ||
                                  selectedOperatorName.isEmpty) {
                                setModalState(() {
                                  errorMessage =
                                      'Veuillez remplir tous les champs';
                                });
                                return;
                              }

                              setModalState(() {
                                isLoading = true;
                                errorMessage = null;
                              });

                              try {
                                final operator = _transferServices.firstWhere(
                                    (op) => op['name'] == selectedOperatorName);
                                final amount = double.parse(amountCtrl.text);

                                if (selectedOperation == 'Recharger') {
                                  await _transferService.deposit(
                                    operatorId: operator['id'],
                                    amount: amount,
                                    phone: phoneCtrl.text,
                                    userId: _currentUser!.id,
                                  );
                                } else {
                                  await _transferService.withdraw(
                                    operatorId: operator['id'],
                                    amount: amount,
                                    phone: phoneCtrl.text,
                                    userId: _currentUser!.id,
                                  );
                                }

                                if (context.mounted) {
                                  Navigator.pop(context); // Close modal
                                  _loadUser(
                                      forceRefresh:
                                          true); // Refresh Balance & History
                                  _showSuccessDialog();
                                }
                              } catch (e) {
                                setModalState(() {
                                  errorMessage = 'Erreur: ${e.toString()}';
                                });
                              } finally {
                                if (context.mounted) {
                                  setModalState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Valider',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 20),
              Text(
                'Opération réussie !',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Votre opération a été effectuée avec succès.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue),
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _calculateFees() {
    if (_amountController.text.isEmpty || _selectedOperator == null) {
      setState(() {
        _operatorFeeAmount = 0.0;
        _totalFees = 0.0;
        _totalAmount = 0.0;
      });
      return;
    }

    double amount =
        double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;

    // Determine bounds
    bool isIntl = _currentCountryCode != _selectedCountryCode;

    // Get percentages (default to 0 if null)
    double opFeePercent =
        (_selectedOperator['operatorFee'] as num?)?.toDouble() ?? 0.0;
    double troovFeeNatPercent =
        (_selectedOperator['troovFeeNational'] as num?)?.toDouble() ?? 0.0;
    double troovFeeIntlPercent =
        (_selectedOperator['troovFeeInternational'] as num?)?.toDouble() ?? 0.0;

    double troovPercent = isIntl ? troovFeeIntlPercent : troovFeeNatPercent;

    setState(() {
      _operatorFeeAmount = amount * (opFeePercent / 100);
      double troovFeeAmount = amount * (troovPercent / 100);
      _totalFees = _operatorFeeAmount + troovFeeAmount;
      _totalAmount = amount + _totalFees;
    });
  }

  void _showTransferConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Confirmer le transfert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFeeRow(
                  "Montant envoyé", "${_amountController.text} FCFA", false),
              SizedBox(height: 10),
              _buildFeeRow(
                  "Frais", "${_totalFees.toStringAsFixed(0)} FCFA", false),
              Divider(),
              _buildFeeRow("Total à payer",
                  "${_totalAmount.toStringAsFixed(0)} FCFA", true),
              SizedBox(height: 10),
              if (_selectedCurrency.isNotEmpty && _selectedCurrency != 'XOF')
                Text(
                  "Le destinataire recevra environ: ... $_selectedCurrency",
                  style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _initiateTransfer();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue),
              child: Text('Confirmer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initiateTransfer() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      double amount = double.parse(_amountController.text.replaceAll(',', ''));
      await _transferService.initiateTransfer(
        destinationCountry: _selectedCountryCode!, // Ensure not null
        recipientPhone: _phoneController.text,
        recipientName: _nameController.text,
        amount: amount,
        serviceSlug: _selectedOperator['slug'] ?? 'unknown', // Pass slug
        userId: _currentUser!.id,
        senderId: _currentUser!.id,
        method: TransferMethod.mobile_money,
      );

      Navigator.pop(context); // Close loading
      _loadUser(forceRefresh: true); // Refresh Balance & History
      _showSuccessDialog();

      // Clear fields
      setState(() {
        _amountController.clear();
        _phoneController.clear();
        _nameController.clear();
        _calculateFees();
      });
    } catch (e) {
      Navigator.pop(context); // Close loading
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Erreur"),
          content: Text(e.toString()),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("OK"))
          ],
        ),
      );
    }
  }

  Widget _buildFeeRow(String label, String value, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black87 : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
            color: isTotal ? AppTheme.primaryBlue : Colors.black87,
          ),
        ),
      ],
    );
  }
}
