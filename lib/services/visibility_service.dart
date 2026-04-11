import '../models/user.dart';

class VisibilityService {
  // Singleton pattern
  static final VisibilityService _instance = VisibilityService._internal();
  factory VisibilityService() => _instance;
  VisibilityService._internal();

  /// Check if a user can access a specific feature or content category
  bool canAccessFeature(User? user, String featureKey) {
    if (user == null) return false;

    // Simplified visibility logic pending Provider integration in UI
    if (user.role == UserRole.provider || user.role == UserRole.admin) {
      return true;
    }

    // List of restricted features for free clients
    const restrictedFeatures = [
      'advanced_stats',
      'unlimited_posts',
      'see_who_viewed_profile',
      'priority_support',
      'real_estate_premium_listings'
    ];
    if (restrictedFeatures.contains(featureKey)) return false;

    return true;
  }

  /// Check if a user can view a specific post level (e.g. for Real Estate)
  bool canViewListing(User? user, Map<String, dynamic> listingMetadata) {
    if (user == null) return false;

    // Example: Only subscribers to "Real Estate" or Pro/Business can see Premium listings
    bool isPremiumListing = listingMetadata['isPremium'] ?? false;

    if (!isPremiumListing) return true; // Everyone sees standard listings

    // Premium listing logic
    if (user.role == UserRole.provider || user.role == UserRole.admin) {
      return true;
    }

    return false;
  }
}
