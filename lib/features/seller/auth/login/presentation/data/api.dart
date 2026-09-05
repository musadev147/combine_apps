import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/auth/login/presentation/model/login_model.dart';
import '/networks/endpoints.dart';

class PostLoginApi {
  static final PostLoginApi _singleton = PostLoginApi._internal();
  PostLoginApi._internal();
  static PostLoginApi get instance => _singleton;

  Future<PostLoginModel> loginData({
    required String email,
    required String password,
  }) async {
    log("login: $email");

    try {
      final data = {
        "email": email,
        "password": password,
      };

      final response = await postHttp(Endpoints.signIn(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostLoginModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("SIGN IN API ERROR: $error");
      rethrow;
    }
  }
}
