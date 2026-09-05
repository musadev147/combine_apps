// Rx variables/state for otp
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide Response;
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/route/app_routes.dart';
import 'package:bd_shope_combined/features/seller/auth/register/presentation/data/api.dart';
import 'package:bd_shope_combined/features/seller/auth/register/presentation/model/register_model.dart';
import 'api.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/data/notification_service.dart';

class PostVerifyOtpRx extends RxResponseInt<Map<String, dynamic>> {
  final api = PostVerifyOtpApi.instance;
  bool _fromRegister = false;
  bool _isFromForgot = false;
  String _lastEmail = '';
  String _lastOtp = '';

  PostVerifyOtpRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<Map<String, dynamic>> get valueStreamData => dataFetcher.stream;

  Future<bool> verifyOtp({
    required String email,
    required String otp,
    bool fromRegister = false,
    bool isFromForgot = false,
  }) async {
    try {
      _fromRegister = fromRegister;
      _isFromForgot = isFromForgot;
      _lastEmail = email;
      _lastOtp = otp;
      await EasyLoading.show(status: 'Verifying OTP...');
      final data = isFromForgot
          ? await api.verifyResetOtp(email: email, otp: otp)
          : await api.verifyOtp(email: email, otp: otp);
      await EasyLoading.dismiss();
      return await handleSuccessWithReturn(data);
    } catch (error) {
      await EasyLoading.dismiss();
      log('Verify OTP error: $error');
      return await handleErrorWithReturn(error);
    }
  }

  Future<bool> resendOtp({
    required String email,
  }) async {
    try {
      await EasyLoading.show(status: 'Resending OTP...');
      final data = await api.resendOtp(email: email);
      await EasyLoading.dismiss();
      AppToast.success(data['message']?.toString() ?? 'OTP Resent successfully');
      return true;
    } catch (error) {
      await EasyLoading.dismiss();
      log('Resend OTP error: $error');
      String message = 'Failed to resend OTP';
      if (error is DioException) {
        final failure = ErrorHandler.handle(error).failure;
        message = failure.responseMessage;
      }
      AppToast.error(message);
      return false;
    }
  }

  @override
  Future<bool> handleSuccessWithReturn(Map<String, dynamic> data) async {
    AppToast.success("Verification Successful");

    if (_isFromForgot) {
      Get.offAllNamed(Routes.CREATE_PASSWORD, arguments: {
        'email': _lastEmail,
        'otp': _lastOtp,
      });
      return true;
    }

    // Extract token/user if present in the response
    final accessToken = data["access_token"] ?? data["token"] ?? data["accessToken"] ?? "";
    final user = data["user"] as Map<String, dynamic>?;
    final id = user?["id"]?.toString() ?? "";
    final email = user?["email"]?.toString() ?? "";
    final roleId = user?["role"]?.toString().toLowerCase() ?? "";
    String roleName = roleId;

    if (!_isFromForgot && !_fromRegister && roleId.isNotEmpty) {
      if (roleId.contains('-')) {
        try {
          final roles = await PostRegisterApi.instance.getRoles();
          final role = roles.firstWhere((r) => r.id == roleId, orElse: () => PostRegisterRole());
          if (role.value != null) {
            roleName = role.value!.toLowerCase();
          }
        } catch (e) {
          log("Role fetch error during otp: $e");
        }
      }

      if (roleName != 'vendor' && roleName != 'seller') {
        AppToast.error("This account is not registered as a Vendor. Please use the correct app.");
        return false;
      }
    }

    await appData.write(kKeyIsLoggedIn, true);
    if (email.isNotEmpty) await appData.write(kKeyEmail, email);
    if (accessToken.isNotEmpty) {
      await appData.write(kKeyAccessToken, accessToken);
      DioSingleton.instance.update(accessToken);
    }
    if (id.isNotEmpty) await appData.write(kKeyUserID, id);

    try {
      final notificationService = Get.put(NotificationService.instance);
      notificationService.registerToken();
    } catch (e) {
      log("PostVerifyOtpRx: Failed to register FCM token: $e");
    }

    if (_fromRegister) {
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.offAllNamed(Routes.HOME);
    }
    return true;
  }

  @override
  Future<bool> handleErrorWithReturn(error) async {
    String message = "Verification failed";
    if (error is DioException) {
      final failure = ErrorHandler.handle(error).failure;
      message = failure.responseMessage;
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }
    AppToast.error(message);
    return false;
  }
}
