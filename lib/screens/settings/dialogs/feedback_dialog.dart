import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../utils/theme.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({Key? key}) : super(key: key);

  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _commentController = TextEditingController();
  final _authService = AuthService();
  int _rating = 0;
  bool _isLoading = false;
  String _type = 'general'; // general, bug, suggestion

  final List<Map<String, dynamic>> _types = [
    {'value': 'general', 'label': 'Avis général', 'icon': Icons.star},
    {'value': 'bug', 'label': 'Signalement de bug', 'icon': Icons.bug_report},
    {'value': 'suggestion', 'label': 'Suggestion', 'icon': Icons.lightbulb},
  ];

  Future<void> _submit() async {
    if (_rating == 0 && _type == 'general') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez donner une note')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.submitFeedback(
        _type == 'bug' ? 'Bug Report' : 'User Feedback',
        _rating,
        _type,
        _commentController.text,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre retour !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Votre avis nous intéresse'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quel est l\'objet de votre retour ?',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: _types.map((type) {
                final isSelected = _type == type['value'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type['icon'],
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey),
                      const SizedBox(width: 5),
                      Text(type['label']),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _type = type['value']);
                  },
                  selectedColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (_type == 'general') ...[
              const Text('Notez votre expérience :',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setState(() => _rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Votre commentaire (optionnel)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style:
              ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Envoyer', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
