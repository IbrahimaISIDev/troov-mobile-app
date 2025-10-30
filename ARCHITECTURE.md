# Architecture de Troov

## Aperçu

Application Flutter multi-plateforme structurée par couches:

- `lib/main.dart`: point d’entrée, configuration du thème, locales, routes.
- `lib/screens/`: UI et navigation (Splash, Welcome, Home, Auth...).
- `lib/services/`: logique métier et accès API (auth, booking, chat, paiement...).
- `lib/models/`: entités métier (user, service, booking...).
- `lib/widgets/`: composants UI réutilisables.
- `lib/utils/`: thème (`AppTheme`), i18n (`AppLocalizations`).

## Flux d’exécution

```mermaid
flowchart TD
  A[runApp(MyApp)] --> B[MaterialApp]
  B --> C[SplashScreen]
  C -->|routes| D[Welcome/Login/Register]
  D --> E[HomeScreen]
  E --> F[Services]
  F --> G[API / Stockage]
```

## Navigation et Locales

- Routes définies dans `MaterialApp.routes` (voir `lib/main.dart`).
- Locales supportées: FR, EN, ES via `flutter_localizations` et `intl`.
- Langue persistée avec `SharedPreferences` (`languageCode`).

## Thème

- `AppTheme.lightTheme` et `AppTheme.darkTheme` dans `lib/utils/theme.dart`.
- Préférence persistée avec `SharedPreferences` (`isDarkMode`).

## Services et Réseau

- Accès réseau via `http`.
- Services dédiés: `auth_service.dart`, `booking_service.dart`, `chat_service.dart`, `payment_service.dart`, `service_service.dart`.
- Chaque service gère la sérialisation avec les `models/*`.

## Modèles

- Entités: `user.dart`, `service.dart`, `service_provider.dart`, `booking.dart`, `message.dart`, `search_filters.dart`, `enums.dart`.

## Widgets

- Exemples: `conversation_tile.dart`, `provider_card.dart`, `service_card.dart`.

## Persistance et Préférences

- `SharedPreferences` pour stocker des préférences légères (thème, langue).

## Internationalisation

- `AppLocalizations.delegate` dans `lib/utils/localization.dart`.
- Ajouter les nouvelles chaînes et locales ici et dans `pubspec.yaml` si nécessaire.

## Tests

- Les tests unitaires vivent dans `test/` et s’exécutent avec `flutter test`.

## Évolutions possibles

- Ajouter une couche repository pour séparer réseau et domaine.
- Gérer l’état avec un package (Provider, Riverpod, Bloc) selon la complexité.
- Intégrer une configuration d’environnement (dev/staging/prod) pour les endpoints.
