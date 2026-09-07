import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_shope_combined/services/web_socket_service.dart';
import 'package:bd_shope_combined/services/agora_service.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/data/api.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/data/notification_service.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';


class EcommerceProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> tags;
  final String category;
  final String sellerId;
  final String sellerName;
  final double rating;
  final String deliveryInfo;
  final int stock;

  EcommerceProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.tags,
    required this.category,
    required this.sellerId,
    required this.sellerName,
    required this.rating,
    required this.deliveryInfo,
    required this.stock,
  });
}

class SellerModel {
  final String id;
  final String name;
  final String photo;
  final String phone;
  final String location;
  String status; // 'Online', 'Busy', 'Offline', 'In Call'
  final List<String> categories;

  // Advanced Ranking fields
  final String type; // 'Store' or 'Individual'
  final String storeName;
  final String
  specialtyTitle; // e.g. 'Fashion Consultant', 'Electronics Expert'
  String level; // 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'
  int totalSales;
  int completedOrders;
  int successfulCalls;
  int positiveReviewsCount;
  double averageRating;
  final String responseTime; // e.g. '2m' or '5m'
  final double responseSpeedScore; // 0.0 to 100.0
  final double profileStrength; // 0.0 to 1.0
  int followers;
  final List<String> badges;
  final Map<int, int> ratingDistribution; // Star count e.g. {5: 45, 4: 5, 3: 2}
  double popularityScore; // Dynamically calculated

  final List<Map<String, dynamic>> reviews;

  SellerModel({
    required this.id,
    required this.name,
    required this.photo,
    required this.phone,
    required this.location,
    required this.status,
    required this.categories,
    required this.type,
    required this.storeName,
    required this.specialtyTitle,
    required this.level,
    required this.totalSales,
    required this.completedOrders,
    required this.successfulCalls,
    required this.positiveReviewsCount,
    required this.averageRating,
    required this.responseTime,
    required this.responseSpeedScore,
    required this.profileStrength,
    required this.followers,
    required this.badges,
    required this.ratingDistribution,
    required this.popularityScore,
    required this.reviews,
  });
}

class CallRequest {
  final String id;
  final String buyerName;
  final String productName;
  final String category;
  final String type; // 'audio' or 'video'
  final List<String> targetSellerIds;
  String status; // 'pending', 'accepted', 'rejected', 'ended'
  String? sellerId; // Added mutable seller ID
  String? acceptedBySellerId; // Added mutable accepted seller ID

  CallRequest({
    required this.id,
    required this.buyerName,
    required this.productName,
    required this.category,
    required this.type,
    required this.targetSellerIds,
    required this.status,
    this.acceptedBySellerId,
    this.sellerId,
  });
}

class ConnectionController extends GetxController {
  final _storage = GetStorage();

  // Observable states
  var sellers = <SellerModel>[].obs;
  var products = <EcommerceProduct>[].obs;
  var cartItems = <EcommerceProduct>[].obs;
  var currentRole = 'buyer'.obs; // 'buyer' or 'seller'

  // Current logged in seller profile status
  var sellerStatus = 'Online'.obs; // 'Online', 'Busy', 'Offline', 'In Call'
  var sellerCategories = <String>['Electronics', 'Laptop', 'Mobile'].obs;
  var sellerTags = <String>['Electronics', 'Laptop', 'Mobile'].obs;

  // Tag management for seller
  var sellerTagIds = <String, String>{}.obs;

  void addTag(String tag) {
    if (!sellerTags.contains(tag)) {
      sellerTags.add(tag);
    }
  }

  void removeTag(String tag) {
    sellerTags.remove(tag);
  }

  var sellerRating = 4.9.obs;
  var sellerCallHistory = <Map<String, dynamic>>[].obs;
  var sellerReviews = <Map<String, dynamic>>[
    {
      'buyer': 'Naimur Rahman',
      'stars': 5.0,
      'comment': 'Live video consultation was super helpful before buying!',
      'date': 'Today',
    },
    {
      'buyer': 'Fahim Ahmed',
      'stars': 4.0,
      'comment': 'Genuine laptop, showed me product condition on video.',
      'date': 'Yesterday',
    },
  ].obs;

  // Active call states
  var currentSessionId = ''.obs;
  var activeCallRequest = Rxn<CallRequest>();
  var callState =
      'idle'.obs; // 'idle', 'broadcasting', 'incoming', 'connected', 'ended'
  var activeCallType = 'audio'.obs; // 'audio' or 'video'
  var callTimerSeconds = 0.obs;
  var isMuted = false.obs;
  var isSpeakerOn = false.obs;
  var isCameraOff = false.obs;
  var callTimerString = '00:00'.obs;
  var networkStatus = 'Excellent'.obs;

  // Connection context for buyer calls
  var callingTagOrProduct = ''.obs;

  // Expose callingTag for UI compatibility
  RxString get callingTag => callingTagOrProduct;
  var callingCategory = ''.obs;
  var matchingSellersCount = 0.obs;
  var connectedSeller = Rxn<SellerModel>();

