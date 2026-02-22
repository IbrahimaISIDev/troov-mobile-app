import 'package:flutter/material.dart';

class MyServicesFormScreen extends StatefulWidget {
  const MyServicesFormScreen({Key? key}) : super(key: key);

  @override
  State<MyServicesFormScreen> createState() => _MyServicesFormScreenState();
}

class _MyServicesFormScreenState extends State<MyServicesFormScreen> {
  final _formKey = GlobalKey<FormState>();

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 100), // Espace pour la navigation
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Détails du service'),
                const SizedBox(height: 15),
                _buildTextField(
                    label: 'Titre',
                    hint: 'Ex: Tresses Africaines',
                    icon: Icons.title),
                const SizedBox(height: 15),
                _buildTextField(
                    label: 'Description',
                    hint: 'Décrivez votre prestation...',
                    maxLines: 3,
                    icon: Icons.description),
                const SizedBox(height: 25),
                _buildSectionTitle('Tarification & Durée'),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField(
                            label: 'Prix',
                            hint: '0',
                            suffix: 'FCFA',
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _buildTextField(
                            label: 'Durée',
                            hint: 'Ex: 1h 30',
                            icon: Icons.timer)),
                  ],
                ),
                const SizedBox(height: 25),
                _buildSectionTitle('Média'),
                const SizedBox(height: 15),
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.shade300, style: BorderStyle.solid),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo_outlined,
                          color: Colors.grey, size: 30),
                      SizedBox(height: 8),
                      Text('Ajouter une photo de couverture',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
    required String label,
    String? hint,
    IconData? icon,
    String? suffix,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
          maxLines: maxLines,
          keyboardType: keyboardType,
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
