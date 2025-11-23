import 'package:flutter/material.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Historique simulé, même structure que _recentTransfers dans TransferScreen
    final List<Map<String, dynamic>> historyTransfers = [
      {
        'name': 'Moussa Diallo',
        'phone': '+221 77 123 45 67',
        'amount': '25,000',
        'date': 'Hier, 14:32',
        'service': 'Orange Money',
      },
      {
        'name': 'Fatou Sarr',
        'phone': '+221 76 987 65 43',
        'amount': '15,500',
        'date': '2 jours',
        'service': 'Wave',
      },
      {
        'name': 'Ibrahima Kane',
        'phone': '+221 78 555 44 33',
        'amount': '50,000',
        'date': '5 jours',
        'service': 'Free Money',
      },
    ];

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
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: historyTransfers.length,
              itemBuilder: (context, index) {
                final transfer = historyTransfers[index];

                final service = transfer['service'] as String;
                final receiverName = transfer['name'] as String;
                final receiverPhone = transfer['phone'] as String;
                final amountRaw = transfer['amount'] as String; // déjà sans " FCFA"
                final date = transfer['date'] as String;
                final reference = 'TRX-${index + 1}2345';

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
                          date: date,
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
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              receiverName.isNotEmpty ? receiverName[0] : '?',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
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
                              date,
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
