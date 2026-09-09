import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/buyer/auth/create_password_screen/model/create_password_model.dart';
import '/networks/endpoints.dart';

class PostResetPasswordApi {
  static final PostResetPasswordApi _singleton = PostResetPasswordApi._internal();
  PostResetPasswordApi._internal();
  static PostResetPasswordApi get instance => _singleton;

  Future<PostResetPasswordModel> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    log('resetPassword for: $email');

    try {
      final data = {
        'email': email,
        'otp': otp,
        'new_password': password,
        'confirm_password': passwordConfirmation,
      };

      final response = await postHttp(Endpoints.forgotNewPassword(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostResetPasswordModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log('RESET PASSWORD API ERROR');
      rethrow;
    }
  }
}
