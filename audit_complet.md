# Audit Complet — Troov Mobile App

> Date : 2026-05-15
> Projet : `troov` (Flutter)
> Branche : `main`

---

## 1. Structure des dossiers

```
/home/dev/troov-mobile-app/
├── android/               # Configurations Android (Gradle, AndroidManifest.xml)
├── ios/                   # Configurations iOS (Xcode project)
├── linux/                 # Support Linux
├── macos/                 # Support macOS
├── windows/               # Support Windows
├── web/                   # Support web
├── assets/
│   ├── images/            # ~25 images (logos, icônes, stock photos, paiements)
│   └── videos/            # 3 vidéos de démonstration
├── test/                  # Vide (aucun test)
├── lib/
│   ├── main.dart
│   ├── screens/           # 62 fichiers d'écrans
│   │   ├── auth/          # 14 écrans d'authentification
│   │   ├── home/          # Accueil + composants
│   │   ├── services/      # Tab Services prestataires
│   │   ├── troov/         # Tab Troov (publications)
│   │   ├── space/         # 13 écrans My Space
│   │   ├── chat/          # Messagerie + appels
│   │   ├── transfert/     # Transferts / paiements
│   │   ├── history/       # Historique
│   │   ├── settings/      # Paramètres + sous-écrans
│   │   └── notifications/
│   ├── services/          # 17 services API
│   ├── models/            # 15 modèles de données
│   ├── widgets/           # 5 widgets personnalisés
│   ├── utils/             # 4 fichiers utilitaires
│   └── data/              # Mock database
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── CONFIGURATION.md
└── README.md
```

---

## 2. Architecture

**Pattern : Architecture en couches sans framework de state management formel**

| Couche | Technologie | Rôle |
|--------|------------|------|
| Présentation | `StatefulWidget` / `StatelessWidget` | UI par écran |
| Service | Classes Dart + `http` | Appels REST + WebSocket |
| Modèle | POJOs `fromJson` / `toJson` | Structures de données |
| Stockage | `SharedPreferences` | Tokens, config, préférences |
| Navigation | `MaterialApp.routes` + `Navigator` | Routing déclaratif + impératif |

**Injection de dépendances** : manuelle (instanciation directe dans les écrans).

**État application** : local à chaque écran (`setState`), aucun state management global.

---

## 3. Dépendances (pubspec.yaml)

| Package | Version | Rôle |
|---------|---------|------|
| `cupertino_icons` | ^1.0.2 | Icônes iOS-style |
| `shared_preferences` | ^2.2.2 | Stockage local clé-valeur |
| `flutter_localizations` | SDK | Support multilingue |
| `intl` | ^0.19.0 | Internationalisation (dates, nombres) |
| `stomp_dart_client` | ^3.0.0 | WebSocket STOMP (feed temps réel) |
| `visibility_detector` | ^0.4.0+2 | Détection visibilité widget (likes/vues auto) |
| `http` | ^1.1.0 | Requêtes HTTP REST |
| `video_player` | ^2.8.1 | Lecture vidéo |
| `local_auth` | ^2.1.8 | Authentification biométrique / PIN |
| `flutter_contacts` | ^1.1.9+2 | Accès aux contacts |
| `geolocator` | ^14.0.2 | Géolocalisation |
| `share_plus` | ^12.0.1 | Partage de contenu |
| `cached_network_image` | ^3.4.1 | Cache images réseau |
| `intl_phone_field` | ^3.2.0 | Input téléphone formaté |
| `image_picker` | ^1.2.1 | Sélection images / vidéos |

**Dev dependencies** : `flutter_test`, `flutter_lints`, `flutter_launcher_icons`

---

## 4. Écrans / Pages

### Flow Authentification (14 écrans)

| Fichier | Rôle |
|---------|------|
| `splash_screen.dart` | Démarrage app |
| `welcome_screen.dart` | Accueil / bienvenue |
| `login_screen.dart` | Connexion email ou téléphone |
| `register_screen.dart` | Inscription |
| `otp_code_screen.dart` | Vérification OTP inscription |
| `email_verification_screen.dart` | Vérification email |
| `forgot_password_input_screen.dart` | Demande reset password |
| `forgot_password_otp_screen.dart` | OTP reset password |
| `forgot_password_screen.dart` | Nouveau password |
| `reset_password_screen.dart` | Réinitialisation |
| `reset_password_success_screen.dart` | Confirmation reset |
| `profile_setup_screen.dart` | Configuration profil post-inscription |
| `preferences_screen.dart` | Préférences utilisateur |
| `subscription_screen.dart` | Souscription / abonnement |
| `onboarding/` (3 fichiers) | Onboarding interactif |
| `app_lock_screen.dart` | Verrouillage par code secret + biométrie |

### Navigation Principale — 5 onglets (PageView)

