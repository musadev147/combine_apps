// API operations for otp
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';

class PostVerifyOtpApi {
  static final PostVerifyOtpApi _singleton = PostVerifyOtpApi._internal();
  PostVerifyOtpApi._internal();
  static PostVerifyOtpApi get instance => _singleton;

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final payload = {
        'email': email,
        'otp': otp,
      };

      Response response = await postHttp(Endpoints.otpVerify(), payload);

      return (response.data as Map<String, dynamic>?) ?? {};
    } catch (error) {
      log('VERIFY OTP API ERROR');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      final payload = {
        'email': email,
      };

      Response response = await postHttp(Endpoints.resendEmailVerification(), payload);

      return (response.data as Map<String, dynamic>?) ?? {};
    } catch (error) {
      log('RESEND OTP API ERROR: $error');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final payload = {
        'email': email,
        'otp': otp,
      };

      Response response = await postHttp(Endpoints.resetOtpVerify(), payload);

      return (response.data as Map<String, dynamic>?) ?? {};
    } catch (error) {
      log('VERIFY RESET OTP API ERROR: $error');
      rethrow;
    }
  }
}