  // Dynamic database IDs for current active call
  var activeBuyerId = 5.obs;
  var activeVendorId = 2.obs;
  var activeTagId = 10.obs;

  Timer? _callTimer;
  Timer? _simulationTimer;

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    _initializeMockSellers();
    _initializeMockProducts();
    recalculateAllScores();

    // Hook up WebSocket callbacks and connect
    if (Get.isRegistered<WebSocketService>()) {
      final wsService = Get.find<WebSocketService>();
      wsService.addMessageListener(_handleWebSocketMessage);
      wsService.connect();
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final type = data['type'] ?? data['action'];
    
    // If we are a seller, DO NOT process call events here!
    // Seller has CallController for this. We only process new_invoice.
    if (currentRole.value == 'seller' && type != 'new_invoice') {
      return;
    }

    if (type == 'call_searching') {
      currentSessionId.value = data['session_id']?.toString() ?? '';
      callState.value = 'broadcasting';
      if (Get.currentRoute != Routes.CALL) {
        Get.toNamed(Routes.CALL);
      }
    } else if (type == 'incoming_call') {
      currentSessionId.value = data['session_id']?.toString() ?? '';
      callingTagOrProduct.value = data['tag_name']?.toString() ?? '';
      final msgCallType = data['call_type']?.toString() ?? data['type']?.toString() ?? 'video';
      activeCallType.value = msgCallType;
      activeCallRequest.value = CallRequest(
        id: currentSessionId.value,
        buyerName: data['buyer_name']?.toString() ?? 'Buyer',
        productName: '#${data['tag_name']}',
        category: data['tag_name']?.toString() ?? '',
        type: msgCallType,
        targetSellerIds: [],
        status: 'pending',
      );
      callState.value = 'incoming';
      if (Get.currentRoute != Routes.CALL) {
        Get.toNamed(Routes.CALL);
      }
    } else if (type == 'call_started') {
      currentSessionId.value = data['session_id']?.toString() ?? '';
      final storedUserId = appData.read(kKeyUserID)?.toString();
      final parsedBuyerId = int.tryParse(data['buyer']?.toString() ?? data['buyer_id']?.toString() ?? storedUserId ?? '');
      activeBuyerId.value = parsedBuyerId ?? 5;
      activeVendorId.value = int.tryParse(data['vendor']?.toString() ?? data['vendor_id']?.toString() ?? data['seller_id']?.toString() ?? '') ?? 2;
      activeTagId.value = int.tryParse(data['tag']?.toString() ?? data['tag_id']?.toString() ?? '') ?? 10;
      final token = data['token'] as String?;
      final channelName = data['channel_name'] as String?;
      final uid = data['uid'] as int? ?? 0;

      final msgCallType = data['call_type']?.toString() ?? data['type']?.toString() ?? '';
      if (msgCallType == 'video' || msgCallType == 'audio') {
        activeCallType.value = msgCallType;
      } else {
        activeCallType.value = 'video'; // Default to video so camera starts
      }

      final sellerId = data['seller_id']?.toString() ?? data['vendor_id']?.toString() ?? '';
      if (sellerId.isNotEmpty) {
        final seller = sellers.firstWhereOrNull((s) => s.id == sellerId);
        if (seller != null) {
          connectedSeller.value = seller;
        }
      }

      if (connectedSeller.value == null) {
        connectedSeller.value = sellers.firstWhereOrNull((s) => s.status == 'Online') ?? sellers.firstOrNull;
      }

      callState.value = 'connected';
      
      // Start call timer
      callTimerSeconds.value = 0;
      isMuted.value = false;
      isSpeakerOn.value = false;
      isCameraOff.value = false;
      networkStatus.value = 'Excellent';

      _callTimer?.cancel();
      _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        callTimerSeconds.value++;
        final minutes = (callTimerSeconds.value ~/ 60).toString().padLeft(2, '0');
        final seconds = (callTimerSeconds.value % 60).toString().padLeft(2, '0');
        callTimerString.value = '$minutes:$seconds';

        if (callTimerSeconds.value % 12 == 0) {
          networkStatus.value = networkStatus.value == 'Excellent'
              ? 'Good'
              : 'Excellent';
        }
      });

      if (Get.currentRoute != Routes.CALL) {
        Get.toNamed(Routes.CALL);
      }

