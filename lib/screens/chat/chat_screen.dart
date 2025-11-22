import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import './chat_list_component.dart';
import './call_list_component.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header avec recherche
          _buildChatHeader(),
          
          // Tabs
          _buildTabBar(),
          const SizedBox(height: 5),

          // Contenu des tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                ChatListComponent(),
                CallListComponent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Troov Chat',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showSearchDialog(),
            icon: const Icon(Icons.search, color: AppTheme.primaryBlue),
          ),
          IconButton(
            onPressed: () => _showMoreOptions(),
            icon: const Icon(Icons.more_vert, color: AppTheme.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: AppTheme.primaryBlue,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'Discussions'),
          Tab(text: 'Appels'),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechercher'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Rechercher un contact...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Implémentation de la recherche
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers les paramètres
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Aide'),
              onTap: () {
                Navigator.pop(context);
                // Navigation vers l'aide
              },
            ),
          ],
        ),
      ),
    );
  }
}