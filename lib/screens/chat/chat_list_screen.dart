import 'package:flutter/material.dart';
import '../../utils/localization.dart';
import '../../utils/theme.dart';
import '../../models/message.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/conversation_tile.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with TickerProviderStateMixin {
  final _chatService = ChatService();
  final _authService = AuthService();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadCurrentUser();
    _loadConversations();
    _startAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUserId = user?.id;
    });
  }

  Future<void> _loadConversations() async {
    try {
      final conversations = await _chatService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de chargement: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshConversations() async {
    await _loadConversations();
  }

  void _openChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversation: conversation,
          currentUserId: _currentUserId!,
        ),
      ),
    ).then((_) {
      // Rafraîchir les conversations au retour
      _refreshConversations();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Messages'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche de conversations
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildBody(),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryBlue,
        ),
      );
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshConversations,
      color: AppTheme.primaryBlue,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ConversationTile(
            conversation: conversation,
            currentUserId: _currentUserId!,
            onTap: () => _openChat(conversation),
            onLongPress: () => _showConversationOptions(conversation),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: AppTheme.primaryBlue.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Aucune conversation',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Vos conversations avec les prestataires\napparaîtront ici',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Retourner à l'écran de recherche
              Navigator.pop(context);
            },
            icon: Icon(Icons.search, color: Colors.white),
            label: Text(
              'Rechercher des services',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConversationOptions(Conversation conversation) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    backgroundImage: conversation.getConversationAvatar(_currentUserId!) != null
                        ? NetworkImage(conversation.getConversationAvatar(_currentUserId!)!)
                        : null,
                    child: conversation.getConversationAvatar(_currentUserId!) == null
                        ? Text(
                            conversation.getConversationTitle(_currentUserId!)[0].toUpperCase(),
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      conversation.getConversationTitle(_currentUserId!),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.mark_chat_read, color: AppTheme.primaryBlue),
                title: Text('Marquer comme lu'),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(conversation);
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_off, color: Colors.orange),
                title: Text('Désactiver les notifications'),
                onTap: () {
                  Navigator.pop(context);
                  _muteConversation(conversation);
                },
              ),
              ListTile(
                leading: Icon(Icons.archive, color: Colors.grey),
                title: Text('Archiver'),
                onTap: () {
                  Navigator.pop(context);
                  _archiveConversation(conversation);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConversation(conversation);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markAsRead(Conversation conversation) async {
    try {
      await _chatService.markConversationAsRead(conversation.id);
      _refreshConversations();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _muteConversation(Conversation conversation) async {
    try {
      await _chatService.muteConversation(conversation.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifications désactivées'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _archiveConversation(Conversation conversation) async {
    try {
      await _chatService.archiveConversation(conversation.id);
      _refreshConversations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conversation archivée'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteConversation(Conversation conversation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la conversation'),
        content: Text('Êtes-vous sûr de vouloir supprimer cette conversation ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _chatService.deleteConversation(conversation.id);
        _refreshConversations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conversation supprimée'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

