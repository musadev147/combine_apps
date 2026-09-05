// API operations for forgot_password
import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/auth/forgot_password/presentation/model/forget_model.dart';
import '/networks/endpoints.dart';

class PostForgotPasswordApi {
  static final PostForgotPasswordApi _singleton = PostForgotPasswordApi._internal();
  PostForgotPasswordApi._internal();
  static PostForgotPasswordApi get instance => _singleton;

  Future<ForgotPasswordModel> forgotPassword({
    required String email,
  }) async {
    log('forgotPassword: $email');

    try {
      final data = {
        'email': email,
      };

      final response = await postHttp(Endpoints.forgotEmail(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ForgotPasswordModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log('FORGOT PASSWORD API ERROR: $error');
      rethrow;
    }
  }
}
