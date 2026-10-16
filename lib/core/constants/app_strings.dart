class AppStrings {
  AppStrings._();

  static String _currentLocale = 'en';

  static String get currentLocale => _currentLocale;

  static void setLocale(String langCode) {
    if (langCode == 'hi' || langCode == 'gu' || langCode == 'en') {
      _currentLocale = langCode;
    } else {
      _currentLocale = 'en';
    }
  }

  static String tr(String key, {String? langCode}) {
    final code = langCode ?? _currentLocale;
    return _translations[code]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  // App Identity & Constants
  static const String appName = 'Jewel Ora';
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Common Actions
  static String get login => tr('login');
  static String get register => tr('register');
  static String get logout => tr('logout');
  static String get cancel => tr('cancel');
  static String get save => tr('save');
  static String get delete => tr('delete');
  static String get edit => tr('edit');
  static String get add => tr('add');
  static String get retry => tr('retry');
  static String get clear => tr('clear');
  static String get apply => tr('apply');
  static String get viewAll => tr('viewAll');
  static String get all => tr('all');
  static String get close => tr('close');
  static String get confirm => tr('confirm');
  static String get ok => tr('ok');
  static String get signOut => tr('signOut');
  static String get confirmLogout => tr('confirmLogout');
  static String get confirmResetData => tr('confirmResetData');
  static String get resetDataDesc => tr('resetDataDesc');
  static String get seedData => tr('seedData');
  static String get bulkPriceAdjustment => tr('bulkPriceAdjustment');
  static String get bulkPriceSubtitle => tr('bulkPriceSubtitle');
  static String get increase => tr('increase');
  static String get discount => tr('discount');
  static String get adjustmentPercentage => tr('adjustmentPercentage');
  static String get targetCategory => tr('targetCategory');
  static String get applyBulkPrice => tr('applyBulkPrice');
  static String get allCategories => tr('allCategories');
  static String get cardOutlineHint => tr('cardOutlineHint');
  static String get coinOutlineHint => tr('coinOutlineHint');
  static String get placeCardHere => tr('placeCardHere');
  static String get placeCoinHere => tr('placeCoinHere');
  static String get creditOrDebitCard => tr('creditOrDebitCard');
  static String get fiveRupeeCoin => tr('fiveRupeeCoin');
  static String get lockAndSaveCalibration => tr('lockAndSaveCalibration');
  static String get resetCalibration => tr('resetCalibration');
  static String get visibleToCustomers => tr('visibleToCustomers');
  static String get hidden => tr('hidden');
  static String get activeOnHome => tr('activeOnHome');
  static String get editProfile => tr('editProfile');
  static String get changePassword => tr('changePassword');

  // Messages & Statuses
  static String get somethingWentWrong => tr('somethingWentWrong');
  static String get noData => tr('noData');
  static String get loading => tr('loading');
  static String get pleaseWait => tr('pleaseWait');
  static String get outOfStock => tr('outOfStock');
  static String get inStock => tr('inStock');
  static String get success => tr('success');
  static String get error => tr('error');
  static String get appTagline => tr('appTagline');

  // Auth Strings
  static String get welcomeBack => tr('welcomeBack');
  static String get loginToContinue => tr('loginToContinue');
  static String get email => tr('email');
  static String get password => tr('password');
  static String get confirmPassword => tr('confirmPassword');
  static String get fullName => tr('fullName');
  static String get phoneNumber => tr('phoneNumber');
  static String get forgotPassword => tr('forgotPassword');
  static String get dontHaveAccount => tr('dontHaveAccount');
  static String get alreadyHaveAccount => tr('alreadyHaveAccount');
  static String get createAccount => tr('createAccount');
  static String get joinExclusivity => tr('joinExclusivity');
  static String get continueWithGoogle => tr('continueWithGoogle');

  // User Navigation
  static String get navHome => tr('navHome');
  static String get navShop => tr('navShop');
  static String get navCart => tr('navCart');
  static String get navProfile => tr('navProfile');

  // Shop & Products
  static String get shopByCategory => tr('shopByCategory');
  static String get featuredCollection => tr('featuredCollection');
  static String get searchProducts => tr('searchProducts');
  static String get addToCart => tr('addToCart');
  static String get chatOnWhatsApp => tr('chatOnWhatsApp');
  static String get myWishlist => tr('myWishlist');
  static String get specifications => tr('specifications');
  static String get description => tr('description');
  static String get jewelleryCollection => tr('jewelleryCollection');
  static String get filterCollection => tr('filterCollection');
  static String get sortCollection => tr('sortCollection');
  static String get itemsFound => tr('itemsFound');
  static String get itemFound => tr('itemFound');
  static String get collectionEmpty => tr('collectionEmpty');
  static String get priceRange => tr('priceRange');
  static String get material => tr('material');
  static String get inStockOnly => tr('inStockOnly');
  static String get resetFilters => tr('resetFilters');
  static String get applyFilters => tr('applyFilters');
  static String get whatsappEnquiry => tr('whatsappEnquiry');
  static String get enquireWhatsApp => tr('enquireWhatsApp');
  static String get selectSize => tr('selectSize');
  static String get ringSizeGuide => tr('ringSizeGuide');
  static String get dropAHint => tr('dropAHint');
  static String get dropAHintSubtitle => tr('dropAHintSubtitle');
  static String get customisePiece => tr('customisePiece');
  static String get metalColor => tr('metalColor');
  static String get purityKarat => tr('purityKarat');
  static String get diamondOption => tr('diamondOption');
  static String get jewelleryCare => tr('jewelleryCare');
  static String get careAndCleaningTips => tr('careAndCleaningTips');
  static String get similarPieces => tr('similarPieces');
  static String get recentlyViewed => tr('recentlyViewed');
  static String get certified100 => tr('certified100');
  static String get lifetimeExchange => tr('lifetimeExchange');
  static String get insuredDelivery => tr('insuredDelivery');
  static String get liveRatePriced => tr('liveRatePriced');
  static String get noFeaturedItems => tr('noFeaturedItems');
  static String get exploreArrivals => tr('exploreArrivals');

  // Cart
  static String get shoppingBag => tr('shoppingBag');
  static String get myCart => tr('myCart');
  static String get cartEmpty => tr('cartEmpty');
  static String get browseShop => tr('browseShop');
  static String get exploreCollection => tr('exploreCollection');
  static String get cartEmptySubtitle => tr('cartEmptySubtitle');
  static String get estimatedTotal => tr('estimatedTotal');
  static String get sendEnquiryWhatsApp => tr('sendEnquiryWhatsApp');
  static String get clearCart => tr('clearCart');
  static String get itemUnavailable => tr('itemUnavailable');

  // Profile & Services
  static String get myProfile => tr('myProfile');
  static String get valuedCustomer => tr('valuedCustomer');
  static String get emailAddress => tr('emailAddress');
  static String get notProvided => tr('notProvided');
  static String get enquiryHistory => tr('enquiryHistory');
  static String get enquiryHistorySubtitle => tr('enquiryHistorySubtitle');
  static String get requestCustomJewellery => tr('requestCustomJewellery');
  static String get requestCustomSubtitle => tr('requestCustomSubtitle');
  static String get bookShowroomVisit => tr('bookShowroomVisit');
  static String get bookVisitSubtitle => tr('bookVisitSubtitle');
  static String get storeInfo => tr('storeInfo');
  static String get storeInfoSubtitle => tr('storeInfoSubtitle');
  static String get ringSizeGuideSubtitle => tr('ringSizeGuideSubtitle');
  static String get jewelleryCareSubtitle => tr('jewelleryCareSubtitle');
  static String get oldGoldCalculator => tr('oldGoldCalculator');
  static String get oldGoldCalculatorSubtitle => tr('oldGoldCalculatorSubtitle');
  static String get giftFinder => tr('giftFinder');
  static String get giftFinderSubtitle => tr('giftFinderSubtitle');
  static String get findGifts => tr('findGifts');
  static String get priceAlerts => tr('priceAlerts');
  static String get priceAlertsSubtitle => tr('priceAlertsSubtitle');
  static String get setRateAlert => tr('setRateAlert');
  static String get targetRate => tr('targetRate');
  static String get currentRate => tr('currentRate');
  static String get alertWhenBelow => tr('alertWhenBelow');
  static String get activeAlerts => tr('activeAlerts');
  static String get noActiveAlerts => tr('noActiveAlerts');
  static String get noAlertsSubtitle => tr('noAlertsSubtitle');
  static String get targetReached => tr('targetReached');
  static String get alertCreated => tr('alertCreated');
  static String get alertDeleted => tr('alertDeleted');
  static String get jewelleryVault => tr('jewelleryVault');
  static String get jewelleryVaultSubtitle => tr('jewelleryVaultSubtitle');
  static String get myVault => tr('myVault');
  static String get verifyHallmark => tr('verifyHallmark');
  static String get addToVault => tr('addToVault');
  static String get vaultEmpty => tr('vaultEmpty');
  static String get vaultEmptySubtitle => tr('vaultEmptySubtitle');
  static String get huidNumber => tr('huidNumber');
  static String get certVerified => tr('certVerified');
  static String get portfolioValue => tr('portfolioValue');
  static String get occasionReminders => tr('occasionReminders');
  static String get occasionRemindersSubtitle => tr('occasionRemindersSubtitle');
  static String get addMilestone => tr('addMilestone');
  static String get upcomingMilestones => tr('upcomingMilestones');
  static String get noReminders => tr('noReminders');
  static String get noRemindersSubtitle => tr('noRemindersSubtitle');
  static String get daysLeft => tr('daysLeft');
  static String get festiveDates => tr('festiveDates');
  static String get goldSavingsScheme => tr('goldSavingsScheme');
  static String get goldSavingsSubtitle => tr('goldSavingsSubtitle');
  static String get schemeCalculator => tr('schemeCalculator');
  static String get myActivePlan => tr('myActivePlan');
  static String get monthlyDeposit => tr('monthlyDeposit');
  static String get customerPays => tr('customerPays');
  static String get storeBonus => tr('storeBonus');
  static String get totalMaturity => tr('totalMaturity');
  static String get enrollScheme => tr('enrollScheme');
  static String get accumulatedGold => tr('accumulatedGold');
  static String get installmentProgress => tr('installmentProgress');
  static String get payInstallment => tr('payInstallment');
  static String get noActivePlan => tr('noActivePlan');
  static String get noActivePlanSubtitle => tr('noActivePlanSubtitle');
  static String get savingsBenefitBadge => tr('savingsBenefitBadge');
  static String get videoShopping => tr('videoShopping');
  static String get videoShoppingSubtitle => tr('videoShoppingSubtitle');
  static String get bookVideoCall => tr('bookVideoCall');
  static String get selectStylistTopic => tr('selectStylistTopic');
  static String get consultationLanguage => tr('consultationLanguage');
  static String get videoPlatform => tr('videoPlatform');
  static String get myAppointments => tr('myAppointments');
  static String get noAppointments => tr('noAppointments');
  static String get diamondGuide => tr('diamondGuide');
  static String get diamondGuideSubtitle => tr('diamondGuideSubtitle');
  static String get cut => tr('cut');
  static String get color => tr('color');
  static String get clarity => tr('clarity');
  static String get caratWeight => tr('caratWeight');
  static String get estDiamondValue => tr('estDiamondValue');
  static String get diamondMillimeter => tr('diamondMillimeter');
  static String get exploreSolitaires => tr('exploreSolitaires');
  static String get bridalPlanner => tr('bridalPlanner');
  static String get bridalPlannerSubtitle => tr('bridalPlannerSubtitle');
  static String get weddingCeremonies => tr('weddingCeremonies');
  static String get totalWeddingBudget => tr('totalWeddingBudget');
  static String get budgetSpent => tr('budgetSpent');
  static String get budgetRemaining => tr('budgetRemaining');
  static String get bridalChecklist => tr('bridalChecklist');
  static String get addBridalPiece => tr('addBridalPiece');
  static String get exportTrousseauWhatsApp => tr('exportTrousseauWhatsApp');
  static String get ringBangleSizer => tr('ringBangleSizer');
  static String get calibrateScreen => tr('calibrateScreen');
  static String get saveSizeToProfile => tr('saveSizeToProfile');
  static String get savedSizeSuccess => tr('savedSizeSuccess');
  static String get calibratedSuccess => tr('calibratedSuccess');
  static String get changeLanguage => tr('changeLanguage');
  static String get changeLanguageSubtitle => tr('changeLanguageSubtitle');
  static String get followUpWhatsApp => tr('followUpWhatsApp');
  static String get enquiryDetails => tr('enquiryDetails');

  // Metal Rates & Calculator
  static String get liveRates => tr('liveRates');
  static String get todayRates => tr('todayRates');
  static String get ratePerGram => tr('ratePerGram');
  static String get rateCalculator => tr('rateCalculator');
  static String get calculate => tr('calculate');
  static String get gold24k => tr('gold24k');
  static String get gold22k => tr('gold22k');
  static String get silver999 => tr('silver999');
  static String get diwaliSale => tr('diwaliSale');
  static String get festiveOffer => tr('festiveOffer');

  // Custom Order
  static String get customOrder => tr('customOrder');
  static String get referencePhotoTitle => tr('referencePhotoTitle');
  static String get referencePhotoDesc => tr('referencePhotoDesc');
  static String get specificationsTitle => tr('specificationsTitle');
  static String get preferredMetal => tr('preferredMetal');
  static String get sizeDimensions => tr('sizeDimensions');
  static String get approxBudget => tr('approxBudget');
  static String get detailedRequirements => tr('detailedRequirements');
  static String get sendCustomOrderWhatsApp => tr('sendCustomOrderWhatsApp');

  // Book Visit
  static String get bookVisitTitle => tr('bookVisitTitle');
  static String get selectDate => tr('selectDate');
  static String get selectTimeSlot => tr('selectTimeSlot');
  static String get notesOptional => tr('notesOptional');
  static String get sendVisitRequestWhatsApp => tr('sendVisitRequestWhatsApp');

  // Store Information
  static String get visitOurStore => tr('visitOurStore');
  static String get getDirections => tr('getDirections');
  static String get callStore => tr('callStore');
  static String get storeTimings => tr('storeTimings');
  static String get followInstagram => tr('followInstagram');
  static String get storeAddress => tr('storeAddress');

  // Admin
  static String get adminPanel => tr('adminPanel');
  static String get manageStore => tr('manageStore');
  static String get products => tr('products');
  static String get categories => tr('categories');
  static String get banners => tr('banners');
  static String get appSettings => tr('appSettings');
  static String get appBranding => tr('appBranding');
  static String get insights => tr('insights');
  static String get metalRates => tr('metalRates');
  static String get customerEnquiries => tr('customerEnquiries');

  // ==========================================
  // Multi-Language Translation Dictionaries
  // ==========================================
  static const Map<String, Map<String, String>> _translations = {
    // English
    'en': {
      'appTagline': 'Timeless Elegance & Luxury',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'retry': 'Retry',
      'clear': 'Clear',
      'apply': 'Apply',
      'viewAll': 'View All',
      'all': 'All',
      'close': 'Close',
      'confirm': 'Confirm',
      'ok': 'OK',
      'signOut': 'Sign Out',
      'confirmLogout': 'Are you sure you want to log out?',
      'confirmResetData': 'Reset & Seed Demo Data?',
      'resetDataDesc': 'This will reset all catalogue products, categories, and banners with 18 authentic jewellery pieces.',
      'seedData': 'Reset & Seed Data',
      'bulkPriceAdjustment': 'Bulk Price Adjustment',
      'bulkPriceSubtitle': 'Batch update catalogue pricing across collection',
      'increase': 'Increase (+)',
      'discount': 'Discount (-)',
      'adjustmentPercentage': 'Adjustment Percentage (%)',
      'targetCategory': 'Target Category (Optional)',
      'applyBulkPrice': 'Apply Bulk Price Change',
      'allCategories': 'All Categories',
      'cardOutlineHint': 'Place any standard credit or debit card against the outline below. Drag the slider until the outline matches the width of your card (85.6 mm).',
      'coinOutlineHint': 'Place an Indian ₹5 coin on the circular outline below. Drag the slider until the circle matches the exact coin diameter (23.0 mm).',
      'placeCardHere': 'Place Card Here\n(Standard 85.6 mm)',
      'placeCoinHere': 'Place ₹5 Coin\n(23.0 mm)',
      'creditOrDebitCard': 'Credit / Debit Card',
      'fiveRupeeCoin': '₹5 Coin',
      'lockAndSaveCalibration': 'Lock & Save Screen Calibration ✓',
      'resetCalibration': 'Reset Calibration to Default',
      'visibleToCustomers': 'Visible to customers',
      'hidden': 'Hidden',
      'activeOnHome': 'Active on Home',
      'editProfile': 'Edit Profile',
      'changePassword': 'Change Password',
      'somethingWentWrong': 'Something went wrong. Please try again.',
      'noData': 'Nothing to show yet',
      'loading': 'Loading...',
      'pleaseWait': 'Please wait...',
      'outOfStock': 'Out of Stock',
      'inStock': 'In Stock',
      'success': 'Success',
      'error': 'Error',
      'welcomeBack': 'Welcome Back',
      'loginToContinue': 'Login to continue to your exclusive vault',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'fullName': 'Full Name',
      'phoneNumber': 'Phone Number (optional)',
      'forgotPassword': 'Forgot password?',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'createAccount': 'Create Account',
      'joinExclusivity': 'Join our exclusive jewellery community',
      'continueWithGoogle': 'Continue with Google',
      'navHome': 'Home',
      'navShop': 'Shop',
      'navCart': 'Cart',
      'navProfile': 'Profile',
      'shopByCategory': 'Shop by Category',
      'featuredCollection': 'Featured Collection',
      'searchProducts': 'Search jewellery by name or material...',
      'addToCart': 'Add to Cart',
      'chatOnWhatsApp': 'Chat on WhatsApp',
      'myWishlist': 'My Wishlist',
      'specifications': 'Specifications',
      'description': 'Description',
      'jewelleryCollection': 'Jewellery Collection',
      'filterCollection': 'Filter Collection',
      'sortCollection': 'Sort Collection',
      'itemsFound': 'items found',
      'itemFound': 'item found',
      'collectionEmpty': 'Collection is empty',
      'priceRange': 'Price Range',
      'material': 'Material',
      'inStockOnly': 'In Stock Only',
      'resetFilters': 'Reset Filters',
      'applyFilters': 'Apply Filters',
      'whatsappEnquiry': 'WhatsApp Enquiry',
      'enquireWhatsApp': 'Enquire on WhatsApp',
      'selectSize': 'Select Size / Dimension',
      'ringSizeGuide': 'Ring Size Guide',
      'dropAHint': 'Drop a Hint',
      'dropAHintSubtitle': 'Let someone special know what you love',
      'customisePiece': 'Customise Your Piece',
      'metalColor': 'Metal Color Tone',
      'purityKarat': 'Gold Purity (Karat)',
      'diamondOption': 'Diamond Quality',
      'jewelleryCare': 'Jewellery Care Tips',
      'careAndCleaningTips': 'View Jewellery Care & Cleaning Tips',
      'similarPieces': 'Similar Pieces You May Love',
      'recentlyViewed': 'Recently Viewed',
      'certified100': '100% Certified',
      'lifetimeExchange': 'Lifetime Exchange',
      'insuredDelivery': 'Insured Delivery',
      'liveRatePriced': 'Live Rate Priced',
      'noFeaturedItems': 'No featured items yet',
      'exploreArrivals': 'Explore our latest jewellery arrivals.',
      'shoppingBag': 'Shopping Bag',
      'myCart': 'My Cart',
      'cartEmpty': 'Your shopping bag is empty',
      'browseShop': 'Explore Collection',
      'exploreCollection': 'Explore Collection',
      'cartEmptySubtitle': 'Explore our latest jewellery arrivals and add pieces to your bag.',
      'estimatedTotal': 'Estimated Total',
      'sendEnquiryWhatsApp': 'Send Enquiry on WhatsApp',
      'clearCart': 'Clear Cart',
      'itemUnavailable': 'This piece is currently unavailable',
      'myProfile': 'My Profile',
      'valuedCustomer': 'Valued Customer',
      'emailAddress': 'Email Address',
      'notProvided': 'Not provided',
      'enquiryHistory': 'My Enquiries & Quotes',
      'enquiryHistorySubtitle': 'Track requested jewellery and WhatsApp quotes',
      'requestCustomJewellery': 'Request Custom Jewellery',
      'requestCustomSubtitle': 'Upload reference photos for made-to-order pieces',
      'bookShowroomVisit': 'Book a Showroom Visit',
      'bookVisitSubtitle': 'Schedule date & time to visit our store',
      'storeInfo': 'Store Location & Contact',
      'storeInfoSubtitle': 'Directions, store timings, and calling info',
      'ringSizeGuideSubtitle': 'Find your perfect ring or bangle size',
      'jewelleryCareSubtitle': 'Maintain brilliance, storage, and cleaning advice',
      'oldGoldCalculator': 'Old Gold Calculator',
      'oldGoldCalculatorSubtitle': 'Calculate instant trade-in value for old jewellery',
      'giftFinder': 'Gift Finder & Stylist',
      'giftFinderSubtitle': 'Find the perfect jewellery gift in 30 seconds',
      'findGifts': 'Find Gifts',
      'priceAlerts': 'Gold Rate Alerts',
      'priceAlertsSubtitle': 'Get notified when gold or silver rate drops',
      'setRateAlert': 'Set Price Drop Alert',
      'targetRate': 'Target Rate',
      'currentRate': 'Current Live Rate',
      'alertWhenBelow': 'Alert me when rate drops to or below',
      'activeAlerts': 'My Active Alerts',
      'noActiveAlerts': 'No price drop alerts set yet',
      'noAlertsSubtitle': 'Set a target rate to track price drops for your favourite metal.',
      'targetReached': 'Target Rate Reached! 🎉',
      'alertCreated': 'Price drop alert created successfully!',
      'alertDeleted': 'Price alert deleted',
      'jewelleryVault': 'Jewellery Vault & Hallmark',
      'jewelleryVaultSubtitle': 'Track portfolio valuation & verify BIS Hallmark / IGI cert',
      'myVault': 'My Vault',
      'verifyHallmark': 'Verify Hallmark / Cert',
      'addToVault': 'Add Piece to Vault',
      'vaultEmpty': 'Your Jewellery Vault is empty',
      'vaultEmptySubtitle': 'Add your gold & diamond pieces to track real-time portfolio valuation based on daily rates.',
      'huidNumber': '6-character BIS HUID',
      'certVerified': 'Certificate Authenticity Verified ✓',
      'portfolioValue': 'Total Portfolio Value',
      'occasionReminders': 'Occasion & Anniversary Reminders',
      'occasionRemindersSubtitle': 'Never miss an anniversary, birthday, or festive date',
      'addMilestone': 'Add Occasion / Milestone',
      'upcomingMilestones': 'Upcoming Milestones',
      'noReminders': 'No milestone dates saved yet',
      'noRemindersSubtitle': 'Save upcoming anniversaries and birthdays to get advance gifting recommendations.',
      'daysLeft': 'days to go',
      'festiveDates': 'Auspicious Gold Dates',
      'goldSavingsScheme': 'Monthly Gold Savings Scheme',
      'goldSavingsSubtitle': '11+1 Plan: Pay 11 months & get the 12th month free from Jewel Ora',
      'schemeCalculator': 'Scheme Calculator',
      'myActivePlan': 'My Active Plan',
      'monthlyDeposit': 'Monthly Deposit Amount',
      'customerPays': 'You Pay (11 Months)',
      'storeBonus': 'Jewel Ora Bonus (1 Month FREE)',
      'totalMaturity': 'Total Jewellery Value at Maturity',
      'enrollScheme': 'Enroll in Gold Savings Plan',
      'accumulatedGold': 'Est. Gold Accumulated',
      'installmentProgress': 'Installment Progress',
      'payInstallment': 'Record Monthly Installment',
      'noActivePlan': 'No Active Savings Plan',
      'noActivePlanSubtitle': 'Start a monthly gold savings scheme today to get 1 month installment free!',
      'savingsBenefitBadge': '100% 12th Month Bonus',
      'videoShopping': 'Live Video Shopping',
      'videoShoppingSubtitle': 'Book 1-on-1 virtual consultation with a jewellery stylist',
      'bookVideoCall': 'Book Live Video Call',
      'selectStylistTopic': 'Select Jewellery Interest',
      'consultationLanguage': 'Consultation Language',
      'videoPlatform': 'Video Platform',
      'myAppointments': 'My Video Consultations',
      'noAppointments': 'No upcoming video consultations',
      'diamondGuide': 'Diamond 4Cs Guide',
      'diamondGuideSubtitle': 'Learn Cut, Color, Clarity & Carat with interactive simulator',
      'cut': 'Cut',
      'color': 'Color',
      'clarity': 'Clarity',
      'caratWeight': 'Carat Weight',
      'estDiamondValue': 'Est. Diamond Value',
      'diamondMillimeter': 'Diameter on Hand',
      'exploreSolitaires': 'Explore Solitaire Collection',
      'bridalPlanner': 'Bridal Trousseau & Budget Planner',
      'bridalPlannerSubtitle': 'Plan wedding jewellery ceremonies, allocate budget & track trousseau pieces',
      'weddingCeremonies': 'Ceremonies',
      'totalWeddingBudget': 'Total Jewellery Budget',
      'budgetSpent': 'Purchased / Spent',
      'budgetRemaining': 'Remaining Budget',
      'bridalChecklist': 'Bridal Checklist',
      'addBridalPiece': 'Add Jewellery Piece',
      'exportTrousseauWhatsApp': 'Share Trousseau on WhatsApp',
      'ringBangleSizer': 'Physical Ring & Bangle Sizer',
      'calibrateScreen': 'Calibrate Screen Accuracy',
      'saveSizeToProfile': 'Save My Size',
      'savedSizeSuccess': 'Size saved to your profile!',
      'calibratedSuccess': 'Screen calibrated with physical accuracy!',
      'changeLanguage': 'Change Language / भाषा बदलें',
      'changeLanguageSubtitle': 'Select English, Hindi, or Gujarati',
      'followUpWhatsApp': 'Follow Up on WhatsApp',
      'enquiryDetails': 'Enquiry Details',
      'liveRates': 'Live Metal Rates',
      'todayRates': "Today's Metal Rates",
      'ratePerGram': 'per gram',
      'rateCalculator': 'Gold & Silver Rate Calculator',
      'calculate': 'Calculate',
      'gold24k': '24K Pure Gold',
      'gold22k': '22K Hallmark Gold',
      'silver999': 'Fine Silver',
      'diwaliSale': 'Diwali Sale',
      'festiveOffer': 'Festive Offer',
      'customOrder': 'Custom Jewellery Order',
      'referencePhotoTitle': '1. Reference Design Photo (Optional)',
      'referencePhotoDesc': 'Attach a picture, sketch, or screenshot of the piece you want made.',
      'specificationsTitle': '2. Specifications & Sizing',
      'preferredMetal': 'Preferred Metal & Purity',
      'sizeDimensions': 'Size / Dimensions',
      'approxBudget': 'Approximate Budget (Optional)',
      'detailedRequirements': 'Detailed Requirements / Custom Notes',
      'sendCustomOrderWhatsApp': 'Send Custom Order Request on WhatsApp',
      'bookVisitTitle': 'Book a Showroom Visit',
      'selectDate': 'Select Date',
      'selectTimeSlot': 'Select Time Slot',
      'notesOptional': 'Special Requests / Notes (Optional)',
      'sendVisitRequestWhatsApp': 'Confirm & Send Request on WhatsApp',
      'visitOurStore': 'Visit Our Experience Store',
      'getDirections': 'Get Directions',
      'callStore': 'Call Store',
      'storeTimings': 'Showroom Timings',
      'followInstagram': 'Follow on Instagram',
      'storeAddress': 'Store Address',
      'adminPanel': 'Admin Panel',
      'manageStore': 'Manage your store and collections',
      'products': 'Products',
      'categories': 'Categories',
      'banners': 'Banners',
      'appSettings': 'App Settings',
      'appBranding': 'App Branding',
      'insights': 'Insights',
      'metalRates': 'Daily Metal Rates',
      'customerEnquiries': 'Customer Enquiries',
    },

    // Hindi (हिंदी)
    'hi': {
      'appTagline': 'सदाबहार सुंदरता और शुद्धता',
      'login': 'लॉगिन',
      'register': 'रजिस्टर करें',
      'logout': 'लॉग आउट',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'add': 'जोड़ें',
      'retry': 'पुनः प्रयास करें',
      'clear': 'साफ़ करें',
      'apply': 'लागू करें',
      'viewAll': 'सभी देखें',
      'all': 'सभी',
      'close': 'बंद करें',
      'confirm': 'पुष्टि करें',
      'ok': 'ठीक है',
      'signOut': 'साइन आउट',
      'confirmLogout': 'क्या आप निश्चित रूप से लॉग आउट करना चाहते हैं?',
      'confirmResetData': 'डेमो डेटा रीसेट करें?',
      'resetDataDesc': 'यह 18 असली आभूषणों के साथ सभी कैटलॉग उत्पाद, श्रेणियां और बैनर रीसेट कर देगा।',
      'seedData': 'डेटा रीसेट और सीड करें',
      'bulkPriceAdjustment': 'थोक भाव समायोजन',
      'bulkPriceSubtitle': 'कलेक्शन में एक साथ कीमतों को अपडेट करें',
      'increase': 'बढ़ाएं (+)',
      'discount': 'छूट (-)',
      'adjustmentPercentage': 'समायोजन प्रतिशत (%)',
      'targetCategory': 'लक्षित श्रेणी (वैकल्पिक)',
      'applyBulkPrice': 'थोक भाव लागू करें',
      'allCategories': 'सभी श्रेणियां',
      'cardOutlineHint': 'नीचे दी गई रूपरेखा पर कोई भी मानक क्रेडिट या डेबिट कार्ड रखें। कार्ड की चौड़ाई (85.6 मिमी) से मेल खाने तक स्लाइडर खींचें।',
      'coinOutlineHint': 'नीचे दिए गए वृत्त पर ₹५ का भारतीय सिक्का रखें। सिक्के के व्यास (23.0 मिमी) से मेल खाने तक स्लाइडर खींचें।',
      'placeCardHere': 'यहाँ कार्ड रखें\n(मानक 85.6 मिमी)',
      'placeCoinHere': 'यहाँ ₹५ सिक्का रखें\n(23.0 मिमी)',
      'creditOrDebitCard': 'क्रेडिट / डेबिट कार्ड',
      'fiveRupeeCoin': '₹५ सिक्का',
      'lockAndSaveCalibration': 'स्क्रीन कैलिब्रेशन सुरक्षित करें ✓',
      'resetCalibration': 'डिफ़ॉल्ट कैलिब्रेशन रीसेट करें',
      'visibleToCustomers': 'ग्राहकों को दृश्य',
      'hidden': 'छिपा हुआ',
      'activeOnHome': 'होम पर सक्रिय',
      'editProfile': 'प्रोफ़ाइल संपादित करें',
      'changePassword': 'पासवर्ड बदलें',
      'somethingWentWrong': 'कुछ गलत हो गया। कृपया पुन: प्रयास करें।',
      'noData': 'अभी कुछ नहीं है',
      'loading': 'लोड हो रहा है...',
      'pleaseWait': 'कृपया प्रतीक्षा करें...',
      'outOfStock': 'स्टॉक समाप्त',
      'inStock': 'उपलब्ध है',
      'success': 'सफल',
      'error': 'त्रुटि',
      'welcomeBack': 'स्वागत है',
      'loginToContinue': 'अपनी ज्वेलरी वॉल्ट देखने के लिए लॉगिन करें',
      'email': 'ईमेल पता',
      'password': 'पासवर्ड',
      'confirmPassword': 'पासवर्ड की पुष्टि करें',
      'fullName': 'पूरा नाम',
      'phoneNumber': 'फ़ोन नंबर (वैकल्पिक)',
      'forgotPassword': 'पासवर्ड भूल गए?',
      'dontHaveAccount': 'खाता नहीं है?',
      'alreadyHaveAccount': 'पहले से खाता है?',
      'createAccount': 'खाता बनाएं',
      'joinExclusivity': 'हमारे खास ज्वेलरी परिवार से जुड़ें',
      'continueWithGoogle': 'गूगल से जारी रखें',
      'navHome': 'होम',
      'navShop': 'शॉप',
      'navCart': 'कार्ट',
      'navProfile': 'प्रोफ़ाइल',
      'shopByCategory': 'कैटेगरी अनुसार देखें',
      'featuredCollection': 'खास आभूषण संग्रह',
      'searchProducts': 'आभूषण, धातु या नाम से खोजें...',
      'addToCart': 'कार्ट में जोड़ें',
      'chatOnWhatsApp': 'व्हाट्सएप पर चैट करें',
      'myWishlist': 'मेरी विशलिस्ट',
      'specifications': 'आभूषण विवरण',
      'description': 'विवरण',
      'jewelleryCollection': 'ज्वेलरी कलेक्शन',
      'filterCollection': 'फ़िल्टर करें',
      'sortCollection': 'क्रमबद्ध करें',
      'itemsFound': 'आभूषण मिले',
      'itemFound': 'आभूषण मिला',
      'collectionEmpty': 'संग्रह खाली है',
      'priceRange': 'कीमत दायरा',
      'material': 'धातु / मटेरियल',
      'inStockOnly': 'केवल उपलब्ध स्टॉक',
      'resetFilters': 'फ़िल्टर हटाएं',
      'applyFilters': 'फ़िल्टर लगाएं',
      'whatsappEnquiry': 'व्हाट्सएप पूछताछ',
      'enquireWhatsApp': 'व्हाट्सएप पर पूछताछ करें',
      'selectSize': 'साइज / माप चुनें',
      'ringSizeGuide': 'रिंग साइज गाइड',
      'dropAHint': 'इशारा करें (Drop a Hint)',
      'dropAHintSubtitle': 'किसी खास को बताएं कि आपको क्या पसंद है',
      'customisePiece': 'आभूषण कस्टमाइज़ करें',
      'metalColor': 'धातु का रंग',
      'purityKarat': 'सोने की शुद्धता (कैરેટ)',
      'diamondOption': 'हीरे की गुणवत्ता',
      'jewelleryCare': 'ज्वेलरी देखभाल टिप्स',
      'careAndCleaningTips': 'ज्वेलरी देखभाल और सफाई टिप्स देखें',
      'similarPieces': 'मिलते-जुलते आभूषण',
      'recentlyViewed': 'हाल ही में देखे गए',
      'certified100': '100% प्रमाणित',
      'lifetimeExchange': 'लाइफटाइम एक्सचेंज',
      'insuredDelivery': 'बीमाकृत डिलीवरी',
      'liveRatePriced': 'लाइव भाव पर आधारित',
      'noFeaturedItems': 'कोई खास आभूषण अभी नहीं है',
      'exploreArrivals': 'हमारे नवीनतम आभूषण संग्रह देखें।',
      'shoppingBag': 'शॉपिंग बैग',
      'myCart': 'मेरी कार्ट',
      'cartEmpty': 'आपका शॉपिंग बैग खाली है',
      'browseShop': 'कलेक्शन देखें',
      'exploreCollection': 'कलेक्शन देखें',
      'cartEmptySubtitle': 'हमारे नवीनतम आभूषण संग्रह देखें और अपने बैग में जोड़ें।',
      'estimatedTotal': 'अनुमानित कुल राशि',
      'sendEnquiryWhatsApp': 'व्हाट्सएप पर पूछताछ भेजें',
      'clearCart': 'कार्ट खाली करें',
      'itemUnavailable': 'यह आभूषण वर्तमान में उपलब्ध नहीं है',
      'myProfile': 'मेरी प्रोफ़ाइल',
      'valuedCustomer': 'प्रिय ग्राहक',
      'emailAddress': 'ईमेल पता',
      'notProvided': 'उपलब्ध नहीं',
      'enquiryHistory': 'मेरी पूछताछ और कोट्स',
      'enquiryHistorySubtitle': 'पूछताछ किए गए आभूषण और कोट्स ट्रैक करें',
      'requestCustomJewellery': 'कस्टम ज्वेलरी ऑर्डर',
      'requestCustomSubtitle': 'कस्टम आभूषण के लिए फोटो अपलोड करें',
      'bookShowroomVisit': 'शोरूम विज़िट बुक करें',
      'bookVisitSubtitle': 'स्टोर विज़िट के लिए तारीख और समय चुनें',
      'storeInfo': 'स्टोर स्थान और संपर्क',
      'storeInfoSubtitle': 'दिशा-निर्देश, स्टोर समय और कॉलिंग विवरण',
      'ringSizeGuideSubtitle': 'अपनी सटीक रिंग या कंगन का साइज जानें',
      'jewelleryCareSubtitle': 'चमक बनाए रखने और साफ-सफाई की सलाह',
      'oldGoldCalculator': 'पुराने गोल्ड का कैलकुलेटर',
      'oldGoldCalculatorSubtitle': 'अपने पुराने आभूषणों का तत्काल विनिमय मूल्य जानें',
      'giftFinder': 'गिफ्ट खोजें (Gift Finder)',
      'giftFinderSubtitle': '३० सेकंड में सही उपहार खोजें',
      'findGifts': 'गिफ्ट ढूंढें',
      'priceAlerts': 'सोने के भाव का अलर्ट',
      'priceAlertsSubtitle': 'सोने या चांदी का भाव गिरने पर अलर्ट पाएं',
      'setRateAlert': 'भाव गिरने का अलर्ट सेट करें',
      'targetRate': 'लक्षित भाव',
      'currentRate': 'वर्तमान लाइव भाव',
      'alertWhenBelow': 'इस भाव पर या इससे नीचे गिरने पर अलर्ट करें',
      'activeAlerts': 'मेरे सक्रिय अलर्ट',
      'noActiveAlerts': 'अभी कोई अलर्ट सेट नहीं है',
      'noAlertsSubtitle': 'अपनी पसंदीदा धातु के भाव गिरने पर नज़र रखने के लिए लक्षित भाव सेट करें।',
      'targetReached': 'लक्षित भाव प्राप्त हुआ! 🎉',
      'alertCreated': 'भाव अलर्ट सफलतापूर्वक सेट किया गया!',
      'alertDeleted': 'अलर्ट हटा दिया गया',
      'jewelleryVault': 'ज्वेलरी वॉल्ट और हॉलमार्क',
      'jewelleryVaultSubtitle': 'पोर्टफोलियो मूल्यांकन ट्रैक करें और हॉलमार्क सत्यापित करें',
      'myVault': 'मेरी वॉल्ट',
      'verifyHallmark': 'हॉलमार्क / सर्टिफिकेट जांचें',
      'addToVault': 'वॉल्ट में आभूषण जोड़ें',
      'vaultEmpty': 'आपकी ज्वेलरी वॉल्ट खाली है',
      'vaultEmptySubtitle': 'लाइव भावों के आधार पर वास्तविक समय में मूल्यांकन जानने के लिए अपने आभूषण जोड़ें।',
      'huidNumber': '६-अंकों का बीआईएस HUID',
      'certVerified': 'सर्टिफिकेट प्रामाणिकता सत्यापित ✓',
      'portfolioValue': 'कुल पोर्टफोलियो मूल्यांकन',
      'occasionReminders': 'अवसर और वर्षगांठ रिमाइंडर',
      'occasionRemindersSubtitle': 'वर्षगांठ, जन्मदिन या शुभ मुहूर्त कभी न भूलें',
      'addMilestone': 'अवसर / तारीख जोड़ें',
      'upcomingMilestones': 'आगामी अवसर',
      'noReminders': 'अभी कोई तारीख सहेजी नहीं गई है',
      'noRemindersSubtitle': 'समय पर ज्वेलरी उपहार की सिफारिशें पाने के लिए वर्षगांठ और जन्मदिन सहेजें।',
      'daysLeft': 'दिन शेष',
      'festiveDates': 'सोना खरीदने के शुभ मुहूर्त',
      'goldSavingsScheme': 'मासिक स्वर्ण बचत योजना',
      'goldSavingsSubtitle': '11+1 योजना: 11 महीने जमा करें और 12वां महीना ज्वेल ओरा से मुफ़्त पाएं',
      'schemeCalculator': 'योजना कैलकुलेटर',
      'myActivePlan': 'मेरी सक्रिय योजना',
      'monthlyDeposit': 'मासिक जमा राशि',
      'customerPays': 'आपका कुल भुगतान (11 माह)',
      'storeBonus': 'ज्वेल ओरा बोनस (1 माह मुफ़्त)',
      'totalMaturity': 'परिपक्वता पर कुल आभूषण मूल्य',
      'enrollScheme': 'स्वर्ण बचत योजना में शामिल हों',
      'accumulatedGold': 'अनुमानित संचित सोना',
      'installmentProgress': 'किस्त की प्रगति',
      'payInstallment': 'मासिक किस्त दर्ज करें',
      'noActivePlan': 'कोई सक्रिय बचत योजना नहीं है',
      'noActivePlanSubtitle': '1 महीने की किस्त मुफ़्त पाने के लिए आज ही मासिक स्वर्ण बचत योजना शुरू करें!',
      'savingsBenefitBadge': '100% 12वें महीने का बोनस',
      'videoShopping': 'लाइव वीडियो शॉपिंग',
      'videoShoppingSubtitle': 'ज्वेलरी स्टाइलिस्ट के साथ 1-ऑन-1 वर्चुअल परामर्श बुक करें',
      'bookVideoCall': 'लाइव वीडियो कॉल बुक करें',
      'selectStylistTopic': 'आभूषण श्रेणी चुनें',
      'consultationLanguage': 'परामर्श की भाषा',
      'videoPlatform': 'वीडियो कॉलिंग माध्यम',
      'myAppointments': 'मेरी वीडियो परामर्श',
      'noAppointments': 'कोई आगामी वीडियो परामर्श नहीं है',
      'diamondGuide': 'डायमंड 4Cs गाइड',
      'diamondGuideSubtitle': 'इंटरैक्टिव सिम्युलेटर के साथ कट, कलर, क्लैरिटी और कैरेट सीखें',
      'cut': 'कट (तराश)',
      'color': 'कलर (रंग)',
      'clarity': 'क्लैरिटी (शुद्धता)',
      'caratWeight': 'कैरेट वज़न',
      'estDiamondValue': 'अनुमानित डायमंड मूल्य',
      'diamondMillimeter': 'व्यास (हाथ पर आकार)',
      'exploreSolitaires': 'सॉलिटेयर कलेक्शन देखें',
      'bridalPlanner': 'विवाह आभूषण व बजट प्लानर',
      'bridalPlannerSubtitle': 'विवाह समारोह अनुसार आभूषण और बजट की योजना बनाएं',
      'weddingCeremonies': 'विवाह समारोह',
      'totalWeddingBudget': 'कुल आभूषण बजट',
      'budgetSpent': 'खरीदा गया / खर्च',
      'budgetRemaining': 'शेष बजट',
      'bridalChecklist': 'दुल्हन आभूषण सूची',
      'addBridalPiece': 'नया आभूषण जोड़ें',
      'exportTrousseauWhatsApp': 'व्हाट्सएप पर शेयर करें',
      'ringBangleSizer': 'स्क्रीन रिंग व कंगन साइज़र',
      'calibrateScreen': 'स्क्रीन कैलिब्रेशन (सटीक माप)',
      'saveSizeToProfile': 'माप प्रोफ़ाइल में सहेजें',
      'savedSizeSuccess': 'आकार आपकी प्रोफ़ाइल में सहेज लिया गया!',
      'calibratedSuccess': 'स्क्रीन भौतिक सटीकता के साथ कैलिब्रेट हो गई!',
      'changeLanguage': 'भाषा बदलें / Change Language',
      'changeLanguageSubtitle': 'English, हिंदी या ગુજરાતી चुनें',
      'followUpWhatsApp': 'व्हाट्सएप पर संपर्क करें',
      'enquiryDetails': 'पूछताछ का विवरण',
      'liveRates': 'लाइव धातु भाव',
      'todayRates': 'आज के सोने और चांदी के भाव',
      'ratePerGram': 'प्रति ग्राम',
      'rateCalculator': 'सोना और चांदी भाव कैलकुलेटर',
      'calculate': 'हिसाब करें',
      'gold24k': '24K शुद्ध सोना',
      'gold22k': '22K हॉलमार्क सोना',
      'silver999': 'चांदी',
      'diwaliSale': 'दिवाली सेल',
      'festiveOffer': 'उत्सव ऑफर',
      'customOrder': 'कस्टम आभूषण ऑर्डर',
      'referencePhotoTitle': '1. संदर्भ डिजाइन फोटो (वैकल्पिक)',
      'referencePhotoDesc': 'जो आभूषण आप बनवाना चाहते हैं उसकी तस्वीर या स्केच जोड़ें।',
      'specificationsTitle': '2. विवरण और साइज',
      'preferredMetal': 'पसंदीदा धातु और शुद्धता',
      'sizeDimensions': 'साइज / माप',
      'approxBudget': 'अनुमानित बजट (वैकल्पिक)',
      'detailedRequirements': 'विस्तृत विवरण / विशेष निर्देश',
      'sendCustomOrderWhatsApp': 'व्हाट्सएप पर कस्टम ऑर्डर अनुरोध भेजें',
      'bookVisitTitle': 'शोरूम विज़िट बुक करें',
      'selectDate': 'तारीख चुनें',
      'selectTimeSlot': 'समय स्लॉट चुनें',
      'notesOptional': 'विशेष अनुरोध / नोट्स (वैकल्पिक)',
      'sendVisitRequestWhatsApp': 'व्हाट्सएप पर विज़िट अनुरोध भेजें',
      'visitOurStore': 'हमारे स्टोर पर पधारें',
      'getDirections': 'रास्ता देखें',
      'callStore': 'स्टोर पर कॉल करें',
      'storeTimings': 'स्टोर का समय',
      'followInstagram': 'इंस्टाग्राम पर फॉलो करें',
      'storeAddress': 'स्टोर का पता',
      'adminPanel': 'एडमिन पैनल',
      'manageStore': 'अपने स्टोर और संग्रह का प्रबंधन करें',
      'products': 'आभूषण उत्पाद',
      'categories': 'कैटेगरीज',
      'banners': 'बैनर्स',
      'appSettings': 'ऐप सेटिंग्स',
      'appBranding': 'ऐप ब्रांडिंग',
      'insights': 'इनसाइट्स',
      'metalRates': 'दैनिक धातु भाव',
      'customerEnquiries': 'ग्राहक पूछताछ',
    },

    // Gujarati (ગુજરાતી)
    'gu': {
      'appTagline': 'શાશ્વત સૌંદર્ય અને વિશ્વાસ',
      'login': 'લૉગિન',
      'register': 'રજીસ્ટર કરો',
      'logout': 'લૉગ આઉટ',
      'cancel': 'રદ કરો',
      'save': 'સાચવો',
      'delete': 'કાઢી નાખો',
      'edit': 'ફેરફાર કરો',
      'add': 'ઉમેરો',
      'retry': 'ફરી પ્રયાસ કરો',
      'clear': 'સાફ કરો',
      'apply': 'લાગુ કરો',
      'viewAll': 'બધા જુઓ',
      'all': 'બધા',
      'close': 'બંધ કરો',
      'confirm': 'ખાતરી કરો',
      'ok': 'બરાબર',
      'signOut': 'સાઇન આઉટ',
      'confirmLogout': 'શું તમે ખરેખર લૉગ આઉટ કરવા માંગો છો?',
      'confirmResetData': 'ડેમો ડેટા ફરી સેટ કરવો છે?',
      'resetDataDesc': 'આનાથી ૧૮ અસલી દાગીના સાથે તમામ ઉત્પાદનો, કેટેગરીઝ અને બેનર્સ ફરીથી સેટ થઈ જશે.',
      'seedData': 'ડેટા ફરી સેટ કરો',
      'bulkPriceAdjustment': 'જથ્થાબંધ ભાવ ફેરફાર',
      'bulkPriceSubtitle': 'સંગ્રહમાં ભાવ એકસાથે અપડેટ કરો',
      'increase': 'વધારો (+)',
      'discount': 'વળતર (-)',
      'adjustmentPercentage': 'ફેરફાર ટકાવારી (%)',
      'targetCategory': 'કેટેગરી (વૈકલ્પિક)',
      'applyBulkPrice': 'ભાવ ફેરફાર લાગુ કરો',
      'allCategories': 'બધી કેટેગરીઝ',
      'cardOutlineHint': 'નીચે આપેલી રૂપરેખા પર કોઈપણ સામાન્ય કાર્ડ મૂકો. કાર્ડની પહોળાઈ (૮૫.૬ મીમી) મેળવવા સ્લાઇડર ખસેડો.',
      'coinOutlineHint': 'નીચે આપેલા વર્તુળ પર ₹૫ નો સિક્કો મૂકો. સિક્કાના વ્યાસ (૨૩.૦ મીમી) મુજબ સ્લાઇડર ખસેડો.',
      'placeCardHere': 'અહીં કાર્ડ મૂકો\n(૮૫.૬ મીમી)',
      'placeCoinHere': 'અહીં ₹૫ નો સિક્કો મૂકો\n(૨૩.૦ મીમી)',
      'creditOrDebitCard': 'ક્રેડિટ / ડેબિટ કાર્ડ',
      'fiveRupeeCoin': '₹૫ નો સિક્કો',
      'lockAndSaveCalibration': 'સ્ક્રીન કેલિબ્રેશન સાચવો ✓',
      'resetCalibration': 'ડિફોલ્ટ કેલિબ્રેશન ફરી સેટ કરો',
      'visibleToCustomers': 'ગ્રાહકોને દેખાશે',
      'hidden': 'છુપાયેલ',
      'activeOnHome': 'હોમ પર સક્રિય',
      'editProfile': 'પ્રોફાઇલ સંપાદિત કરો',
      'changePassword': 'પાસવર્ડ બદલો',
      'somethingWentWrong': 'કંઈક ખોટું થયું. કૃપા કરી ફરી પ્રયાસ કરો.',
      'noData': 'હજુ કશું નથી',
      'loading': 'લોડ થઈ રહ્યું છે...',
      'pleaseWait': 'કૃપા કરીને રાહ જુઓ...',
      'outOfStock': 'સ્ટોક ખલાસ',
      'inStock': 'સ્ટોકમાં ઉપલબ્ધ',
      'success': 'સફળ',
      'error': 'ભૂલ',
      'welcomeBack': 'સ્વાગત છે',
      'loginToContinue': 'તમારું દાગીના વૉલ્ટ જોવા માટે લૉગિન કરો',
      'email': 'ઈમેલ સરનામું',
      'password': 'પાસવર્ડ',
      'confirmPassword': 'પાસવર્ડની ખાતરી કરો',
      'fullName': 'પૂરું નામ',
      'phoneNumber': 'ફોન નંબર (વૈકલ્પિક)',
      'forgotPassword': 'પાસવર્ડ ભૂલી ગયા?',
      'dontHaveAccount': 'ખાતું નથી?',
      'alreadyHaveAccount': 'પહેલેથી ખાતું છે?',
      'createAccount': 'ખાતું બનાવો',
      'joinExclusivity': 'અમારા ખાસ જ્વેલરી પરિવારમાં જોડાઓ',
      'continueWithGoogle': 'ગૂગલ સાથે ચાલુ રાખો',
      'navHome': 'હોમ',
      'navShop': 'શોપ',
      'navCart': 'કાર્ટ',
      'navProfile': 'પ્રોફાઇલ',
      'shopByCategory': 'કેટેગરી મુજબ ખરીદો',
      'featuredCollection': 'સ્પેશિયલ કલેક્શન',
      'searchProducts': 'દાગીના, ધાતુ અથવા નામ શોધો...',
      'addToCart': 'કાર્ટમાં ઉમેરો',
      'chatOnWhatsApp': 'વોટ્સએપ પર ચેટ કરો',
      'myWishlist': 'મારી વિશલિસ્ટ',
      'specifications': 'દાગીના વિગત',
      'description': 'વિગતવાર વર્ણન',
      'jewelleryCollection': 'દાગીના કલેક્શન',
      'filterCollection': 'ફિલ્ટર કરો',
      'sortCollection': 'ક્રમબદ્ધ કરો',
      'itemsFound': 'દાગીના મળ્યા',
      'itemFound': 'દાગીનો મળ્યો',
      'collectionEmpty': 'કલેક્શન ખાલી છે',
      'priceRange': 'કિંમત શ્રેણી',
      'material': 'ધાતુ / મટીરીયલ',
      'inStockOnly': 'ફક્ત સ્ટોકમાં ઉપલબ્ધ',
      'resetFilters': 'ફિલ્ટર કાઢી નાખો',
      'applyFilters': 'ફિલ્ટર લાગુ કરો',
      'whatsappEnquiry': 'વોટ્સએપ પૂછપરછ',
      'enquireWhatsApp': 'વોટ્સએપ પર પૂછપરછ કરો',
      'selectSize': 'સાઇઝ / માપ પસંદ કરો',
      'ringSizeGuide': 'વીંટી સાઇઝ ગાઇડ',
      'dropAHint': 'હિન્ટ આપો (Drop a Hint)',
      'dropAHintSubtitle': 'કોઈ ખાસ વ્યક્તિને જણાવો કે તમને આ દાગીનો ગમ્યો છે',
      'customisePiece': 'તમારા દાગીનાને કસ્ટમાઇઝ કરો',
      'metalColor': 'ધાતુનો કલર / શેડ',
      'purityKarat': 'સોનાની શુદ્ધતા (કેરેટ)',
      'diamondOption': 'હીરાની ગુણવત્તા',
      'jewelleryCare': 'દાગીનાની કાળજી માટે ટિપ્સ',
      'careAndCleaningTips': 'દાગીનાની સંભાળ અને સફાઈ માટેની ટિપ્સ જુઓ',
      'similarPieces': 'મળતા આવતા દાગીના',
      'recentlyViewed': 'તાજેતરમાં જોયેલા',
      'certified100': '100% પ્રમાણિત',
      'lifetimeExchange': 'લાઇફટાઇમ એક્સચેન્જ',
      'insuredDelivery': 'વીમાકૃત ડિલિવરી',
      'liveRatePriced': 'લાઈવ ભાવ આધારિત',
      'noFeaturedItems': 'હજુ કોઈ ખાસ દાગીના નથી',
      'exploreArrivals': 'અમારા નવા દાગીના કલેક્શન જુઓ.',
      'shoppingBag': 'શોપિંગ બેગ',
      'myCart': 'મારી કાર્ટ',
      'cartEmpty': 'તમારી શોપિંગ બેગ ખાલી છે',
      'browseShop': 'કલેક્શન જુઓ',
      'exploreCollection': 'કલેક્શન જુઓ',
      'cartEmptySubtitle': 'અમારા નવા દાગીના કલેક્શન જુઓ અને તમારા બેગમાં ઉમેરો.',
      'estimatedTotal': 'અંદાજિત કુલ રકમ',
      'sendEnquiryWhatsApp': 'વોટ્સએપ પર પૂછપરછ મોકલો',
      'clearCart': 'કાર્ટ ખાલી કરો',
      'itemUnavailable': 'આ દાગીનો હાલમાં ઉપલબ્ધ નથી',
      'myProfile': 'મારી પ્રોફાઇલ',
      'valuedCustomer': 'પ્રિય ગ્રાહક',
      'emailAddress': 'ઈમેલ સરનામું',
      'notProvided': 'આપેલ નથી',
      'enquiryHistory': 'મારી પૂછપરછ અને ક્વોટ્સ',
      'enquiryHistorySubtitle': 'પૂછપરછ કરેલા દાગીના અને ક્વોટ્સ ટ્રેક કરો',
      'requestCustomJewellery': 'કસ્ટમ દાગીના ઓર્ડર',
      'requestCustomSubtitle': 'કસ્ટમ દાગીના માટે ફોટો અપલોડ કરો',
      'bookShowroomVisit': 'શોરૂમ મુલાકાત બુક કરો',
      'bookVisitSubtitle': 'સ્ટોર મુલાકાત માટે તારીખ અને સમય પસંદ કરો',
      'storeInfo': 'સ્ટોર સરનામું અને સંપર્ક',
      'storeInfoSubtitle': 'સરનામું, સ્ટોર સમય અને કૉલિંગ વિગત',
      'ringSizeGuideSubtitle': 'તમારી ચોક્કસ વીંટી અથવા બંગડીનું માપ જાણો',
      'jewelleryCareSubtitle': 'ચમક જાળવી રાખવા અને સાફ-સફાઈની સલાહ',
      'oldGoldCalculator': 'જૂના સોનાનું કેલ્ક્યુલેટર',
      'oldGoldCalculatorSubtitle': 'જૂના દાગીનાની તાત્કાલિક એક્સચેન્જ કિંમત જાણો',
      'giftFinder': 'ગિફ્ટ ફાઇન્ડર (Gift Finder)',
      'giftFinderSubtitle': '૩૦ સેકન્ડમાં મેળવો યોગ્ય ગિફ્ટ',
      'findGifts': 'ગિફ્ટ શોધો',
      'priceAlerts': 'સોનાના ભાવનું એલર્ટ',
      'priceAlertsSubtitle': 'સોના કે ચાંદીના ભાવ ઘટે ત્યારે એલર્ટ મેળવો',
      'setRateAlert': 'ભાવ ઘટવાનું એલર્ટ સેટ કરો',
      'targetRate': 'ટાર્ગેટ ભાવ',
      'currentRate': 'હાલનો લાઈવ ભાવ',
      'alertWhenBelow': 'આ ભાવે અથવા તેનાથી નીચે જાય ત્યારે એલર્ટ કરો',
      'activeAlerts': 'મારા સક્રિય એલર્ટ',
      'noActiveAlerts': 'હજુ કોઈ ભાવ એલર્ટ સેટ નથી',
      'noAlertsSubtitle': 'તમારી મનપસંદ ધાતુના ભાવ ઘટવાની જાણ મેળવવા ટાર્ગેટ ભાવ સેટ કરો.',
      'targetReached': 'ટાર્ગેટ ભાવ પહોંચી ગયો! 🎉',
      'alertCreated': 'ભાવ એલર્ટ સફળતાપૂર્વક સેટ થઈ ગયું!',
      'alertDeleted': 'એલર્ટ કાઢી નાખવામાં આવ્યું',
      'jewelleryVault': 'દાગીના વોલ્ટ અને હોલમાર્ક',
      'jewelleryVaultSubtitle': 'પોર્ટફોલિયો મૂલ્યાંકન ટ્રેક કરો અને હોલમાર્ક ચકાસો',
      'myVault': 'મારી વોલ્ટ',
      'verifyHallmark': 'હોલમાર્ક / સર્ટિફિકેટ ચકાસો',
      'addToVault': 'વોલ્ટમાં દાગીનો ઉમેરો',
      'vaultEmpty': 'તમારી દાગીના વોલ્ટ ખાલી છે',
      'vaultEmptySubtitle': 'લાઇવ સોના-ચાંદીના ભાવ મુજબ સાચું મૂલ્ય જાણવા તમારા દાગીના ઉમેરો.',
      'huidNumber': '૬-અક્ષરનો બીઆઈએસ HUID',
      'certVerified': 'સર્ટિફિકેટ પ્રમાણિત છે ✓',
      'portfolioValue': 'કુલ પોર્ટફોલિયો મૂલ્ય',
      'occasionReminders': 'અવસર અને એનિવર્સરી રિમાઇન્ડર',
      'occasionRemindersSubtitle': 'એનિવર્સરી, જન્મદિવસ કે શુભ મુહૂર્ત ક્યારેય ન ભૂલો',
      'addMilestone': 'અવસર / તારીખ ઉમેરો',
      'upcomingMilestones': 'આગામી અવસરો',
      'noReminders': 'હજુ કોઈ તારીખ સેટ નથી',
      'noRemindersSubtitle': 'સમયસર દાગીના ગિફ્ટ કરવા માટે એનિવર્સરી અને જન્મદિવસ સાચવો.',
      'daysLeft': 'દિવસ બાકી',
      'festiveDates': 'સોનું ખરીદવાના શુભ મુહૂર્ત',
      'goldSavingsScheme': 'માસિક સુવર્ણ બચત યોજના',
      'goldSavingsSubtitle': '11+1 યોજના: 11 મહિના જમા કરો અને 12મો મહિનો જ્વેલ ઓરા તરફથી મફત મેળવો',
      'schemeCalculator': 'યોજના કેલ્ક્યુલેટર',
      'myActivePlan': 'મારી સક્રિય યોજના',
      'monthlyDeposit': 'માસિક બચત રકમ',
      'customerPays': 'તમે ચૂકવશો (11 મહિના)',
      'storeBonus': 'જ્વેલ ઓરા બોનસ (1 મહિનો મફત)',
      'totalMaturity': 'પાકતી મુદતે કુલ દાગીના ખરીદી મૂલ્ય',
      'enrollScheme': 'સુવર્ણ બચત યોજના શરૂ કરો',
      'accumulatedGold': 'અંદાજિત જમા સોનું',
      'installmentProgress': 'હપ્તાની પ્રગતિ',
      'payInstallment': 'માસિક હપ્તો નોંધો',
      'noActivePlan': 'કોઈ સક્રિય બચત યોજના નથી',
      'noActivePlanSubtitle': '1 મહિનો મફત હપ્તો મેળવવા આજે જ માસિક સુવર્ણ બચત યોજના શરૂ કરો!',
      'savingsBenefitBadge': '100% 12મા મહિનાનું બોનસ',
      'videoShopping': 'લાઇવ વિડીયો શોપિંગ',
      'videoShoppingSubtitle': 'જ્વેલરી સ્ટાઈલિસ્ટ સાથે 1-ઓન-1 વર્ચ્યુઅલ પરામર્શ બુક કરો',
      'bookVideoCall': 'લાઇવ વિડીયો કોલ બુક કરો',
      'selectStylistTopic': 'દાગીના કેટેગરી પસંદ કરો',
      'consultationLanguage': 'પરામર્શની ભાષા',
      'videoPlatform': 'વિડીયો કોલિંગ માધ્યમ',
      'myAppointments': 'મારી વિડીયો મુલાકાતો',
      'noAppointments': 'કોઈ આગામી વિડીયો મુલાકાત નથી',
      'diamondGuide': 'હીરા 4Cs ગાઈડ',
      'diamondGuideSubtitle': 'ઇન્ટરેક્ટિવ સિમ્યુલેટર સાથે કટ, કલર, ક્લેરિટી અને કેરેટ શીખો',
      'cut': 'કટ (ઘાટ)',
      'color': 'કલર (રંગ)',
      'clarity': 'ક્લેરિટી (શુદ્ધતા)',
      'caratWeight': 'કેરેટ વજન',
      'estDiamondValue': 'અંદાજિત હીરા મૂલ્ય',
      'diamondMillimeter': 'વ્યાસ (હાથ પર માપ)',
      'exploreSolitaires': 'સોલિટેર કલેક્શન જુઓ',
      'bridalPlanner': 'લગ્ન દાગીના અને બજેટ આયોજક',
      'bridalPlannerSubtitle': 'લગ્ન પ્રસંગો અનુસાર દાગીના અને બજેટનું આયોજન કરો',
      'weddingCeremonies': 'લગ્ન પ્રસંગો',
      'totalWeddingBudget': 'કુલ દાગીના બજેટ',
      'budgetSpent': 'ખરીદાયેલ / ખર્ચ',
      'budgetRemaining': 'બાકી બજેટ',
      'bridalChecklist': 'દુલ્હન દાગીના યાદી',
      'addBridalPiece': 'નવો દાગીનો ઉમેરો',
      'exportTrousseauWhatsApp': 'વોટ્સએપ પર શેર કરો',
      'ringBangleSizer': 'સ્ક્રીન રિંગ અને બંગડી માપક',
      'calibrateScreen': 'સ્ક્રીન કેલિબ્રેશન (ચોક્કસ માપ)',
      'saveSizeToProfile': 'માપ પ્રોફાઇલમાં સાચવો',
      'savedSizeSuccess': 'માપ તમારી પ્રોફાઇલમાં સાચવવામાં આવ્યું!',
      'calibratedSuccess': 'સ્ક્રીન ભૌતિક ચોકસાઈ સાથે કેલિબ્રેટ થઈ ગઈ!',
      'changeLanguage': 'ભાષા બદલો / Change Language',
      'changeLanguageSubtitle': 'English, हिंदी અથવા ગુજરાતી પસંદ કરો',
      'followUpWhatsApp': 'વોટ્સએપ પર સંપર્ક કરો',
      'enquiryDetails': 'પૂછપરછ વિગત',
      'liveRates': 'લાઇવ સોના-ચાંદીના ભાવ',
      'todayRates': 'આજના સોના-ચાંદીના ભાવ',
      'ratePerGram': 'પ્રતિ ગ્રામ',
      'rateCalculator': 'સોના-ચાંદી ભાવ કેલ્ક્યુલેટર',
      'calculate': 'હિસાબ કરો',
      'gold24k': '24K શુદ્ધ સોનું',
      'gold22k': '22K હોલમાર્ક સોનું',
      'silver999': 'ચાંદી',
      'diwaliSale': 'દિવાળી સેલ',
      'festiveOffer': 'ઉત્સવ ઑફર',
      'customOrder': 'કસ્ટમ દાગીના ઓર્ડર',
      'referencePhotoTitle': '1. સંદર્ભ ફોટો (વૈકલ્પિક)',
      'referencePhotoDesc': 'જે દાગીનો બનાવવો હોય તેનો ફોટો અથવા સ્કેચ જોડો.',
      'specificationsTitle': '2. વિગત અને સાઇઝ',
      'preferredMetal': 'પસંદગીની ધાતુ અને શુદ્ધતા',
      'sizeDimensions': 'સાઇઝ / માપ',
      'approxBudget': 'અંદાજિત બજેટ (વૈકલ્પિક)',
      'detailedRequirements': 'વિગતવાર જરૂરિયાત / ખાસ નોંધ',
      'sendCustomOrderWhatsApp': 'વોટ્સએપ પર કસ્ટમ ઓર્ડર વિનંતી મોકલો',
      'bookVisitTitle': 'શોરૂમ મુલાકાત બુક કરો',
      'selectDate': 'તારીખ પસંદ કરો',
      'selectTimeSlot': 'સમય સ્લોટ પસંદ કરો',
      'notesOptional': 'ખાસ વિનંતી / નોંધ (વૈકલ્પિક)',
      'sendVisitRequestWhatsApp': 'વોટ્સએપ પર મુલાકાત વિનંતી મોકલો',
      'visitOurStore': 'અમારા સ્ટોરની મુલાકાત લો',
      'getDirections': 'રસ્તો જુઓ',
      'callStore': 'સ્ટોર પર કોલ કરો',
      'storeTimings': 'શોરૂમનો સમય',
      'followInstagram': 'ઇન્સ્ટાગ્રામ પર ફોલો કરો',
      'storeAddress': 'સ્ટોરનું સરનામું',
      'adminPanel': 'એડમિન પેનલ',
      'manageStore': 'તમારા સ્ટોર અને કલેક્શનનું સંચાલન કરો',
      'products': 'દાગીના ઉત્પાદનો',
      'categories': 'કેટેગરીઝ',
      'banners': 'બેનર્સ',
      'appSettings': 'એપ સેટિંગ્સ',
      'appBranding': 'એપ બ્રાન્ડિંગ',
      'insights': 'ઇનસાઇટ્સ',
      'metalRates': 'દૈનિક ધાતુ ભાવ',
      'customerEnquiries': 'ગ્રાહક પૂછપરછ',
    },
  };
}