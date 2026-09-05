
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/features/seller/auth/register/presentation/model/register_model.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';

class PostRegisterApi {
  static final PostRegisterApi _singleton = PostRegisterApi._internal();
  PostRegisterApi._internal();
  static PostRegisterApi get instance => _singleton;

  Future<PostRegisterModel> signUpdata({
    required String name,
    required String email,
    required String user_role,
    required String phoneNumber,
    required String permanentAddress,
    required String presentAddress,
    File? avatar,
    required String password,
    required String password_confirmation,
  }) async {
    log("Email: $email");
    log("Name: $name");
    log("User Role: $user_role");
    log("Phone: $phoneNumber");
    log("Permanent Addr: $permanentAddress");
    log("Present Addr: $presentAddress");
    log("Password: $password");

    try {
      final formData = FormData.fromMap({
        "name": name,
        "email": email,
        "role": user_role,
        "user_role": user_role,
        "phone_number": phoneNumber,
        "permanent_address": permanentAddress,
        "present_address": presentAddress,
        "password": password,
        "password_confirmation": password_confirmation,
        "confirm_password": password_confirmation,
        if (avatar != null)
          "image": await MultipartFile.fromFile(avatar.path),
      });

      Response response = await postHttp(Endpoints.register(), formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return PostRegisterModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("API ERROR: $error");
      rethrow;
    }
  }

  Future<List<PostRegisterRole>> getRoles() async {
    try {
      Response response = await getHttp(Endpoints.lookupRoles());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List) {
          return data
              .map((json) => PostRegisterRole.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => PostRegisterRole.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data['roles'] is List) {
          return (data['roles'] as List)
              .map((json) => PostRegisterRole.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("GET ROLES API ERROR: $error");
      rethrow;
    }
  }
}