#### Onglet 1 — Home
- `home_tab_screen.dart`
- `create_text_status_screen.dart` — Créer status texte
- `create_media_status_screen.dart` — Créer status image/vidéo
- `story_view_screen.dart` — Visualiser stories
- Composants : `home_tab_header.dart`, `main_image_section.dart`, `ads_section.dart`, `product_section.dart`, `messages_section.dart`

#### Onglet 2 — Transfert
- `transfer_screen.dart`, `enhanced_transfer_screen.dart`, `multiple_transfer_screen.dart`
- `payment_screen.dart`, `history_screen.dart`

#### Onglet 3 — Troov (Publications)
- `troov_screen.dart`, `owner_profile_screen.dart`

#### Onglet 4 — Services
- `services_screen.dart`
- Composants : `service_header.dart`, `service_categories.dart`, `popular_services.dart`
- `service_provider_list.dart`, `service_provider_detail.dart`

#### Onglet 5 — My Space (13 écrans)
- `my_space_screen.dart`
- `publish_troov_screen.dart`, `stats_screen.dart`, `my_shop_screen.dart`
- `my_sales_screen.dart`, `my_purchases_screen.dart`, `my_publications_screen.dart`
- `my_services_screen.dart`, `my_services_management_screen.dart`, `my_services_form_screen.dart`
- `provider_registration_screen.dart`
- `order_detail_screen.dart`, `purchase_detail_screen.dart`, `space_settings_screen.dart`

#### Écrans secondaires
- **Chat** : `chat_screen.dart`, `chat_list_component.dart`, `chat_detail_screen.dart`, `call_screen.dart`, `call_list_component.dart`
- **History** : `history_screen.dart`, `history_detail_screen.dart`
- **Notifications** : `notifications_screen.dart`
- **Settings** : `settings_screen.dart`, `server_config_screen.dart`, `profile_edit_screen.dart`, `security_settings_screen.dart`, `privacy_settings_screen.dart`, `notification_settings_screen.dart`, `storage_settings_screen.dart`, `help_center_screen.dart`, `about_screen.dart`

---

## 5. Services / API

### Services HTTP (17 fichiers)

| Service | Endpoints principaux |
|---------|---------------------|
| `AuthService` | `/auth/login`, `/auth/register`, `/auth/logout`, `/auth/verify-otp`, `/auth/forgot-password`, `/auth/phone/verify-code`, `/auth/reset-password`, `/auth/verify-secret-code` |
| `PostService` | `/posts`, `/posts/user`, `/posts/$id/like`, `/posts/$id/view`, `/posts/$id/comments` |
| `ProductService` | `/products`, `/products/$id`, `/products/category/$id`, `/products/provider/$id` |
| `ServiceHubService` | `/categories`, `/posts?size=20`, `/posts/$id/like`, `/posts/$id/view` |
| `ProviderService` | `/providers`, `/providers/user/$id`, `/providers/$id` |
| `PortfolioService` | `/portfolios/provider/$id` |
| `CategoryService` | `/categories`, `/categories/$id` |
| `StoryService` | `/v1/statuses`, `/v1/statuses/me`, `/v1/statuses/$id/view` |
| `FeedService` | `/posts?page=X&size=Y`, `/posts/$id/like`, `/posts/$id/view` |
| `FeedbackService` | `/feedbacks` (POST avec query params) |
| `TransferService` | **Entièrement mockée — pas d'API réelle** |
| `WebSocketService` | `ws://server:8081/ws-troov` (STOMP) |
| `GlobalVideoCache` | Cache vidéo local |
| `ConfigService` | Gestion URL serveur dynamique (SharedPreferences) |

### Configuration serveur dynamique

```dart
// lib/utils/config.dart
static String _baseUrl = 'https://troov-backend.onrender.com/api'; // Production par défaut
static const String defaultBaseUrl = 'http://192.168.1.69:8081/api'; // Dev local
```

URL changeable via `ServerConfigScreen` sans recompiler l'app.

### Tous les endpoints identifiés

**Authentication**
- `POST /auth/login`
- `POST /auth/register` (multipart)
- `POST /auth/logout`
- `POST /auth/register/send-otp`
- `POST /auth/register/verify-otp`
- `POST /auth/forgot-password`
- `POST /auth/verify-otp`
- `PATCH /auth/reset-password`
- `POST /auth/phone/send-code`
- `POST /auth/phone/verify-code`
- `POST /auth/verify-identity` (multipart images)
- `POST /auth/verify-secret-code`

**Posts / Feed**
- `GET /posts?page=X&size=Y`
- `GET /posts/user`
- `GET /posts/user/$userId`
- `POST /posts`
- `POST /posts/$id/like`
- `POST /posts/$id/view`
- `POST /posts/$id/share`
- `GET /posts/$id/comments`
- `POST /posts/$id/comments`

