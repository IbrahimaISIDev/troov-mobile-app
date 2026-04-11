# Configuration Dynamique du Serveur

## Vue d'ensemble

L'application mobile supporte maintenant une configuration dynamique du serveur. Cela permet de changer l'adresse du serveur sans recompiler l'APK.

## Comment ça fonctionne

1. **Au démarrage** : L'application charge la configuration du serveur depuis `SharedPreferences`
2. **Valeur par défaut** : Si aucune configuration n'est sauvegardée, utilise `http://192.168.1.69:8081/api`
3. **Persistance** : La configuration est sauvegardée localement sur le téléphone

## Accéder à la configuration

### Depuis l'application (à implémenter dans votre UI)

```dart
// Accéder à la page de configuration
Navigator.pushNamed(context, '/server-config');
```

### Depuis le code

```dart
import 'services/config_service.dart';

// Récupérer l'URL actuelle
String baseUrl = ConfigService.getBaseUrl();

// Sauvegarder une nouvelle URL
await ConfigService.saveBaseUrl('http://192.168.1.70:8081/api');

// Vérifier que l'URL est valide
bool isValid = ConfigService._isValidUrl('http://192.168.1.70:8081/api');

// Réinitialiser à la valeur par défaut
await ConfigService.resetToDefault();
```

## Interface utilisateur pour la configuration

La page `ServerConfigScreen` fournit une interface complète avec:

- ✅ Champ de texte pour entrer l'URL
- ✅ Bouton "Tester la connexion" pour vérifier que le serveur est accessible
- ✅ Messages d'erreur et de succès clairs
- ✅ Bouton "Sauvegarder" pour persister la configuration
- ✅ Bouton "Réinitialiser" pour revenir à la valeur par défaut
- ✅ Aide intégrée avec exemples

## Points clés

### 1. **Initialisation au démarrage**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService.loadConfig();
  runApp(MyApp());
}
```

### 2. **Configuration centralisée**

Tous les services utilisent `AppConfig.baseUrl` qui est maintenant dynamique:

```dart
// Au lieu de: static const String baseUrl = '...'
class AppConfig {
  static String _baseUrl = 'http://192.168.1.69:8081/api';
  
  static String get baseUrl => _baseUrl;
  static void setBaseUrl(String url) => _baseUrl = url;
}
```

### 3. **Services affectés**

Tous les services HTTP utilisent cette configuration:
- `AuthService`
- `ServiceHubService`
- `PostService`
- `ProductService`
- `PortfolioService`

## Format attendu pour l'URL

L'URL doit être au format correct:

✅ `http://192.168.1.69:8081/api`
✅ `https://troov-backend.onrender.com/api`
❌ `192.168.1.69:8081/api` (manque le protocole)
❌ `http://192.168.1.69:8081` (manque le chemin `/api`)

## Validation de la connexion

Avant de sauvegarder, vous pouvez tester la connexion:

```dart
bool success = await ConfigService.testConnection('http://192.168.1.70:8081/api');
```

Cette fonction:
1. Teste une requête simple au serveur
2. A un timeout de 5 secondes
3. Retourne `true` si le serveur répond avec un code 200

## Cas d'usage

### Distribution d'APK

1. **Développeur** : Distribue l'APK à d'autres utilisateurs
2. **Utilisateur** : Ouvre l'app
3. **Utilisateur** : Va dans les paramètres → Configuration du serveur
4. **Utilisateur** : Entre l'adresse de son serveur local
5. **Utilisateur** : Clique "Tester la connexion"
6. **Utilisateur** : Si OK, clique "Sauvegarder"
7. ✅ L'app se reconnecte automatiquement à la nouvelle adresse

### Passage du développement à la production

```dart
// Pour basculer rapidement vers la production
await ConfigService.saveBaseUrl(AppConfig.productionBaseUrl);
// = 'https://troov-backend.onrender.com/api'
```

## Intégration avec votre UI existante

Ajoutez un bouton dans votre écran d'accueil ou paramètres:

```dart
ListTile(
  leading: Icon(Icons.storage),
  title: Text('Configuration du serveur'),
  subtitle: Text(ConfigService.getBaseUrl()),
  onTap: () => Navigator.pushNamed(context, '/server-config'),
)
```

## Debugging

Pour voir les logs de configuration:

```dart
// Dans ConfigService, les erreurs sont loggées avec print()
// Activez les logs pour déboguer les problèmes de connexion
```

## Notes techniques

- La configuration utilise `SharedPreferences` pour la persistance
- Les modifications prennent effet immédiatement
- L'app ne nécessite pas de redémarrage après un changement
- La validation d'URL est effectuée avant la sauvegarde
