import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'order_detail_screen.dart';

class MyServicesManagementScreen extends StatefulWidget {
  const MyServicesManagementScreen({Key? key}) : super(key: key);

  @override
  _MyServicesManagementScreenState createState() =>
      _MyServicesManagementScreenState();
}

class _MyServicesManagementScreenState extends State<MyServicesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Services',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(text: 'Commandes'),
            Tab(text: 'Mes Services'),
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(),
          _buildServicesList(),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    final orders = [
      {
        'customer': 'Awa Diop',
        'service': 'Coiffure - Tresses',
        'date': '20 Dec, 10:00',
        'status': 'En attente',
        'statusColor': Colors.orange,
      },
      {
        'customer': 'Moussa Ndiaye',
        'service': 'Location Drone',
        'date': '18 Dec, 09:00',
        'status': 'Confirmé',
        'statusColor': Colors.green,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(order: order),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                child: Text((order['customer'] as String)[0],
                    style: TextStyle(color: AppTheme.primaryBlue)),
              ),
              title: Text(order['customer'] as String),
              subtitle: Text('${order['service']} • ${order['date']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (order['statusColor'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order['status'] as String,
                  style: TextStyle(
                    color: order['statusColor'] as Color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesList() {
    final services = [
      {
        'name': 'Coiffure Dame',
        'type': 'Beauté',
        'price': '5,000 F',
        'active': true,
      },
      {
        'name': 'Location Studio',
        'type': 'Immobilier',
        'price': '25,000 F / jour',
        'active': true,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.build_circle_outlined, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        service['type'] as String,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service['price'] as String,
                        style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: service['active'] as bool,
                  onChanged: (val) {},
                  activeColor: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