**Produits / Services**
- `GET /products`
- `GET /products/$id`
- `GET /products/category/$id`
- `GET /products/provider/$id`
- `POST /products`
- `PUT /products/$id`
- `DELETE /products/$id`

**Utilisateur**
- `GET /users/me`
- `PATCH /users/me`
- `PATCH /users/me/password`
- `PATCH /users/me/secret-code`

**Prestataires**
- `GET /providers`
- `GET /providers/user/$id`
- `POST /providers/user/$id`
- `PUT /providers/$id`
- `GET /portfolios/provider/$id`
- `POST /portfolios/provider/$id`

**Stories / Status**
- `GET /v1/statuses`
- `GET /v1/statuses/me`
- `POST /v1/statuses` (multipart)
- `POST /v1/statuses/$id/view`

**Divers**
- `GET /categories`
- `POST /uploads` (multipart)
- `POST /feedbacks`

### WebSocket (STOMP)

| Topic | Événement |
|-------|-----------|
| `/topic/feed` | Nouveau post en temps réel |
| `/topic/post/$id/likes` | Likes en direct |
| `/topic/post/$id/comments` | Commentaires en direct |
| `/topic/post/$id/views` | Vues en direct |
| `/topic/post/$id/comment-count` | Compteur commentaires |
| `/topic/post/$id/comment-likes` | Likes sur commentaires |

---

## 6. Modèles de données

| Modèle | Fichier | Champs clés |
|--------|---------|------------|
| `User` | `user.dart` | id, email, phone, firstName, lastName, profileImage, role, isVerified, location, pseudo, preferences |
| `Post` | `post_model.dart` | id, description, mediaUrl, category, likeCount, commentCount, viewCount, isLiked, author |
| `Comment` | `post_model.dart` | id, content, likeCount, isLiked, author |
| `Author` | `post_model.dart` | id, firstName, lastName, profileImage |
| `Product` | `product.dart` | id, title, description, price, category, videoUrl, images, likeCount, isLiked, provider |
| `ProviderProfile` | `provider_model.dart` | id, user, agencyName, specialties, rating, distance, reviewCount, totalMissions, isVerified |
| `Story` | `story_model.dart` | id, authorId, mediaUrl, textContent, type, expiresAt, views, isRead |
| `Category` | `category_model.dart` | id, title, description, color, commissionPercentage, totalProducts |
| `TransferTransaction` | `transfer_model.dart` | id, senderId, recipientPhone, amount, fees, method, status, referenceNumber |
| `UserLocation` | `user.dart` | latitude, longitude, address, city, country |

**Enums principaux**
- `UserRole` : client, provider, admin, dev
- `ServiceCategory` : cleaning, repair, delivery, cooking, health, beauty, education, transport, gardening, technology
- `StoryType` : image, video, text, audio
- `TransferStatus` : pending, processing, completed, failed, cancelled
- `TransferMethod` : bank_account, mobile_money, wallet, cash_pickup
- `ProviderStatus` : AVAILABLE, BUSY, OFFLINE, VACATION

---

## 7. Widgets personnalisés

| Widget | Fichier | Rôle |
|--------|---------|------|
| `VideoFeedItem` | `widgets/video_feed_item.dart` | Affiche post/produit vidéo ou image, gère likes/commentaires/partage, pause/play |
| `CommentsModal` | `widgets/comments_modal.dart` | Modal liste + ajout commentaires |
| `QuantitySelector` | `widgets/quantity_selector.dart` | Sélecteur quantité (−/+) |
| `ServiceOptionSelector` | `widgets/service_option_selector.dart` | Sélecteur options service |
| `StoryStatusAvatar` | `widgets/story_status_avatar.dart` | Avatar avec anneau story |

---

## 8. Navigation

- `MaterialApp.routes` pour les routes nommées principales (`/welcome`, `/login`, `/register`, `/home`, `/server-config`)
- `PageView` pour les 5 onglets avec `animateToPage`
- `Navigator.push` / `pop` pour détails et sous-écrans
- `pushAndRemoveUntil` pour logout (nettoyage de la pile)
- `GlobalKey<NavigatorState>` pour navigation depuis `AppLifecycleState`

---

## 9. Authentification

**Type** : JWT Bearer Token

| Mécanisme | Endpoint |
|-----------|----------|
| Email + password | `POST /auth/login` |
| Téléphone + OTP | `POST /auth/phone/verify-code` |
| Mot de passe oublié | `/auth/forgot-password` → OTP → `/auth/reset-password` |
| Code secret app lock | Vérifié via `/auth/verify-secret-code` |
| Biométrie | `local_auth` (empreinte / face ID) |
| Vérification identité | `POST /auth/verify-identity` (multipart) |

**Stockage** : `SharedPreferences` — clé `auth_token` pour le JWT, `user_data` pour le profil en cache.

---

