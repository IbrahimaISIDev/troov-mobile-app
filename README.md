# Troov — Application Mobile Flutter

Application mobile communautaire et marketplace développée en Flutter, ciblant Android et iOS. Elle permet aux utilisateurs de publier du contenu (photos/vidéos), d'effectuer des transferts d'argent, de découvrir des prestataires de services et de gérer leur espace personnel.

---

## Fonctionnalités principales

### Authentification & Sécurité
- Inscription / Connexion par email ou numéro de téléphone
- Vérification OTP (email et SMS)
- Réinitialisation de mot de passe
- Verrouillage applicatif par code secret + biométrie (`local_auth`)
- Onboarding interactif post-inscription (catégories, prestataire, source)

### Onglet Home
- Stories (statuts texte, image, vidéo)
- Flux de produits et annonces publicitaires
- Section messages rapides
- Création de statuts médias / texte

### Onglet Troov (Feed social)
- Publications images et vidéos depuis le backend
- Likes, commentaires et vues en temps réel
- Profil des propriétaires de publications
- Lecture vidéo optimisée avec cache (`GlobalVideoCache`)

### Onglet Transfert
- Transfert simple, multiple et amélioré
- Historique des transactions
- Écran de paiement

### Onglet Services
- Découverte de prestataires par catégorie
- Liste et fiche détaillée des prestataires
- Portfolios prestataires

### My Space (Espace personnel)
- Tableau de bord utilisateur avec statistiques
- Gestion des publications (publier, suivre)
- Boutique personnelle (produits)
- Ventes et achats avec détail des commandes
- Gestion des services proposés (création, édition)
- Inscription comme prestataire
- Paramètres de l'espace

### Autres
- Messagerie instantanée (chat + appels)
- Notifications
- Historique des activités
- Paramètres complets (profil, sécurité, confidentialité, stockage, aide)
- Mode sombre / clair
- Multilingue : français, anglais, espagnol

---

## Architecture

Pattern en couches sans framework de state management formel.

```
lib/
├── main.dart                  # Point d'entrée, routes, thème, langue
├── screens/                   # 62 écrans organisés par domaine
│   ├── auth/                  # Authentification (14 écrans)
│   ├── home/                  # Accueil + composants
│   ├── troov/                 # Feed publications
│   ├── transfert/             # Transferts / paiements
│   ├── services/              # Marketplace services
│   ├── space/                 # Espace personnel (13 écrans)
│   ├── chat/                  # Messagerie & appels
│   ├── history/               # Historique
│   ├── notifications/         # Notifications
│   └── settings/              # Paramètres
├── services/                  # 17 services (HTTP REST + WebSocket)
├── models/                    # 15 modèles de données (fromJson/toJson)
├── widgets/                   # Widgets réutilisables (modal commentaires, vidéo, etc.)
├── utils/                     # Thème, localisation, config, responsive
└── data/                      # Mock database (données de fallback)
```

| Couche | Technologie |
|--------|-------------|
| UI | `StatefulWidget` / `StatelessWidget` + `setState` |
| Services | `http` (REST) + `stomp_dart_client` (WebSocket) |
| Modèles | POJOs Dart `fromJson` / `toJson` |
| Persistance locale | `SharedPreferences` |
| Navigation | `MaterialApp.routes` + `Navigator.push` |

---

## Stack technique

| Package | Rôle |
|---------|------|
| `flutter_localizations` / `intl` | Support multilingue (fr / en / es) |
| `http` | Requêtes REST |
| `stomp_dart_client` | WebSocket STOMP (feed temps réel) |
| `video_player` | Lecture vidéo |
| `cached_network_image` | Cache images réseau |
| `visibility_detector` | Détection visibilité (likes/vues automatiques) |
| `shared_preferences` | Stockage local (token, config, préférences) |
| `local_auth` | Biométrie / code PIN |
| `image_picker` | Sélection image / vidéo depuis la galerie |
| `geolocator` | Géolocalisation |
| `flutter_contacts` | Accès aux contacts |
| `share_plus` | Partage de contenu natif |
| `intl_phone_field` | Champ téléphone avec indicatif pays |

---

## Prérequis

- Flutter SDK `>=3.4.3 <4.0.0`
- Dart SDK compatible
- Android SDK (API 21+) ou Xcode pour iOS
- Un backend Troov accessible (REST + WebSocket STOMP sur le port `8081`)

---

## Installation

```bash
git clone <repo-url>
cd troov-mobile-app
flutter pub get
```

---

## Lancer l'application

### Mode simple

```bash
flutter run
```

### Avec détection automatique de l'IP locale (développement)

```bash
./run_dev.sh
# ou avec une IP spécifique :
./run_dev.sh 192.168.1.100
```

Ce script détecte automatiquement votre adresse IP locale et configure l'URL du backend via `--dart-define`.

---

## Configuration du backend

L'URL du serveur est configurable dynamiquement **sans recompiler l'APK** via l'écran **Paramètres → Configuration du serveur**.

| Environnement | URL par défaut |
|--------------|----------------|
| Production | `https://troov-backend.onrender.com/api` |
| Développement local | `http://192.168.1.69:8081/api` |

```dart
// Récupérer l'URL active
String url = ConfigService.getBaseUrl();

// Changer l'URL (persiste dans SharedPreferences)
await ConfigService.saveBaseUrl('http://192.168.1.70:8081/api');

// Revenir à la valeur par défaut
await ConfigService.resetToDefault();
```

Format attendu : `http(s)://<host>:<port>/api`

---

## Endpoints backend principaux

| Domaine | Exemples d'endpoints |
|---------|----------------------|
| Auth | `POST /auth/login`, `POST /auth/register`, `POST /auth/verify-otp`, `PATCH /auth/reset-password` |
| Feed / Posts | `GET /posts`, `POST /posts/$id/like`, `POST /posts/$id/view`, `GET /posts/$id/comments` |
| Produits | `GET /products`, `GET /products/category/$id`, `GET /products/provider/$id` |
| Services | `GET /categories`, `GET /providers`, `GET /providers/$id` |
| Portfolios | `GET /portfolios/provider/$id` |
| Stories | `GET /v1/statuses`, `POST /v1/statuses/$id/view` |
| WebSocket | `ws://<host>:8081/ws-troov` (protocole STOMP) |

---

## Assets

```
assets/
├── images/   # Logo, icônes, images de stock, logos de paiement
└── videos/   # Vidéos de démonstration
```

---

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Tests

Le dossier `test/` est présent mais les tests ne sont pas encore implémentés.

```bash
flutter test
```
