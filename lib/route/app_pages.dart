import 'package:get/get.dart';

import 'package:bd_shope_combined/features/buyer/onboarding/splash_screen.dart';
import 'package:bd_shope_combined/features/buyer/onboarding/onboarding_flow.dart';
import 'package:bd_shope_combined/features/role_selection/role_selection_screen.dart';
import 'package:bd_shope_combined/features/buyer/home/home_screen/home_screen.dart';

// Auth screens
import 'package:bd_shope_combined/features/buyer/auth/login_screen/login_screen.dart';
import 'package:bd_shope_combined/features/buyer/auth/register_screen/register_screen.dart';
import 'package:bd_shope_combined/features/buyer/auth/otp_screen/otp_screen.dart';
import 'package:bd_shope_combined/features/buyer/auth/forgot_password_screen/forgot_password_screen.dart';
import 'package:bd_shope_combined/features/buyer/auth/create_password_screen/create_password_screen.dart';

// Seller screens
import 'package:bd_shope_combined/features/seller/auth/login/presentation/login_screen.dart' as seller_login;
import 'package:bd_shope_combined/features/seller/auth/register/presentation/register_screen.dart' as seller_register;
import 'package:bd_shope_combined/features/seller/home/presentation/home_screen.dart' as seller_home;

// Buyer screens
import 'package:bd_shope_combined/features/buyer/coustomer/home_screen/buyer_home_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/search_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/product_list_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/product_detail_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/category_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/nearby_sellers_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/notifications_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/buyer_profile_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/edit_profile_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/seller_profile_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/top_sellers_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/call/call_screen.dart';
import 'package:bd_shope_combined/features/buyer/chat/chat_conversation_screen.dart';
import 'package:bd_shope_combined/features/buyer/payment/payment_invoice_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/invoice_details_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/privacy_policy_screen.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/about_screen.dart';

import 'app_routes.dart';
export 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashScreen()),
    GetPage(name: Routes.ONBOARDING, page: () => const OnboardingFlow()),
    GetPage(name: Routes.ROLE_SELECTION, page: () => const RoleSelectionScreen()),
    GetPage(name: Routes.HOME, page: () => const HomeScreen()),
    // Auth routes
    GetPage(name: Routes.LOGIN, page: () => const LoginScreen()),
    GetPage(name: Routes.REGISTER, page: () => const RegisterScreen()),
    GetPage(name: Routes.OTP, page: () => const OtpScreen()),
    GetPage(name: Routes.FORGOT_PASSWORD, page: () => const ForgotPasswordScreen()),
    GetPage(name: Routes.CREATE_PASSWORD, page: () => const CreatePasswordScreen()),
    // Seller Auth routes
    GetPage(name: Routes.SELLER_LOGIN, page: () => const seller_login.LoginScreen()),
    GetPage(name: Routes.SELLER_REGISTER, page: () => const seller_register.RegisterScreen()),
    GetPage(name: Routes.SELLER_HOME, page: () => const seller_home.HomeScreen()),
    // Buyer routes
    GetPage(name: Routes.BUYER_HOME, page: () => const BuyerHomeScreen()),
    GetPage(name: Routes.SEARCH, page: () => const SearchScreen()),
    GetPage(name: Routes.PRODUCT_LIST, page: () => const ProductListScreen()),
    GetPage(name: Routes.PRODUCT_DETAILS, page: () => const ProductDetailScreen()),
    GetPage(name: Routes.CATEGORY, page: () => const CategoryScreen()),
    GetPage(name: Routes.NEARBY_SELLERS, page: () => const NearbySellersScreen()),
    GetPage(name: Routes.NOTIFICATIONS, page: () => const NotificationsScreen()),
    GetPage(name: Routes.BUYER_PROFILE, page: () => const BuyerProfileScreen()),
    GetPage(name: Routes.EDIT_PROFILE, page: () => const EditProfileScreen()),
    GetPage(name: Routes.SELLER_PROFILE, page: () => const SellerProfileScreen()),
    GetPage(name: Routes.TOP_SELLERS, page: () => const TopSellersScreen()),
    GetPage(name: Routes.CHAT, page: () => const ChatConversationScreen()),
    GetPage(name: Routes.CALL, page: () => const CallScreen()),
    GetPage(name: Routes.PAYMENT_INVOICE, page: () => const PaymentInvoiceScreen()),
    GetPage(
      name: Routes.INVOICE_DETAILS,
      page: () => InvoiceDetailsScreen(
        invoiceId: Get.arguments as String,
      ),
    ),
    GetPage(name: Routes.PRIVACY_POLICY, page: () => const PrivacyPolicyScreen()),
    GetPage(name: Routes.ABOUT, page: () => const AboutScreen()),
  ];
}
