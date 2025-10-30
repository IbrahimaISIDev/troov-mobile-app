# Support

## Obtenir de l’aide

- Ouvrez une issue en décrivant:
  - Version de Flutter (`flutter --version`)
  - Plateforme ciblée (Android/iOS/Web/Desktop)
  - Étapes pour reproduire
  - Logs pertinents

## Questions fréquentes (FAQ)

- Problèmes de dépendances: exécutez `flutter pub get` puis `flutter clean && flutter pub get`.
- Échec de build iOS: vérifiez les certificats/provisioning et exécutez `pod install` dans `ios/` sur macOS.
- Assets non trouvés: assurez-vous qu’ils sont listés dans `pubspec.yaml` et que le chemin est correct.
