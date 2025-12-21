import 'package:flutter/material.dart';

import 'history_detail_screen.dart';
import '../../services/transfer_service.dart';
import '../../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TransferService _transferService = TransferService();
  final AuthService _authService = AuthService();
  List<dynamic> _historyTransfers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final history = await _transferService.getTransactionHistory(user.id);
        setState(() {
          _historyTransfers = history;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Utilisateur non identifié";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur de chargement: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                FilterChip(
                  label: Text('Tous les transferts'),
                  selected: true,
                  onSelected: null,
                ),
                FilterChip(
                  label: Text('Entrants'),
                  selected: false,
                  onSelected: null,
                ),
                FilterChip(
                  label: Text('Sortants'),
                  selected: false,
                  onSelected: null,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _historyTransfers.isEmpty
                        ? Center(child: Text("Aucune transaction"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _historyTransfers.length,
                            itemBuilder: (context, index) {
                              final transfer = _historyTransfers[index];

                              final service =
                                  transfer['service'] ?? 'Transfert';
                              // Fallback logic closely matching backend DTO structure
                              final receiverName = transfer['recipientName'] ??
                                  transfer['senderName'] ??
                                  'Inconnu';
                              final receiverPhone =
                                  transfer['recipientPhone'] ??
                                      transfer['phone'] ??
                                      '';
                              final amountRaw = transfer['amount'].toString();
                              final date = transfer['date'] ?? 'Récemment';
                              final reference = transfer['id'] ?? 'TRX-REF';

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HistoryDetailScreen(
                                        service: service,
                                        receiverName: receiverName,
                                        receiverPhone: receiverPhone,
                                        amount: '$amountRaw FCFA',
                                        date: date.toString(),
                                        reference: reference,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            receiverName.isNotEmpty
                                                ? receiverName[0]
                                                : '?',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              receiverName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              receiverPhone,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              service,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$amountRaw FCFA',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            date.toString().split('T')[0],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
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
    );
  }
}
