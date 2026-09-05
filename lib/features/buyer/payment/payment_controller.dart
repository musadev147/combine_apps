import 'package:get/get.dart';

class PaymentController extends GetxController {
  // Observable variables
  var selectedGateway = 'SSL Commerz'.obs;
  var isEscrowEnabled = false.obs;
  var paymentStatus = 'Pending'.obs; // Pending, Processing, OTP Verification, Completed, Refunded
  var isProcessing = false.obs;
  var note = ''.obs;

  // Invoice Data (Mocked for now)
  final double subtotal = 125000.00;
  final double deliveryFee = 500.00;
  final double platformFee = 50.00;
  
  double get totalAmount => subtotal + deliveryFee + platformFee;

  void selectGateway(String gateway) {
    selectedGateway.value = gateway;
  }

  void toggleEscrow(bool value) {
    isEscrowEnabled.value = value;
  }

  // Simulating payment process and OTP trigger
  void initiatePayment() async {
    isProcessing.value = true;
    paymentStatus.value = 'Processing';
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Move to OTP step
    paymentStatus.value = 'OTP Verification';
    isProcessing.value = false;
  }

  // Submit OTP and finalize payment
  Future<bool> submitOtp(String otp) async {
    isProcessing.value = true;
    
    // Simulate network verification
    await Future.delayed(const Duration(seconds: 2));
    
    if (otp == '1234') { // Dummy success case
      paymentStatus.value = 'Completed';
      isProcessing.value = false;
      return true;
    } else {
      isProcessing.value = false;
      return false; // OTP Failed
    }
  }

  // Refund Management
  void requestRefund() async {
    isProcessing.value = true;
    
    // Simulate refund processing
    await Future.delayed(const Duration(seconds: 2));
    
    paymentStatus.value = 'Refunded';
    isProcessing.value = false;
    
    Get.snackbar(
      'Refund Successful', 
      'Your funds have been refunded to the original payment method.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
