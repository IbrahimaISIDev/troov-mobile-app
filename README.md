# Troov

Application Flutter multi-plateforme (Android, iOS, Web, Desktop) pour la mise en relation entre utilisateurs et prestataires de services, avec authentification, réservation, messagerie et paiements.

## Sommaire

- **[Aperçu](#aperçu)**
- **[Fonctionnalités](#fonctionnalités)**
- **[Stack technique](#stack-technique)**
- **[Structure du projet](#structure-du-projet)**
- **[Prérequis](#prérequis)**
- **[Installation](#installation)**
- **[Démarrage](#démarrage)**
- **[Configuration](#configuration)**
- **[Tests](#tests)**
- **[Déploiement](#déploiement)**
- **[Contribuer](#contribuer)**
- **[Support](#support)**

## Aperçu

Troov est un projet Flutter (`name: troov_app`) ciblant plusieurs plateformes. Il prend en charge l’internationalisation (FR/EN/ES), le thème clair/sombre, la persistance des préférences et des services métiers (auth, réservation, chat, paiement).

## Fonctionnalités

- Authentification et enregistrement (`/login`, `/register`).
- Onboarding et accueil (`SplashScreen`, `WelcomeScreen`, `HomeScreen`).
- Réservations, services, prestataires et recherche (`lib/services/*`, `lib/models/*`).
- Messagerie (conversations) et paiements.
- Thème clair/sombre persisté (SharedPreferences).
- Internationalisation FR/EN/ES (`lib/utils/localization.dart`).

## Stack technique

- Flutter SDK >= 3.4.3, Dart >= 3.4
- Dépendances principales (extrait `pubspec.yaml`):
  - `shared_preferences`
  - `flutter_localizations` + `intl`
  - `http`
- Organisation par couches: `models`, `services`, `screens`, `widgets`, `utils`.

## Structure du projet

```
.
├─ lib/
│  ├─ main.dart
│  ├─ models/                 # Entités: user, service, booking, etc.
│  ├─ services/               # Accès API et logique métier (auth, booking...)
│  ├─ screens/                # UI et navigation (splash, welcome, home...)
│  ├─ widgets/                # Composants réutilisables
│  └─ utils/                  # Thème, i18n
├─ assets/images/             # Ressources images
├─ test/                      # Tests unitaires
├─ android/, ios/, web/, ...  # Cibles plateformes
└─ pubspec.yaml               # Dépendances et assets
```

## Prérequis

- Flutter SDK et outils de plateforme installés.
- Android Studio / Xcode configurés pour l’émulation.
- Optionnel: navigateurs pour le Web, toolchains desktop.

## Installation

```bash
flutter pub get
```

Si vous modifiez des assets, vérifiez la section `assets` dans `pubspec.yaml` puis exécutez `flutter pub get`.

## Démarrage

Exécuter sur l’appareil/émulateur souhaité:

```bash
# Android
flutter run -d android

# iOS (sur macOS)
flutter run -d ios

# Web
flutter run -d chrome

# Desktop (si activé)
flutter run -d linux
```

Routes principales (voir `lib/main.dart`):

- `/welcome`, `/login`, `/register`, `/home`
- `home: SplashScreen()` comme point d’entrée UI

Thème et langue peuvent être changés depuis `HomeScreen` et sont persistés via `SharedPreferences` (`isDarkMode`, `languageCode`).

## Configuration

- Internationalisation: support FR/EN/ES via `AppLocalizations` et `intl`.
- Langue persistée par la clé `languageCode`.
- Thème: clair/sombre via `AppTheme` (`lib/utils/theme.dart`).
- Stockage local: `SharedPreferences` pour les préférences utilisateur.
- Réseau/API: `http`. Renseignez vos endpoints dans la couche `services/`.

Variables sensibles: utilisez des solutions sécurisées (chiffrement local, Remote Config, ou build-time) — évitez de committer des secrets.

## Tests

```bash
flutter test
```

Ajoutez vos tests dans `test/`.

## Déploiement

- Android: `flutter build apk` ou `flutter build appbundle`
- iOS: `flutter build ios` (signature requise)
- Web: `flutter build web`
- Desktop: `flutter build linux`

Reportez-vous à la documentation Flutter pour la signature, la configuration des stores et l’hébergement Web.

## Contribuer

Consultez `CONTRIBUTING.md` et `CODE_OF_CONDUCT.md`.

## Support

Consultez `SUPPORT.md`.
