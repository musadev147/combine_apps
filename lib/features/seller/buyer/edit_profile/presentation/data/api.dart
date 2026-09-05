import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/features/seller/buyer/edit_profile/presentation/model/model.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';

class EditProfileApi {
  static final EditProfileApi _singleton = EditProfileApi._internal();
  EditProfileApi._internal();
  static EditProfileApi get instance => _singleton;

  Future<EditProfileResponseModel> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phoneNumber,
    required String permanentAddress,
    required String presentAddress,
    File? image,
  }) async {
    log("Update Profile: $email, $name, ID: $userId");
    try {
      final formData = FormData.fromMap({
        "name": name,
        "email": email,
        "phone_number": phoneNumber,
        "permanent_address": permanentAddress,
        "present_address": presentAddress,
        if (image != null)
          "image": await MultipartFile.fromFile(image.path),
      });

      Response response = await patchHttp(Endpoints.editProfileUser(id: userId), formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return EditProfileResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("EDIT PROFILE API ERROR: $error");
      rethrow;
    }
  }
}