      if (channelName != null && channelName.isNotEmpty) {
        Get.find<AgoraService>().joinCallChannel(channelId: channelName, token: token, uid: uid);
      }
    } else if (type == 'call_timeout') {
      Get.snackbar(
        'Call Timeout',
        data['message']?.toString() ?? 'No response from vendor.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.85),
        colorText: Colors.white,
      );
      cancelCall();
    } else if (type == 'call_cancelled') {
      Get.snackbar(
        'Call Cancelled',
        data['message']?.toString() ?? 'The call was cancelled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.85),
        colorText: Colors.white,
      );
      cancelCall();
    } else if (type == 'call_rejected_by_buyer' || type == 'cancel_call') {
      Get.snackbar(
        'Call Ended',
        'The call was ended or cancelled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.85),
        colorText: Colors.white,
      );
      cancelCall();
    } else if (type == 'call_declined') {
      Get.snackbar(
        'Call Declined',
        data['message']?.toString() ?? 'The seller declined the call.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.85),
        colorText: Colors.white,
      );
      cancelCall();
    } else if (type == 'new_invoice') {
      final invoice = data['invoice'] as Map<String, dynamic>?;
      if (invoice != null) {
        NotificationService.instance.showLocalNotification(
          title: 'New Invoice Received',
          body: 'You received a new invoice for ${invoice['product_name']?.toString() ?? 'item'} from ${invoice['vendor_name']?.toString() ?? 'Vendor'}',
          payload: invoice['id']?.toString() ?? '',
        );
        _showInvoicePopup(invoice);
      }
    }
  }

  void _showInvoicePopup(Map<String, dynamic> invoice) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20.r),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E1E38).withOpacity(0.95),
                const Color(0xFF0F0C20).withOpacity(0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7953CA).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Header Decorator
                Container(
                  padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFF53A4CA).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF53A4CA)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'New Invoice Received',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Invoice Details
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPopupDetailRow('Vendor Name', invoice['vendor_name']?.toString() ?? 'N/A'),
                      SizedBox(height: 10.h),
                      _buildPopupDetailRow('Product Name', invoice['product_name']?.toString() ?? 'N/A'),
                      SizedBox(height: 10.h),
                      _buildPopupDetailRow('Quantity', invoice['quantity']?.toString() ?? 'N/A'),
                      SizedBox(height: 10.h),
                      _buildPopupDetailRow('Price per piece', '৳${invoice['price_per_piece']?.toString() ?? '0.00'}'),
                      SizedBox(height: 12.h),
                      Divider(color: Colors.white.withOpacity(0.15)),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Price',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '৳${invoice['total_price']?.toString() ?? '0.00'}',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF53A4CA),
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions (Pay Now, Close)
                Padding(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 24.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          onPressed: () => Get.back(),
                          child: Text(
                            'Close',
                            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 15.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7953CA),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          onPressed: () {
                            Get.back(); // Dismiss the popup first
                            Get.toNamed(
                              Routes.INVOICE_DETAILS,
                              arguments: invoice['id']?.toString() ?? '',
                            );
                          },
                          child: Text(
                            'Pay Now',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildPopupDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13.sp,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _initiateInvoicePayment(String invoiceId) async {
    try {
      EasyLoading.show(status: 'Initiating Payment...');
      
      final response = await postHttp('/payment/initiate/', {
        'invoice_id': invoiceId,
        'phone_number': '01700000000',
        'address': 'Dhaka, Bangladesh',
      });
      
      EasyLoading.dismiss();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final gatewayUrl = response.data['GatewayPageURL'] as String?;
        if (gatewayUrl != null && gatewayUrl.isNotEmpty) {
          final uri = Uri.parse(gatewayUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            Get.snackbar(
              'Error',
              'Could not open the payment gateway URL.',
              backgroundColor: Colors.redAccent.withOpacity(0.9),
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'Payment Gateway URL is missing in the response.',
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to initiate payment. Status: ${response.statusCode}',
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }


  void _loadUserRole() {
    String? storedRole = _storage.read('userRole');
    if (storedRole != null) {
      currentRole.value = storedRole;
    }
  }

  void setRole(String role) {
    currentRole.value = role;
    _storage.write('userRole', role);
  }

  void _initializeMockSellers() {
    sellers.assignAll([
      SellerModel(
        id: 's1',
        name: 'Tanvir Rahman',
        photo:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200',
        phone: '+8801712345678',
        location: 'Gulshan, Dhaka',
        status: 'Online',
        categories: ['Electronics', 'Mobile', 'Laptop'],
        type: 'Store',
        storeName: 'SmartTech BD',
        specialtyTitle: 'Tech Specialist',
        level: 'Gold',
        totalSales: 154,
        completedOrders: 142,
        successfulCalls: 88,
        positiveReviewsCount: 92,
        averageRating: 4.9,
        responseTime: '1m',
        responseSpeedScore: 98.0,
        profileStrength: 0.95,
        followers: 1250,
        badges: [
          'Verified Seller',
          'Trusted Seller',
          'Top Rated Seller',
          'Fast Responder',
        ],
        ratingDistribution: {5: 85, 4: 6, 3: 1, 2: 0, 1: 0},
        popularityScore: 0.0, // Calculated dynamically
        reviews: [
          {
            'buyer': 'Tanvir',
            'stars': 5.0,
            'comment': 'Consulted over video, showed the box seal!',
            'date': 'Yesterday',
          },
        ],
      ),
      SellerModel(
        id: 's2',
        name: 'Sarah Khan',
        photo:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200',
        phone: '+8801812345678',
        location: 'Banani, Dhaka',
        status: 'Online',
        categories: ['T-Shirt', 'Shirt', 'Pant', 'Shoes'],
        type: 'Individual',
        storeName: 'Vogue Dhaka',
        specialtyTitle: 'Fashion Consultant',
        level: 'Platinum',
        totalSales: 210,
        completedOrders: 198,
        successfulCalls: 120,
        positiveReviewsCount: 145,
        averageRating: 4.8,
        responseTime: '2m',
        responseSpeedScore: 94.0,
        profileStrength: 0.98,
        followers: 3200,
        badges: [
          'Verified Seller',
          'Trusted Seller',
          'Expert Consultant',
          'Premium Seller',
          'Top Performer',
        ],
        ratingDistribution: {5: 120, 4: 20, 3: 5, 2: 0, 1: 0},
        popularityScore: 0.0,
        reviews: [
          {
            'buyer': 'Mitu',
            'stars': 4.5,
            'comment': 'Showed fabric stretch quality on audio request.',
            'date': '3 days ago',
          },
        ],
      ),
      SellerModel(
        id: 's3',
        name: 'Mim Akter',
        photo:
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200',
        phone: '+8801912345678',
        location: 'Dhanmondi, Dhaka',
        status: 'Online',
        categories: ['Cosmetics', 'Watch'],
        type: 'Individual',
        storeName: 'Cosmo Zone',
        specialtyTitle: 'Product Advisor',
        level: 'Silver',
        totalSales: 68,
        completedOrders: 62,
        successfulCalls: 45,
        positiveReviewsCount: 30,
        averageRating: 4.7,
        responseTime: '3m',
        responseSpeedScore: 88.0,
        profileStrength: 0.85,
        followers: 480,
        badges: ['Verified Seller', 'Expert Consultant'],
        ratingDistribution: {5: 25, 4: 4, 3: 1, 2: 0, 1: 0},
        popularityScore: 0.0,
        reviews: [],
      ),
      SellerModel(
        id: 's4',
        name: 'Electro Wave Shop',
        photo:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
        phone: '+8801612345678',
        location: 'Uttara, Dhaka',
        status: 'Offline',
        categories: ['Home Appliances', 'Electronics'],
        type: 'Store',
        storeName: 'Electro Wave',
        specialtyTitle: 'Home Decor Expert',
        level: 'Diamond',
        totalSales: 450,
        completedOrders: 432,
        successfulCalls: 220,
        positiveReviewsCount: 310,
        averageRating: 5.0,
        responseTime: '1m',
        responseSpeedScore: 99.0,
        profileStrength: 1.0,
        followers: 5400,
        badges: [
          'Verified Seller',
          'Trusted Seller',
          'Top Rated Seller',
          'Fast Responder',
          'Premium Seller',
          'Top Performer',
        ],
        ratingDistribution: {5: 305, 4: 5, 3: 0, 2: 0, 1: 0},
        popularityScore: 0.0,
        reviews: [],
      ),
      SellerModel(
        id: 's5',
        name: 'Apex Store Mirpur',
        photo:
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200',
        phone: '+8801512345678',
        location: 'Mirpur, Dhaka',
        status: 'Online',
        categories: ['Shoes', 'T-Shirt', 'Pant'],
        type: 'Store',
        storeName: 'Apex Wear',
        specialtyTitle: 'Product Advisor',
        level: 'Bronze',
        totalSales: 40,
        completedOrders: 35,
        successfulCalls: 15,
        positiveReviewsCount: 12,
        averageRating: 4.4,
        responseTime: '8m',
        responseSpeedScore: 75.0,
        profileStrength: 0.70,
        followers: 120,
        badges: ['Verified Seller'],
        ratingDistribution: {5: 8, 4: 3, 3: 1, 2: 0, 1: 0},
        popularityScore: 0.0,
        reviews: [],
      ),
    ]);
  }

  void _initializeMockProducts() {
    products.assignAll([
      EcommerceProduct(
        id: 'p1',
        title: 'iPhone 15 Pro Max',
        description:
            'Super Retina XDR OLED, 120Hz, HDR10, Dolby Vision. A17 Pro chip. 256GB. Excellent camera zoom. Verified official warranty.',
        price: 1299.00,
        imageUrl:
            'https://images.unsplash.com/photo-1695048133142-1a20484d2569?q=80&w=500',
        tags: ['iphone', 'mobile', 'smartphone', 'apple'],
        category: 'Mobile',
        sellerId: 's1',
        sellerName: 'SmartTech BD',
        rating: 4.9,
        deliveryInfo:
            'Free delivery inside Dhaka within 24 hours. Extra charges outside.',
        stock: 12,
      ),
      EcommerceProduct(
        id: 'p2',
        title: 'Premium Black Cotton T-Shirt',
        description:
            '100% combed organic cotton fabric. High-quality stitching, sweat-absorbent, premium luxury wash comfort.',
        price: 25.00,
        imageUrl:
            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?q=80&w=500',
        tags: [
          'tshirt',
          'black tshirt',
          'mens tshirt',
          'cotton tshirt',
          'clothing',
        ],
        category: 'T-Shirt',
        sellerId: 's2',
        sellerName: 'Vogue Hub Dhaka',
        rating: 4.8,
        deliveryInfo:
            'Delivery inside Dhaka: 60 BDT (1-2 days). Outside: 120 BDT (2-3 days).',
        stock: 100,
      ),
      EcommerceProduct(
        id: 'p3',
        title: 'MacBook Pro 14" M3',
        description:
            'Apple M3 Chip with 8-core CPU, 10-core GPU, 8GB Unified Memory, 512GB SSD. Space Grey. 1 year official warranty.',
        price: 1599.00,
        imageUrl:
            'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=500',
        tags: ['macbook', 'laptop', 'apple', 'computer'],
        category: 'Laptop',
        sellerId: 's1',
        sellerName: 'SmartTech BD',
        rating: 4.9,
        deliveryInfo: 'Next-day home delivery with live product verification.',
        stock: 5,
      ),
      EcommerceProduct(
        id: 'p4',
        title: 'Luxury Matte Lipstick',
        description:
            'Velvety matte formula with high-pigment payoff. Intensely hydrating and long-wearing. Clean, luxury, and organic ingredients.',
        price: 35.00,
        imageUrl:
            'https://images.unsplash.com/photo-1586495777744-4413f21062fa?q=80&w=500',
        tags: ['cosmetics', 'lipstick', 'makeup', 'beauty'],
        category: 'Cosmetics',
        sellerId: 's3',
        sellerName: 'Cosmo Zone',
        rating: 4.7,
        deliveryInfo: 'Standard shipping: 2-4 business days.',
        stock: 45,
      ),
      EcommerceProduct(
        id: 'p5',
        title: 'Men Sport Sneakers',
        description:
            'Responsive cushion outsole with breathable mesh top cover. Designed for superior shock absorption and running performance.',
        price: 120.00,
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500',
        tags: ['shoes', 'sneakers', 'nike', 'sport', 'clothing'],
        category: 'Shoes',
        sellerId: 's5',
        sellerName: 'Apex Wear',
        rating: 4.6,
        deliveryInfo: 'Express delivery available. Free returns within 7 days.',
        stock: 30,
      ),
    ]);
  }

  // --- POPULARITY RANKING ALGORITHM ---

  void recalculateAllScores() {
    for (var seller in sellers) {
      _calculatePopularityScore(seller);
      _calculateSellerLevel(seller);
    }
    // Sort sellers by popularity score descending
    sellers.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
  }

  void _calculatePopularityScore(SellerModel seller) {
    // 40% Rating (normalized from 1-5 to 0-100)
    final double ratingComponent =
        ((seller.averageRating - 1.0) / 4.0) * 100 * 0.40;

    // 20% Completed Orders (capped at 500 completed orders for score scaling)
    final double ordersComponent =
        (seller.completedOrders / 500.0).clamp(0.0, 1.0) * 100 * 0.20;

    // 15% Successful Calls (capped at 300 calls for score scaling)
    final double callsComponent =
        (seller.successfulCalls / 300.0).clamp(0.0, 1.0) * 100 * 0.15;

    // 10% Positive Reviews (capped at 200 positive reviews)
    final double reviewsComponent =
        (seller.positiveReviewsCount / 200.0).clamp(0.0, 1.0) * 100 * 0.10;

    // 10% Response Speed Score (native 0-100 score)
    final double speedComponent = seller.responseSpeedScore * 0.10;

    // 5% Profile Strength (0.0 to 1.0)
    final double profileComponent = seller.profileStrength * 100 * 0.05;

    seller.popularityScore =
        ratingComponent +
        ordersComponent +
        callsComponent +
        reviewsComponent +
        speedComponent +
        profileComponent;
  }

  void _calculateSellerLevel(SellerModel seller) {
    final score = seller.popularityScore;
    if (score >= 90) {
      seller.level = 'Diamond';
    } else if (score >= 75) {
      seller.level = 'Platinum';
    } else if (score >= 55) {
      seller.level = 'Gold';
    } else if (score >= 35) {
      seller.level = 'Silver';
    } else {
      seller.level = 'Bronze';
    }
  }

  // --- LEADERBOARDS ---

  List<SellerModel> getLeaderboard(String type) {
    final list = List<SellerModel>.from(sellers);
    switch (type) {
      case 'Top Sellers':
        list.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
      case 'Top Stores':
        return list.where((s) => s.type == 'Store').toList();
      case 'Top Consultants':
        return list.where((s) => s.type == 'Individual').toList();
      case 'Most Active Sellers':
        list.sort((a, b) => b.completedOrders.compareTo(a.completedOrders));
        break;
      case 'Highest Rated Sellers':
        list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
    }
    return list;
  }

  // --- AI RECOMMENDATION ENGINE ---

  List<SellerModel> getRecommendedSellers() {
    // Return top ranked online sellers first
    return sellers.where((s) => s.status == 'Online').toList();
  }

  // --- ECOMMERCE BUYER ACTIONS ---

  void addToCart(EcommerceProduct product) {
    if (!cartItems.contains(product)) {
      cartItems.add(product);
      Get.snackbar(
        'Added to Cart',
        '${product.title} has been added to your shopping cart!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF53A4CA).withOpacity(0.85),
        colorText: Colors.white,
      );
    }
  }

  void removeFromCart(EcommerceProduct product) {
    cartItems.remove(product);
  }

  // --- REAL-TIME LIVE BROADCAST SYSTEM ---

  List<SellerModel> getOnlineSellersForProduct(EcommerceProduct product) {
    return sellers.where((s) {
      final matchesCategory = s.categories.contains(product.category);
      final isOnline = s.status == 'Online';
      return matchesCategory && isOnline;
    }).toList();
  }

  List<SellerModel> getOnlineSellersForTag(String search) {
    final query = search.toLowerCase().trim();
    return sellers.where((s) {
      final matchesCategory = s.categories.any(
        (cat) => cat.toLowerCase().contains(query),
      );
      final isOnline = s.status == 'Online';
      return matchesCategory && isOnline;
    }).toList();
  }

  void broadcastCallForTag({
    required String tag,
    required String callType,
    String? tagId,
  }) async {
    callingTagOrProduct.value = tag;
    callingCategory.value = tag;
    activeCallType.value = callType;

    // Try to resolve tagId dynamically from API if not provided
    if (tagId == null || tagId.isEmpty) {
      try {
        final tagsList = await GetSerachTagApi.instance.fetchTags(query: tag);
        final match = tagsList.firstWhereOrNull(
          (t) => t.tagname?.toLowerCase().trim() == tag.toLowerCase().trim()
        );
        if (match != null) {
          tagId = match.id;
        }
      } catch (e) {
        print("Error resolving tagId dynamically: $e");
      }
    }

    final lowercaseTag = tag.trim().toLowerCase();
    final matchingSellers = sellers.where((s) {
      final isOnline = s.status == 'Online';
      final matchesCategory = s.categories.any(
        (cat) => cat.toLowerCase().contains(lowercaseTag)
      );
      return isOnline && matchesCategory;
    }).toList();

    matchingSellersCount.value = matchingSellers.length;
    callState.value = 'broadcasting';

    // Create a CallRequest representing this broadcast
    final request = CallRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      buyerName: 'Buyer',
      productName: '#$tag',
      category: tag,
      type: callType,
      targetSellerIds: matchingSellers.map((s) => s.id).toList(),
      status: 'pending',
      sellerId: null,
    );
    activeCallRequest.value = request;

    // Send via WebSocket Service
    if (tagId != null && tagId.isNotEmpty) {
      Get.find<WebSocketService>().initiateCall(tagId: tagId, callType: callType);
    } else {
      Get.find<WebSocketService>().sendCallRequest(
        product: tag,
        sellerIds: matchingSellers.map((s) => s.id).toList(),
      );
    }

    // Navigate to Call Screen
    Get.toNamed(Routes.CALL);

    // Timeout after 90 seconds if no seller accepts
    _simulationTimer?.cancel();
    _simulationTimer = Timer(const Duration(seconds: 90), () {
      if (callState.value == 'broadcasting') {
        Get.snackbar(
          'Broadcast Timeout',
          'No seller accepted the call within the time limit.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.85),
          colorText: Colors.white,
        );
        cancelCall();
      }
    });
  }

  void broadcastCallForProduct({
    required String name,
    required String category,
    required String callType,
  }) {
    callingTagOrProduct.value = name;
    callingCategory.value = category;
    activeCallType.value = callType;

    final matchingSellers = sellers
        .where((s) => s.status == 'Online' && s.categories.contains(category))
        .toList();
    matchingSellersCount.value = matchingSellers.length;
    callState.value = 'broadcasting';

    // Create a CallRequest representing this broadcast
    final request = CallRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      buyerName: 'Buyer',
      productName: name,
      category: category,
      type: callType,
      targetSellerIds: matchingSellers.map((s) => s.id).toList(),
      status: 'pending',
      sellerId: null,
    );
    activeCallRequest.value = request;

    // Send via WebSocket Service
    Get.find<WebSocketService>().sendCallRequest(
      product: category,
      sellerIds: matchingSellers.map((s) => s.id).toList(),
    );

    // Navigate to Call Screen
    Get.toNamed(Routes.CALL);

    // Timeout after 90 seconds if no seller accepts
    _simulationTimer?.cancel();
    _simulationTimer = Timer(const Duration(seconds: 90), () {
      if (callState.value == 'broadcasting') {
        Get.snackbar(
          'Broadcast Timeout',
          'No seller accepted the call within the time limit.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.85),
          colorText: Colors.white,
        );
        cancelCall();
      }
    });
  }

  void _connectCallWithSeller(SellerModel seller) {
    _simulationTimer?.cancel();
    connectedSeller.value = seller;

    seller.status = 'In Call';
    sellers.refresh();

    callState.value = 'connected';
    callTimerSeconds.value = 0;
    isMuted.value = false;
    isSpeakerOn.value = false;
    isCameraOff.value = false;
    networkStatus.value = 'Excellent';

    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callTimerSeconds.value++;
      final minutes = (callTimerSeconds.value ~/ 60).toString().padLeft(2, '0');
      final seconds = (callTimerSeconds.value % 60).toString().padLeft(2, '0');
      callTimerString.value = '$minutes:$seconds';

      if (callTimerSeconds.value % 12 == 0) {
        networkStatus.value = networkStatus.value == 'Excellent'
            ? 'Good'
            : 'Excellent';
      }
    });
  }

  // --- SELLER SIDE SIMULATOR ---

  void toggleSellerAvailability() {
    if (sellerStatus.value == 'Online') {
      sellerStatus.value = 'Offline';
    } else {
      sellerStatus.value = 'Online';
    }

    Get.snackbar(
      'Availability Status Changed',
      'You are now ${sellerStatus.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
          (sellerStatus.value == 'Online' ? Colors.green : Colors.grey)
              .withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void simulateIncomingCallForSeller() {
    if (sellerStatus.value != 'Online') {
      Get.snackbar(
        'Cannot Accept Calls',
        'Please turn your availability status to Online first!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent.withOpacity(0.85),
        colorText: Colors.white,
      );
      return;
    }

    // If there is an active broadcast request, present it to the seller
    final request = activeCallRequest.value;
    if (request == null) {
      Get.snackbar(
        'No Calls',
        'There is currently no incoming buyer request.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.withOpacity(0.85),
        colorText: Colors.white,
      );
      return;
    }

    // Show incoming request dialog
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: const Color(0xFF1E1E38).withOpacity(0.95),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam, color: const Color(0xFF53A4CA), size: 44.r),
              const SizedBox(height: 16),
              Text(
                'Incoming Call',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buyer ${request.buyerName} wants to talk about "${request.productName}". Accept?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.back();
                        request.status = 'rejected';
                        activeCallRequest.value = null;
                        callState.value = 'idle';
                      },
                      child: Text(
                        'Reject',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7953CA),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.back();
                        request.status = 'accepted';
                        // Assign the accepting seller's ID
                        final sellerId = sellers.firstWhere((s) => s.status == 'Online').id;
                        request.sellerId = sellerId;
                        request.acceptedBySellerId = sellerId;
                        activeCallRequest.value = request;
                        callState.value = 'connected';
                        connectedSeller.value = sellers.firstWhere(
                          (s) => s.id == request.sellerId,
                        );
                        connectedSeller.value?.status = 'In Call';
                        sellers.refresh();
                        callTimerSeconds.value = 0;
                        isMuted.value = false;
                        isSpeakerOn.value = false;
                        isCameraOff.value = false;
                        networkStatus.value = 'Excellent';
                        _callTimer?.cancel();
                        _callTimer = Timer.periodic(
                          const Duration(seconds: 1),
                          (timer) {
                            callTimerSeconds.value++;
                            final minutes = (callTimerSeconds.value ~/ 60)
                                .toString()
                                .padLeft(2, '0');
                            final seconds = (callTimerSeconds.value % 60)
                                .toString()
                                .padLeft(2, '0');
                            callTimerString.value = '${minutes}:${seconds}';
                          },
                        );
                      },
                      child: const Text(
                        'Accept',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void acceptIncomingCall() {
    _simulationTimer?.cancel();
    Get.find<WebSocketService>().acceptCall(currentSessionId.value);
    callState.value = 'connected';
    sellerStatus.value = 'In Call';

    connectedSeller.value = SellersAliasMock();

    callTimerSeconds.value = 0;
    isMuted.value = false;
    isSpeakerOn.value = false;
    isCameraOff.value = false;

    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callTimerSeconds.value++;
      final minutes = (callTimerSeconds.value ~/ 60).toString().padLeft(2, '0');
      final seconds = (callTimerSeconds.value % 60).toString().padLeft(2, '0');
      callTimerString.value = '$minutes:$seconds';
    });
  }

  SellerModel SellersAliasMock() {
    return SellerModel(
      id: 'buyer_mock',
      name: 'Aysha Siddika (Buyer)',
      photo:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=200',
      phone: '+8801755555555',
      location: 'Mirpur, Dhaka',
      status: 'Online',
      categories: [],
      type: 'Individual',
      storeName: '',
      specialtyTitle: 'Fashion Consultant',
      level: 'Bronze',
      totalSales: 0,
      completedOrders: 0,
      successfulCalls: 0,
      positiveReviewsCount: 0,
      averageRating: 5.0,
      responseTime: 'Instant',
      responseSpeedScore: 100,
      profileStrength: 0.8,
      followers: 12,
      badges: [],
      ratingDistribution: {},
      popularityScore: 100,
      reviews: [],
    );
  }

  void rejectIncomingCall() {
    _simulationTimer?.cancel();
    Get.find<WebSocketService>().declineCall(currentSessionId.value);
    callState.value = 'idle';
  }

  // --- COMMON CALL ACTIONS ---

  void toggleMute() {
    isMuted.value = !isMuted.value;
    Get.find<AgoraService>().muteLocalAudio(isMuted.value);
  }

  void toggleSpeaker() {
    isSpeakerOn.value = !isSpeakerOn.value;
    Get.find<AgoraService>().enableSpeakerphone(isSpeakerOn.value);
  }

  void toggleCamera() {
    isCameraOff.value = !isCameraOff.value;
    Get.find<AgoraService>().muteLocalVideo(isCameraOff.value);
  }

  void switchCamera() {
    Get.find<AgoraService>().switchCamera();
  }

  void rejectCurrentVendor() {
    _callTimer?.cancel();
    Get.find<AgoraService>().leaveCallChannel();
    final vendorId = connectedSeller.value?.id;
    Get.find<WebSocketService>().rejectCall(currentSessionId.value, vendorId: vendorId);
    
    // Reset/restart the simulation/timeout timer for the new search
    _simulationTimer?.cancel();
    _simulationTimer = Timer(const Duration(seconds: 90), () {
      if (callState.value == 'broadcasting') {
        Get.snackbar(
          'Broadcast Timeout',
          'No other seller accepted the call.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.85),
          colorText: Colors.white,
        );
        cancelCall();
      }
    });

    // Transition back to broadcasting state
    callState.value = 'broadcasting';
    connectedSeller.value = null;
  }

  void endCall() {
    _callTimer?.cancel();
    _simulationTimer?.cancel();

    // End call on WebSocket and Agora RTC
    Get.find<WebSocketService>().cancelCall(currentSessionId.value);
    Get.find<AgoraService>().leaveCallChannel();

    final finalDuration = callTimerString.value;
    final endedSeller = connectedSeller.value;
    final endedProduct = callingTagOrProduct.value;

    if (endedSeller != null) {
      if (endedSeller.id != 'buyer_mock') {
        endedSeller.status = 'Online';
      }

      final historyItem = {
        'name': endedSeller.name,
        'tag': endedProduct,
        'duration': finalDuration,
        'date': 'Just now',
        'type': activeCallType.value,
      };
      sellerCallHistory.insert(0, historyItem);
    }
    sellers.refresh();

    callState.value = 'ended';

    if (currentRole.value == 'buyer') {
      _showRatingDialog(endedSeller);
    } else {
      sellerStatus.value = 'Online';
      callState.value = 'idle';
      connectedSeller.value = null;
    }
  }

  void cancelCall() {
    _simulationTimer?.cancel();
    _callTimer?.cancel();
    
    // Cancel call on WebSocket and Agora RTC
    final wsService = Get.find<WebSocketService>();
    if (currentSessionId.value.isNotEmpty) {
      wsService.cancelCall(currentSessionId.value);
    } else {
      // Force reconnect to let the server know we dropped the call prematurely
      wsService.disconnect();
      Future.delayed(const Duration(milliseconds: 500), () => wsService.connect());
    }
    Get.find<AgoraService>().leaveCallChannel();

    final endedSeller = connectedSeller.value;
    if (endedSeller != null) {
      if (endedSeller.id != 'buyer_mock') {
        endedSeller.status = 'Online';
      }
    }
    sellers.refresh();

    callState.value = 'idle';
    connectedSeller.value = null;
  }

  void submitRating(SellerModel seller, double stars, String reviewText) {
    if (seller.id != 'buyer_mock') {
      final newReview = {
        'buyer': 'Me (Buyer)',
        'stars': stars,
        'comment': reviewText.isEmpty
            ? 'Consultation call successfully answered.'
            : reviewText,
        'date': 'Today',
      };
      seller.reviews.insert(0, newReview);

      // Add to positive review counts if stars >= 4.0
      if (stars >= 4.0) {
        seller.positiveReviewsCount++;
      }

      // Update aggregate ratings
      double sum = 0;
      for (var r in seller.reviews) {
        sum += (r['stars'] as num).toDouble();
      }
      seller.averageRating = sum / seller.reviews.length;

      // Recalculate Dynamic Popularity Scores
      recalculateAllScores();

      Get.snackbar(
        'Feedback Recorded',
        'Thank you! You rated ${seller.name} $stars stars.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF53A4CA).withOpacity(0.85),
        colorText: Colors.white,
      );
    }

    callState.value = 'idle';
    connectedSeller.value = null;
  }

  void _showRatingDialog(SellerModel? seller) {
    if (seller == null) {
      callState.value = 'idle';
      return;
    }

    double selectedStars = 5.0;
    final reviewTextController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: const Color(0xFF1E1E38).withOpacity(0.95),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF7953CA),
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(seller.photo),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rate Your Consultation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Was this video/audio call helpful in deciding your purchase with ${seller.name}?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1.0;
                      return GestureDetector(
                        onTap: () {
                          setStateDialog(() {
                            selectedStars = starVal;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            starVal <= selectedStars
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewTextController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Share your shopping review...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF53A4CA)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Get.back();
                            callState.value = 'idle';
                            connectedSeller.value = null;
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7953CA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Get.back();
                            submitRating(
                              seller,
                              selectedStars,
                              reviewTextController.text,
                            );
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }
}
