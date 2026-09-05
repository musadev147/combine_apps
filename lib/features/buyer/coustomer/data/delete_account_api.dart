import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/post_delete_account_model.dart';

class DeleteAccountApi {
  static final DeleteAccountApi _singleton = DeleteAccountApi._internal();
  DeleteAccountApi._internal();
  static DeleteAccountApi get instance => _singleton;

  Future<PostAccountModel> requestDeleteAccount({
    required String email,
    required String password,
  }) async {
    try {
      final data = {
        "email": email,
        "password": password,
      };
      final response = await postHttp(Endpoints.deleteAccountRequest(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostAccountModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("REQUEST DELETE ACCOUNT API ERROR: $error");
      rethrow;
    }
  }

  Future<PostAccountModel> confirmDeleteAccount({
    required String email,
    required String otp,
  }) async {
    try {
      final data = {
        "email": email,
        "otp": otp,
        "code": otp,
      };
      final response = await postHttp(Endpoints.deleteAccountConfirm(), data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostAccountModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("CONFIRM DELETE ACCOUNT API ERROR: $error");
      rethrow;
    }
  }
}
