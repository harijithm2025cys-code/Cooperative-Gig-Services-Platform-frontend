import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ta'),
  ];

  bool get isTamil => locale.languageCode == 'ta';

  // ---------------------------------------------------------------------------
  // Dictionary Mappings (Tamil + English)
  // ---------------------------------------------------------------------------
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General & App Info
      'app_title': 'Cooperative Gig Services Platform',
      'app_tagline': 'Digitally empowering cooperative workers for household & community services',
      'welcome': 'Welcome',
      'loading': 'Loading...',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'submit': 'Submit',
      'save': 'Save',
      'close': 'Close',
      'back': 'Back',
      'search': 'Search services...',
      'language': 'Language',
      'switch_language': 'Switch Language',
      'english': 'English',
      'tamil': 'தமிழ் (Tamil)',

      // Auth & Roles
      'login': 'Sign In',
      'sign_up': 'Create Account',
      'logout': 'Sign Out',
      'phone_number': 'Phone Number',
      'enter_phone': 'Enter 10-digit mobile number',
      'password': 'Password',
      'enter_password': 'Enter your secure password',
      'full_name': 'Full Name',
      'select_role': 'Select Your Account Type',
      'role_customer': 'Household Customer',
      'role_independent_worker': 'Independent Specialist',
      'role_cooperative_worker': 'Cooperative Member Worker',
      'role_association_head': 'Cooperative Association Head',
      'role_super_admin': 'Federation Super Admin',
      'select_cooperative': 'Select Cooperative Society',
      'auth_failed': 'Authentication failed. Please verify your credentials.',
      'login_success': 'Signed in successfully',
      'register_success': 'Account created successfully',

      // Customer Marketplace & Booking
      'services_marketplace': 'Cooperative Service Marketplace',
      'cooperative_federation': 'Labour Cooperative Federation',
      'fixed_pricing_guarantee': 'Fixed Cooperative Pricing Guarantee',
      'no_surge_pricing': 'No surge pricing • Fair worker remuneration',
      'book_service': 'Book Service',
      'emergency_service': 'Emergency Booking (Immediate Dispatch)',
      'emergency_tag': 'EMERGENCY',
      'service_electrician': 'Electrical & Wiring Specialist',
      'service_plumber': 'Plumbing & Pipefitting',
      'service_mason': 'Masonry & Concrete Works',
      'service_carpenter': 'Carpentry & Woodwork',
      'service_painter': 'Painting & Wall Coating',
      'service_cleaner': 'Deep Sanitation & Cleaning',
      'worker_count': 'Required Worker Count',
      'service_location': 'Service Delivery Location',
      'enter_location': 'Enter house/street address',
      'schedule_time': 'Preferred Service Date & Time',
      'total_estimate': 'Verified Cooperative Tariff',
      'per_worker_rate': 'Rate per worker',
      'proceed_to_payment': 'Proceed to Secure Payment',
      'immediate_help_note': 'Specialist will be dispatched within 15 minutes of payment confirmation.',

      // Payments & Razorpay
      'payment_checkout': 'Razorpay Secure Checkout',
      'payment_pending': 'Payment Pending',
      'payment_captured': 'Payment Successful & Captured',
      'payment_failed': 'Payment Unsuccessful',
      'pay_now': 'Pay with Razorpay',
      'razorpay_test_mode': 'Razorpay Gateway (Test Mode)',
      'verifying_payment': 'Verifying cryptographic payment signature...',
      'payment_required_notice': 'Payment confirmation required prior to cooperative specialist dispatch.',
      'tax_invoice': 'Official Tax Invoice',
      'invoice_id': 'Invoice #',
      'download_invoice': 'Download Tax Invoice',
      'refund_status': 'Refund Status',
      'settlement_status': 'Worker Settlement Status',

      // Dispatch & Booking Lifecycle
      'booking_status': 'Service Lifecycle & Live Status',
      'status_requested': 'Booking Created',
      'status_payment_pending': 'Awaiting Payment',
      'status_matching': 'Matching Cooperative Specialists',
      'status_assigned': 'Worker Assigned',
      'status_accepted': 'Specialist Accepted',
      'status_on_the_way': 'Specialist On The Way',
      'status_arrived': 'Specialist Arrived on Site',
      'status_in_progress': 'Service In Progress',
      'status_completed': 'Service Completed — Awaiting Customer Acceptance',
      'status_confirmed': 'Customer Verified & Confirmed',
      'status_cancelled': 'Booking Cancelled',
      'customer_inspection_title': 'Customer Inspection & Mutual Acceptance',
      'customer_otp_prompt': 'Share this 6-digit confirmation code ONLY after inspecting and approving the work:',
      'enter_completion_otp': 'Enter Customer Confirmation OTP',
      'verify_otp_btn': 'Verify Acceptance OTP',
      'otp_expires_in': 'Code expires in 15 minutes (Max 3 attempts)',
      'rate_service': 'Rate Cooperative Service Quality',
      'star_rating': 'Rating (1 to 5 Stars)',
      'feedback_notes': 'Share your experience with the cooperative...',
      'submit_review': 'Submit Rating & Feedback',

      // Worker Dashboard & Actions
      'worker_portal': 'Specialist Operational Portal',
      'active_assignments': 'Active Assignments',
      'available_status': 'Available for Dispatch',
      'on_duty': 'On Duty',
      'off_duty': 'Off Duty',
      'accept_job': 'Accept Assignment',
      'reject_job': 'Decline',
      'mark_on_the_way': 'Mark "On The Way"',
      'mark_arrived': 'Mark "Arrived on Site"',
      'start_service': 'Start Service',
      'complete_service': 'Complete Service & Request OTP',
      'worker_earnings': 'Welfare & Earnings Summary',
      'monthly_completed': 'Completed Jobs This Month',

      // Association & Admin Dashboards
      'association_dashboard': 'Labour Cooperative Administration',
      'super_admin_dashboard': 'State Federation Central Command',
      'cooperative_roster': 'Worker Society Roster',
      'analytics_tab': 'Operational Analytics',
      'ml_forecast_tab': 'AI Demand & Workforce Forecast',
      'total_revenue': 'Total Federation Turnover',
      'active_workers': 'Active Verified Specialists',
      'total_bookings': 'Total Processed Bookings',
      'complaints_disputes': 'Grievances & Dispute Management',
      'file_complaint': 'Register Grievance',
      'complaint_resolved': 'Grievance Resolved',
      'ml_model_status': 'AI Inference Engine Telemetry',
      'predicted_demand': 'Predicted Service Demand (7 Days)',
      'model_accuracy': 'Ranking Model Precision',

      // Accessibility, Offline & Network
      'network_offline': 'Connection Lost. Operating in resilient offline mode.',
      'realtime_unavailable': 'Live updates temporarily unavailable. Tap to refresh.',
      'safe_error_msg': 'This request could not be completed. Please try again.',
      'validation_error': 'Please check the required fields and correct errors.',
      'contrast_high': 'Accessible High Contrast Mode',
    },

    'ta': {
      // General & App Info
      'app_title': 'கூட்டுறவு கிக் சேவைகள் தளம்',
      'app_tagline': 'வீட்டு மற்றும் சமூக சேவைகளுக்காக கூட்டுறவு தொழிலாளர்களை டிஜிட்டல் முறையில் இணைக்கிறது',
      'welcome': 'நல்வரவு',
      'loading': 'ஏற்றுகிறது...',
      'retry': 'மீண்டும் முயற்சிக்குக',
      'cancel': 'ரத்து செய்க',
      'confirm': 'உறுதி செய்க',
      'submit': 'சமர்ப்பிக்கவும்',
      'save': 'சேமிக்கவும்',
      'close': 'மூடுக',
      'back': 'பின்னே செல்',
      'search': 'சேவைகளைத் தேடுக...',
      'language': 'மொழி',
      'switch_language': 'மொழியை மாற்றவும்',
      'english': 'English (ஆங்கிலம்)',
      'tamil': 'தமிழ்',

      // Auth & Roles
      'login': 'உள்நுழைக',
      'sign_up': 'புதிய கணக்கு தொடங்க',
      'logout': 'வெளியேறு',
      'phone_number': 'கைபேசி எண்',
      'enter_phone': '10 இலக்க மொபைல் எண்ணை உள்ளிடுக',
      'password': 'கடவுச்சொல்',
      'enter_password': 'பாதுகாப்பான கடவுச்சொல்லை உள்ளிடுக',
      'full_name': 'முழு பெயர்',
      'select_role': 'கணக்கு வகையைத் தேர்ந்தெடுக்கவும்',
      'role_customer': 'வீட்டு வாடிக்கையாளர்',
      'role_independent_worker': 'சுயாதீன நிபுணர்',
      'role_cooperative_worker': 'கூட்டுறவு சங்க பணியாளர்',
      'role_association_head': 'கூட்டுறவு சங்க தலைவர்',
      'role_super_admin': 'கூட்டமைப்பு தலைமை நிர்வாகி',
      'select_cooperative': 'கூட்டுறவு சங்கத்தைத் தேர்ந்தெடுக்கவும்',
      'auth_failed': 'உள்நுழைவு தோல்வியடைந்தது. விவரங்களைச் சரிபார்க்கவும்.',
      'login_success': 'வெற்றிகரமாக உள்நுழைந்தது',
      'register_success': 'கணக்கு வெற்றிகரமாக உருவாக்கப்பட்டது',

      // Customer Marketplace & Booking
      'services_marketplace': 'கூட்டுறவு சேவை அங்காடி',
      'cooperative_federation': 'தொழிலாளர் கூட்டுறவு கூட்டமைப்பு',
      'fixed_pricing_guarantee': 'நிர்ணயிக்கப்பட்ட கூட்டுறவு கட்டண உத்திரவாதம்',
      'no_surge_pricing': 'அதிக கட்டணம் இல்லை • நியாயமான தொழிலாளர் கூலி',
      'book_service': 'சேவையை முன்பதிவு செய்க',
      'emergency_service': 'அவசர முன்பதிவு (உடனடி உதவி)',
      'emergency_tag': 'அவசரம்',
      'service_electrician': 'மின்சார மற்றும் வயரிங் நிபுணர்',
      'service_plumber': 'குழாய் மற்றும் பிளம்பிங் பணி',
      'service_mason': 'கொத்தனார் மற்றும் கட்டுமான பணி',
      'service_carpenter': 'தச்சர் மற்றும் மரவேலை',
      'service_painter': 'வர்ணம் பூசுதல் பணி',
      'service_cleaner': 'முழுமையான தூய்மை பணி',
      'worker_count': 'தேவையான பணியாளர்களின் எண்ணிக்கை',
      'service_location': 'சேவை வழங்கப்படும் இடம்',
      'enter_location': 'வீட்டு முகவரியை உள்ளிடுக',
      'schedule_time': 'தேவையான தேதி மற்றும் நேரம்',
      'total_estimate': 'சரிபார்க்கப்பட்ட கூட்டுறவு கட்டணம்',
      'per_worker_rate': 'ஒரு பணியாளருக்கான கட்டணம்',
      'proceed_to_payment': 'பணம் செலுத்த தொடர்க',
      'immediate_help_note': 'பணம் செலுத்திய 15 நிமிடங்களுக்குள் கூட்டுறவு நிபுணர் அனுப்பி வைக்கப்படுவார்.',

      // Payments & Razorpay
      'payment_checkout': 'Razorpay பாதுகாப்பான கட்டண செலுத்துகை',
      'payment_pending': 'பணம் நிலுவையில் உள்ளது',
      'payment_captured': 'பணம் செலுத்துதல் வெற்றிகரமாக முடிந்தது',
      'payment_failed': 'பணம் செலுத்துதல் தோல்வியடைந்தது',
      'pay_now': 'Razorpay மூலம் பணம் செலுத்துக',
      'razorpay_test_mode': 'Razorpay கட்டண தளம் (சோதனை முறை)',
      'verifying_payment': 'கிரிப்டோகிராஃபிக் கட்டண கையொப்பம் சரிபார்க்கப்படுகிறது...',
      'payment_required_notice': 'பணியாளர் ஒதுக்கீட்டிற்கு முன் பணம் செலுத்துதல் கட்டாயமாகும்.',
      'tax_invoice': 'அதிகாரப்பூர்வ வரி விலைப்பட்டியல்',
      'invoice_id': 'விலைப்பட்டியல் எண் #',
      'download_invoice': 'விலைப்பட்டியலை பதிவிறக்குக',
      'refund_status': 'பணம் திரும்பப்பெறும் நிலை',
      'settlement_status': 'தொழிலாளர் பணப்பட்டுவாடா நிலை',

      // Dispatch & Booking Lifecycle
      'booking_status': 'சேவை நிலை மற்றும் நேரலை கண்காணிப்பு',
      'status_requested': 'முன்பதிவு உருவாக்கப்பட்டது',
      'status_payment_pending': 'பணம் செலுத்த காத்திருக்கிறது',
      'status_matching': 'கூட்டுறவு பணியாளர் தேர்ந்தெடுக்கப்படுகிறார்',
      'status_assigned': 'பணியாளர் ஒதுக்கப்பட்டார்',
      'status_accepted': 'பணியாளர் ஏற்றுக்கொண்டார்',
      'status_on_the_way': 'பணியாளர் வந்து கொண்டிருக்கிறார்',
      'status_arrived': 'பணியாளர் வந்து சேர்ந்தார்',
      'status_in_progress': 'பணி நடைபெறுகிறது',
      'status_completed': 'பணி முடிந்தது — வாடிக்கையாளர் சரிபார்ப்பிற்கு காத்திருக்கிறது',
      'status_confirmed': 'வாடிக்கையாளர் சரிபார்த்து உறுதி செய்தார்',
      'status_cancelled': 'முன்பதிவு ரத்து செய்யப்பட்டது',
      'customer_inspection_title': 'வாடிக்கையாளர் ஆய்வு மற்றும் ஏற்பு சரிபார்ப்பு',
      'customer_otp_prompt': 'வேலையை முழுமையாக ஆய்வு செய்து திருப்தி அடைந்த பின் மட்டுமே இந்த 6 இலக்க OTP குறியீட்டைப் பகிரவும்:',
      'enter_completion_otp': 'வாடிக்கையாளர் உறுதிப்படுத்தல் OTP குறியீட்டை உள்ளிடுக',
      'verify_otp_btn': 'ஏற்பு OTP சரிபார்க்கவும்',
      'otp_expires_in': 'குறியீடு 15 நிமிடங்களில் காலாவதியாகும் (அதிகபட்சம் 3 முயற்சிகள்)',
      'rate_service': 'கூட்டுறவு சேவையின் தரத்தை மதிப்பிடுக',
      'star_rating': 'மதிப்பீடு (1 முதல் 5 நட்சத்திரங்கள்)',
      'feedback_notes': 'கூட்டுறவு உடனான உங்கள் அனுபவத்தைப் பகிரவும்...',
      'submit_review': 'மதிப்பீட்டை சமர்ப்பிக்கவும்',

      // Worker Dashboard & Actions
      'worker_portal': 'பணியாளர் கட்டுப்பாட்டு தளம்',
      'active_assignments': 'நடப்பு பணிகள்',
      'available_status': 'பணிக்கு தயார்',
      'on_duty': 'பணியில் உள்ளார்',
      'off_duty': 'விடுப்பில் உள்ளார்',
      'accept_job': 'பணியை ஏற்கவும்',
      'reject_job': 'நிராகரிக்கவும்',
      'mark_on_the_way': '"வந்து கொண்டிருக்கிறேன்" எனப் பதிவிடுக',
      'mark_arrived': '"வந்து சேர்ந்தேன்" எனப் பதிவிடுக',
      'start_service': 'பணியைத் தொடங்குக',
      'complete_service': 'பணியை முடித்து OTP கோருக',
      'worker_earnings': 'நலன்புரி மற்றும் வருவாய் விவரம்',
      'monthly_completed': 'இம்மாதம் முடிக்கப்பட்ட பணிகள்',

      // Association & Admin Dashboards
      'association_dashboard': 'தொழிலாளர் கூட்டுறவு நிர்வாகம்',
      'super_admin_dashboard': 'மாநில கூட்டமைப்பு தலைமை கட்டுப்பாட்டகம்',
      'cooperative_roster': 'தொழிலாளர் கூட்டுறவு பட்டியல்',
      'analytics_tab': 'செயல்பாட்டு பகுப்பாய்வு',
      'ml_forecast_tab': 'AI தேவை மற்றும் பணியாளர் முன்னறிவிப்பு',
      'total_revenue': 'மொத்த கூட்டமைப்பு வருவாய்',
      'active_workers': 'செயலில் உள்ள சரிபார்க்கப்பட்ட தொழிலாளர்கள்',
      'total_bookings': 'மொத்த முன்பதிவுகள்',
      'complaints_disputes': 'புகார்கள் மற்றும் சர்ச்சை தீர்வு',
      'file_complaint': 'புகார் பதிவு செய்க',
      'complaint_resolved': 'புகார் தீர்க்கப்பட்டது',
      'ml_model_status': 'AI மாதிரி நிலை மற்றும் துல்லியம்',
      'predicted_demand': 'எதிர்பார்க்கப்படும் சேவைத் தேவை (7 நாட்கள்)',
      'model_accuracy': 'வரிசைப்படுத்துதல் மாதிரி துல்லியம்',

      // Accessibility, Offline & Network
      'network_offline': 'இணைய இணைப்பு இல்லை. ஆஃப்லைன் முறையில் இயங்குகிறது.',
      'realtime_unavailable': 'நேரலை புதுப்பிப்புகள் தற்காலிகமாக கிடைக்கவில்லை. புதுப்பிக்க தொடவும்.',
      'safe_error_msg': 'கோரிக்கை நிறைவேற்றப்படவில்லை. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.',
      'validation_error': 'தேவையான தகவல்களை சரியாக உள்ளிடவும்.',
      'contrast_high': 'தெளிவான பார்வை முறை',
    }
  };

  // ---------------------------------------------------------------------------
  // Generic Lookup & Parameterized Interpolation
  // ---------------------------------------------------------------------------
  String translate(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Common Getters for direct, typed convenience
  String get appTitle => translate('app_title');
  String get appTagline => translate('app_tagline');
  String get welcome => translate('welcome');
  String get loading => translate('loading');
  String get retry => translate('retry');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get submit => translate('submit');
  String get language => translate('language');
  String get english => translate('english');
  String get tamil => translate('tamil');
  String get switchLanguage => translate('switch_language');

  // Auth Getters
  String get login => translate('login');
  String get signUp => translate('sign_up');
  String get logout => translate('logout');
  String get phoneNumber => translate('phone_number');
  String get password => translate('password');
  String get fullName => translate('full_name');
  String get selectRole => translate('select_role');

  // Customer & Marketplace Getters
  String get servicesMarketplace => translate('services_marketplace');
  String get fixedPricingGuarantee => translate('fixed_pricing_guarantee');
  String get bookService => translate('book_service');
  String get emergencyService => translate('emergency_service');
  String get workerCount => translate('worker_count');
  String get serviceLocation => translate('service_location');
  String get totalEstimate => translate('total_estimate');
  String get proceedToPayment => translate('proceed_to_payment');

  // Payments & Lifecycle Getters
  String get paymentPending => translate('payment_pending');
  String get paymentCaptured => translate('payment_captured');
  String get payNow => translate('pay_now');
  String get taxInvoice => translate('tax_invoice');
  String get bookingStatus => translate('booking_status');
  String get workerAssigned => translate('status_assigned');
  String get onTheWay => translate('status_on_the_way');
  String get arrived => translate('status_arrived');
  String get inProgress => translate('status_in_progress');
  String get completed => translate('status_completed');
  String get customerInspectionTitle => translate('customer_inspection_title');
  String get customerOtpPrompt => translate('customer_otp_prompt');
  String get verifyOtpBtn => translate('verify_otp_btn');
  String get rateService => translate('rate_service');

  // Worker Getters
  String get workerPortal => translate('worker_portal');
  String get activeAssignments => translate('active_assignments');
  String get acceptJob => translate('accept_job');
  String get rejectJob => translate('reject_job');
  String get markOnTheWay => translate('mark_on_the_way');
  String get markArrived => translate('mark_arrived');
  String get startService => translate('start_service');
  String get completeService => translate('complete_service');
  String get workerEarnings => translate('worker_earnings');

  // Admin & ML Getters
  String get associationDashboard => translate('association_dashboard');
  String get superAdminDashboard => translate('super_admin_dashboard');
  String get analyticsTab => translate('analytics_tab');
  String get mlForecastTab => translate('ml_forecast_tab');
  String get predictedDemand => translate('predicted_demand');

  // Errors & Offline
  String get networkOffline => translate('network_offline');
  String get realtimeUnavailable => translate('realtime_unavailable');
  String get safeErrorMsg => translate('safe_error_msg');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
