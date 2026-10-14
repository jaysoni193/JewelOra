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
  static String get signOut => tr('signOut');
  static String get confirmLogout => tr('confirmLogout');

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
      'signOut': 'Sign Out',
      'confirmLogout': 'Are you sure you want to log out?',
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
      'signOut': 'साइन आउट',
      'confirmLogout': 'क्या आप निश्चित रूप से लॉग आउट करना चाहते हैं?',
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
      'signOut': 'સાઇન આઉટ',
      'confirmLogout': 'શું તમે ખરેખર લૉગ આઉટ કરવા માંગો છો?',
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