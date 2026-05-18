import 'package:flutter/material.dart';
import '../../space/provider_registration_screen.dart';
import 'onboarding_success_screen.dart';

class OnboardingProviderScreen extends StatelessWidget {
  const OnboardingProviderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingSuccessScreen()),
              );
            },
            child: const Text(
              'Passer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ÉTAPE FINALE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Devenez prestataire\nsur Troov !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Proposez vos services, gagnez en visibilité et développez votre activité locale dès aujourd\'hui.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Option 1 Card: Consumer (G-TROOV)
              _buildFormulaCard(
                context: context,
                title: 'G-TROOV (Gratuit)',
                price: '0 FCFA',
                description: 'Profitez de la plateforme pour découvrir les actualités locales, regarder des stories et commander des services.',
                color: Colors.blueGrey,
                bgOpacityColor: Colors.blueGrey.withOpacity(0.04),
                features: [
                  'Consulter les stories & actualités locales',
                  'Acheter des services & produits en ligne',
                  'Publier du contenu dans le feed (max 3/jour)',
                  'Suivre et interagir avec vos prestataires',
                ],
                buttonLabel: 'Continuer comme Consommateur',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingSuccessScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Option 2 Card: Standard Provider (Troov Deel)
              _buildFormulaCard(
                context: context,
                title: 'TROOV DEEL (Standard)',
                price: '2000 FCFA/mois',
                description: 'Commencez à proposer vos services et à publier sur notre fil d\'actualité locale en toute simplicité.',
                color: Colors.blueAccent,
                bgOpacityColor: Colors.blue.withOpacity(0.04),
                features: [
                  'Publications illimitées dans le feed',
                  'Vente de vos produits & services',
                  'Fiche prestataire standard',
                  'Frais de commission (10% - 25%)',
                ],
                buttonLabel: 'Devenir Prestataire Standard',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProviderRegistrationScreen(
                        initialSubscriptionType: 'STANDARD',
                        isFromOnboarding: true,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Option 3 Card: Premium Provider (Troov Business)
              _buildFormulaCard(
                context: context,
                title: 'TROOV BUSINESS (Premium)',
                price: '5000 FCFA/mois',
                isPremium: true,
                description: 'Boostez vos performances locales avec une visibilité prioritaire, des Stories et une commission ultra-réduite.',
                color: Colors.deepPurple,
                bgOpacityColor: Colors.deepPurple.withOpacity(0.04),
                features: [
                  'Visibilité Prioritaire (Tête de liste)',
                  'Publication de Stories & Statuts',
                  'Votre espace boutique personnalisé',
                  'Frais de commission réduits (5% - 15%)',
                  'Badge de vérification exclusif',
                ],
                buttonLabel: 'Devenir Prestataire Premium',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProviderRegistrationScreen(
                        initialSubscriptionType: 'BUSINESS',
                        isFromOnboarding: true,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormulaCard({
    required BuildContext context,
    required String title,
    required String price,
    required String description,
    required Color color,
    required Color bgOpacityColor,
    required List<String> features,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool isPremium = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgOpacityColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPremium ? Colors.deepPurple : Colors.grey.shade200,
          width: isPremium ? 2.5 : 1,
        ),
        boxShadow: [
          if (isPremium)
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isPremium ? Colors.deepPurple.shade900 : Colors.black87,
                        ),
                      ),
                    ),
                    if (isPremium)
                      const Icon(Icons.stars, color: Colors.amber, size: 22),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.deepPurple.shade700 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Column(
                  children: features.map((feat) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isPremium ? Icons.check_circle : Icons.check_circle_outline,
                            size: 16,
                            color: isPremium ? Colors.deepPurple : Colors.blueAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feat,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isPremium)
            Positioned(
              top: 0,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'POPULAIRE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
