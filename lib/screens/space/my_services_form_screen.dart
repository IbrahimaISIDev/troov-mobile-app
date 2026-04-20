import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/product_service.dart';
import '../../services/provider_service.dart';
import '../../services/post_service.dart';
import '../../services/category_service.dart';
import '../../models/category_model.dart' as model;

class MyServicesFormScreen extends StatefulWidget {
  const MyServicesFormScreen({Key? key}) : super(key: key);

  @override
  State<MyServicesFormScreen> createState() => _MyServicesFormScreenState();
}

class _MyServicesFormScreenState extends State<MyServicesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final ProviderService _providerService = ProviderService();
  final PostService _postService = PostService();
  final CategoryService _categoryService = CategoryService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;
  List<model.Category> _categories = [];
  model.Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final cats = await _categoryService.getAllCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final provider = await _providerService.getCurrentProvider();
      if (provider == null) {
        throw Exception("Profil prestataire non trouvé. Veuillez d'abord créer votre boutique.");
      }

      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _postService.uploadImage(_imageFile!);
      }

      final productData = {
        'providerId': provider.id,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'categoryName': _selectedCategory?.title ?? provider.profession ?? 'Service',
        'duration': _durationController.text,
        'images': imageUrl != null ? [imageUrl] : [],
        'status': 'ACTIVE',
      };

      await _productService.createProduct(productData);
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service créé avec succès !')),
        );
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouveau Service',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Détails du service'),
                    const SizedBox(height: 15),
                    _buildTextField(
                        controller: _titleController,
                        label: 'Titre',
                        hint: 'Ex: Tresses Africaines',
                        icon: Icons.title,
                        validator: (v) => v!.isEmpty ? 'Veuillez saisir un titre' : null),
                    const SizedBox(height: 15),
                    _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Décrivez votre prestation...',
                        maxLines: 3,
                        icon: Icons.description,
                        validator: (v) => v!.isEmpty ? 'Veuillez saisir une description' : null),
                    const SizedBox(height: 25),
                    _buildSectionTitle('Tarification & Durée'),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                controller: _priceController,
                                label: 'Prix',
                                hint: '0',
                                suffix: 'FCFA',
                                keyboardType: TextInputType.number,
                                validator: (v) => v!.isEmpty ? 'Requis' : null)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                        controller: _durationController,
                        label: 'Durée estimée',
                        hint: 'Ex: 1h 30, 2 jours, etc.',
                        icon: Icons.timer,
                        validator: (v) => v!.isEmpty ? 'Veuillez saisir une durée' : null),
                    const SizedBox(height: 25),
                    _buildSectionTitle('Catégorie du service'),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<model.Category>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      hint: const Text('Choisir une catégorie'),
                      items: _categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.title),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                      validator: (v) => v == null ? 'Veuillez choisir une catégorie' : null,
                    ),
                    const SizedBox(height: 25),
                    _buildSectionTitle('Média'),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade300, style: BorderStyle.solid),
                          image: _imageFile != null 
                              ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: _imageFile == null 
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined,
                                      color: Colors.grey, size: 30),
                                  SizedBox(height: 8),
                                  Text('Ajouter une photo de couverture',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Enregistrer le service',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    String? suffix,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            prefixIcon:
                icon != null ? Icon(icon, color: Colors.grey, size: 20) : null,
            suffixText: suffix,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent),
            ),
          ),
        ),
      ],
    );
  }
}
