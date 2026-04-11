import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/provider_service.dart';
import '../../services/auth_service.dart';
import '../../services/post_service.dart';

class ProviderRegistrationScreen extends StatefulWidget {
  const ProviderRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<ProviderRegistrationScreen> createState() =>
      _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState
    extends State<ProviderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agencyNameController = TextEditingController();
  final _professionController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  File? _logoFile;
  bool _isLoading = false;

  final ProviderService _providerService = ProviderService();
  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoFile = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = await AuthService().getCurrentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
      setState(() => _isLoading = false);
      return;
    }

    String? logoUrl;
    if (_logoFile != null) {
      try {
        logoUrl = await _postService.uploadImage(_logoFile!);
      } catch (e) {
        print('Error uploading logo: $e');
        // Continue even if logo fails, or handle as error
      }
    }

    final providerData = {
      'agencyName': _agencyNameController.text.trim(),
      'profession': _professionController.text.trim(),
      'logoUrl': logoUrl,
      'bio': _bioController.text.trim(),
      'address': _addressController.text.trim(),
      'status': 'AVAILABLE',
      'rating': 0.0,
      'reviewCount': 0,
      'totalMissions': 0,
    };

    try {
      final result =
          await _providerService.createProvider(user.id, providerData);
      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil prestataire créé avec succès !')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        throw Exception('Erreur lors de la création');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Devenir Prestataire',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Créez votre profil professionnel pour commencer à vendre vos services sur Troov.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          image: _logoFile != null
                              ? DecorationImage(
                                  image: FileImage(_logoFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: _logoFile == null
                            ? const Icon(Icons.add_a_photo_rounded,
                                color: Colors.blueAccent, size: 30)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Logo de votre agence',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                label: "Nom de l'agence / Nom commercial",
                hint: "Ex: Ma Coiffure Bio",
                controller: _agencyNameController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: "Profession / Métier",
                hint: "Ex: Coiffeuse, Plombier, Développeur",
                controller: _professionController,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: "Biographie / Description",
                hint: "Parlez-nous de votre expertise...",
                controller: _bioController,
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: "Adresse professionnelle",
                hint: "Ex: Dakar, Sénégal",
                controller: _addressController,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Créer mon profil',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }
}
