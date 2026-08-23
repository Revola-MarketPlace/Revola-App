class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleAuth = '/auth/google';
  static const String me = '/auth/me';
  static const String selectRole = '/auth/select-role';
  static const String sellerOnboarding = '/auth/seller-onboarding';
  static const String updateDetails = '/auth/updatedetails';
  static const String updatePassword = '/auth/updatepassword';

  // Products & Catalog
  static const String products = '/products';
  static const String categories = '/categories';
  static const String materialTypes = '/material-types';
  static const String mySellerProducts = '/products/my/listings';

  // Cart
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';

  // Orders & Deliveries
  static const String estimateDeliveryFee = '/orders/estimate-delivery-fee';
  static const String checkout = '/orders/checkout';
  static const String myBuyerOrders = '/orders';
  static const String mySellerOrders = '/orders';
  static const String trackingByNumber = '/orders/tracking';
  static const String deliveryByOrder = '/deliveries/order';
  static const String deliveries = '/deliveries';
  static const String deliveryStatus = '/deliveries/status';

  // Payments
  static const String initPayment = '/payments/initialize';
  static const String verifyPayment = '/payments/verify-online';
  static const String submitReceipt = '/payments/submit-receipt';
  static const String pendingPayments = '/payments/pending';
  static const String verifyManualPayment = '/payments/verify-manual';

  // Map & Depots
  static const String mapPlaces = '/map/places';
  static const String nearestPlaces = '/map/nearest';

  // Payouts & Disputes
  static const String myPayouts = '/payouts/my/listings';
  static const String sellerProducts = '/products/my/listings';
  static const String disputes = '/disputes';
  static const String myDisputes = '/disputes/my-disputes';

  // Notifications & Admin
  static const String notifications = '/notifications';
  static const String readAllNotifications = '/notifications/read-all';
  static const String adminStats = '/admin/stats';
  static const String pendingApprovals = '/admin/pending-approvals';
}