## 10. Assets

### Images (~25 fichiers)
- Logos : `logo.png`, `logo1.png`, `logo_bleu.png`, `logo_blanc.png`, `logo_troov.jpeg`, `logo_troov-mini.jpeg`
- Paiements mobiles : `orange_money.png`, `wave.png`, `mtn_money.png`, `moov_money.png`, `airtel_money.png`, `mpesa.png`
- Stock photos : `image.png` … `image8.png`, `burger.png`, `burger.jpeg`, `refri.png`, `profile.png`
- Autres : `google_logo.png`, `ouz.png`

### Vidéos (3 fichiers)
- `troov.mp4`, `refri.mp4`, `royal.mp4`

### Localizations
- Langues supportées : **FR, EN, ES**
- 48+ clés traductibles déclarées dans `lib/utils/localization.dart` (pas de fichiers `.arb`)

---

## 11. Configuration

### Thème (`lib/utils/theme.dart`)
- Light : fond blanc, texte noir, accent bleu `#215E8C`
- Dark : fond noir, texte blanc, accent bleu

### Android
- `minSdkVersion` : 21
- Permissions : Biometric, Contacts, Location, Internet, Cleartext traffic

### Icône launcher
- Source : `assets/images/logo_troov.jpeg`
- Généré via `flutter_launcher_icons`

---

## 12. Points forts ✅

| Point fort | Détail |
|------------|--------|
| Config serveur dynamique | URL changeable sans recompilation (SharedPreferences) |
| Temps réel WebSocket | Feed, likes, commentaires via STOMP |
| Multilingue | FR / EN / ES |
| Dark mode | Thème stocké en préférence |
| Upload multipart | Images et vidéos |
| Cache images & vidéo | `cached_network_image` + `GlobalVideoCache` |
| Auth complète | Email, téléphone, OTP, code secret, biométrie, vérification identité |
| Géolocalisation | Via `geolocator` |
| Partage | Via `share_plus` |
| Système likes/commentaires | Counts en temps réel WebSocket |

---

## 13. Lacunes & Points à améliorer ⚠️

### Critique
| Problème | Impact | Fichier concerné |
|----------|--------|-----------------|
| Aucun test | Fragile en production | `test/` (vide) |
| `TransferService` 100% mockée | Fonctionnalité paiement non opérationnelle | `services/transfer_service.dart` |
| Token JWT stocké en clair | Risque sécurité (SharedPreferences non chiffré) | `services/auth_service.dart` |
| Pas de refresh token / logout au 401 | Sessions expirées mal gérées | Tous les services HTTP |

### Important
| Problème | Impact |
|----------|--------|
| Gestion erreur basique (`print()`) | UX dégradée, débogage difficile |
| Pas de state management global | Complexité grandissante avec + d'écrans |
| Pas de flavors dev/staging/prod | Déploiements risqués |
| Offline mode absent | App inutilisable sans réseau |
| Pagination partielle | Infinite scroll non uniforme |

### Mineur
| Problème | Impact |
|----------|--------|
| Pas de fichiers `.arb` (traductions hardcodées) | Maintenance traductions difficile |
| `print()` au lieu d'un logger | Logs non filtrables en prod |
| Pas de pinning SSL | Risque man-in-the-middle |
| Responsive non testé tablette | UI potentiellement cassée |
| Dispose controllers non systématique | Fuites mémoire potentielles |
| README très basique | Onboarding nouveaux devs difficile |

### Fonctionnalités à clarifier / compléter
- `ActivityService` — appelée dans `MySpaceScreen` mais logique à vérifier
- `CartService` — présente mais utilisation à confirmer
- `Chat` — structure WebSocket présente, implémentation à vérifier
- `NotificationsScreen` — appels API à clarifier
- `HistoryService` — à vérifier
- Pas de recherche globale identifiée
- Pas de système follow/unfollow utilisateurs
- Pas de blocage utilisateur

---

## 14. Résumé exécutif

**Troov** est une app Flutter MVP de marché local multi-services bien structurée, avec une UI complète (62+ écrans), une authentification robuste multi-mécanismes, un feed temps réel WebSocket, et une architecture en couches lisible.

**État actuel** : Prêt pour démo / MVP, mais plusieurs chantiers sont nécessaires avant une mise en production sérieuse :

1. **Sécurité** : chiffrer le stockage des tokens (`flutter_secure_storage`)
2. **Tests** : mettre en place tests unitaires et d'intégration
3. **TransferService** : connecter à une vraie API
4. **Gestion d'erreurs** : centraliser et afficher des feedbacks cohérents à l'utilisateur
5. **State management** : envisager `Riverpod` ou `BLoC` pour l'évolutivité
6. **Flavors** : séparer environnements dev / staging / prod

---

*Audit généré automatiquement — à mettre à jour à chaque sprint majeur.*
