import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
    Locale('es'),
  ];

  final Locale locale;

  AppLocalizations(this.locale);

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'welcome': 'Bienvenue chez Troov',
      'welcome_description': 'Troov est votre plateforme de services de proximité. Trouvez facilement des prestataires qualifiés près de chez vous pour tous vos besoins quotidiens.',
      'get_started': 'Commencer',
      'home': 'Accueil',
      'services': 'Services',
      'messages': 'Messages',
      'profile': 'Profil',
      'settings': 'Paramètres',
      'dark_mode': 'Mode sombre',
      'language': 'Langue',
      'french': 'Français',
      'english': 'Anglais',
      'spanish': 'Espagnol',
      'search_services': 'Rechercher des services...',
      'popular_services': 'Services populaires',
      'nearby_providers': 'Prestataires à proximité',
      'book_now': 'Réserver maintenant',
      'view_profile': 'Voir le profil',
      'rating': 'Note',
      'reviews': 'Avis',
      'distance': 'Distance',
      'price': 'Prix',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'retry': 'Réessayer',
    },
    'en': {
      'welcome': 'Welcome to Troov',
      'welcome_description': 'Troov is your local services platform. Easily find qualified service providers near you for all your daily needs.',
      'get_started': 'Get Started',
      'home': 'Home',
      'services': 'Services',
      'messages': 'Messages',
      'profile': 'Profile',
      'settings': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'french': 'French',
      'english': 'English',
      'spanish': 'Spanish',
      'search_services': 'Search for services...',
      'popular_services': 'Popular Services',
      'nearby_providers': 'Nearby Providers',
      'book_now': 'Book Now',
      'view_profile': 'View Profile',
      'rating': 'Rating',
      'reviews': 'Reviews',
      'distance': 'Distance',
      'price': 'Price',
      'loading': 'Loading...',
      'error': 'Error',
      'retry': 'Retry',
    },
    'es': {
      'welcome': 'Bienvenido a Troov',
      'welcome_description': 'Troov es tu plataforma de servicios locales. Encuentra fácilmente proveedores de servicios calificados cerca de ti para todas tus necesidades diarias.',
      'get_started': 'Comenzar',
      'home': 'Inicio',
      'services': 'Servicios',
      'messages': 'Mensajes',
      'profile': 'Perfil',
      'settings': 'Configuración',
      'dark_mode': 'Modo Oscuro',
      'language': 'Idioma',
      'french': 'Francés',
      'english': 'Inglés',
      'spanish': 'Español',
      'search_services': 'Buscar servicios...',
      'popular_services': 'Servicios Populares',
      'nearby_providers': 'Proveedores Cercanos',
      'book_now': 'Reservar Ahora',
      'view_profile': 'Ver Perfil',
      'rating': 'Calificación',
      'reviews': 'Reseñas',
      'distance': 'Distancia',
      'price': 'Precio',
      'loading': 'Cargando...',
      'error': 'Error',
      'retry': 'Reintentar',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get welcome => translate('welcome');
  String get welcomeDescription => translate('welcome_description');
  String get getStarted => translate('get_started');
  String get home => translate('home');
  String get services => translate('services');
  String get messages => translate('messages');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get darkMode => translate('dark_mode');
  String get language => translate('language');
  String get french => translate('french');
  String get english => translate('english');
  String get spanish => translate('spanish');
  String get searchServices => translate('search_services');
  String get popularServices => translate('popular_services');
  String get nearbyProviders => translate('nearby_providers');
  String get bookNow => translate('book_now');
  String get viewProfile => translate('view_profile');
  String get rating => translate('rating');
  String get reviews => translate('reviews');
  String get distance => translate('distance');
  String get price => translate('price');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

