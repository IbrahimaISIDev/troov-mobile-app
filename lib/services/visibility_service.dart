import '../models/user.dart';

class VisibilityService {
  // Singleton pattern
  static final VisibilityService _instance = VisibilityService._internal();
  factory VisibilityService() => _instance;
  VisibilityService._internal();

  /// Check if a user can access a specific feature or content category
  bool canAccessFeature(User? user, String featureKey) {
    if (user == null) return false;

    // Business users have access to everything
    if (user.accountType == AccountType.business) return true;

    // Pro users have access to most things except specific business tools
    if (user.accountType == AccountType.pro) {
      if (featureKey == 'business_analytics' ||
          featureKey == 'ad_campaign_management') {
        return false;
      }
      return true;
    }

    // Essential (Free) users have restricted access
    if (user.accountType == AccountType.essential) {
      // List of restricted features for free users
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

    return false;
  }

  /// Check if a user can view a specific post level (e.g. for Real Estate)
  bool canViewListing(User? user, Map<String, dynamic> listingMetadata) {
    if (user == null) return false;

    // Example: Only subscribers to "Real Estate" or Pro/Business can see Premium listings
    bool isPremiumListing = listingMetadata['isPremium'] ?? false;

    if (!isPremiumListing) return true; // Everyone sees standard listings

    // Premium listing logic
    if (user.accountType == AccountType.business ||
        user.accountType == AccountType.pro) {
      return true;
    }

    // Check specific subscription (mocked logic)
    // if (user.subscriptions.contains('real_estate')) return true;

    return false;
  }
}
