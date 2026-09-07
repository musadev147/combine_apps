import 'dart:developer';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/get_all_tag_model.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

class TagApi {
  static final TagApi _singleton = TagApi._internal();
  TagApi._internal();
  static TagApi get instance => _singleton;

  Future<List<Results>> fetchVendorTags() async {
    try {
      final response = await getHttp(Endpoints.vendorTags());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        log("RAW VENDOR TAGS RESPONSE: $data");
        List<Results> tags = [];
        if (data is Map<String, dynamic>) {
          final model = GetAllTagModel.fromJson(data);
          tags = model.results ?? [];
        } else if (data is List) {
          tags = data.map((json) => Results.fromJson(json as Map<String, dynamic>)).toList();
        }
        
        final vendorId = appData.read(kKeyUserID)?.toString();
        log("VENDOR ID FROM STORAGE: $vendorId");
        if (vendorId != null && vendorId.isNotEmpty) {
          tags = tags.where((element) => element.vendor == vendorId).toList();
        }
        
        log("FILTERED VENDOR TAGS COUNT: ${tags.length}");
        return tags;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH VENDOR TAGS API ERROR: $error");
      rethrow;
    }
  }

  Future<List<Results>> fetchAdminTags({String query = ""}) async {
    try {
      final response = await getHttp(Endpoints.searchTag(query: query));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final model = GetAllTagModel.fromJson(data);
          return model.results ?? [];
        } else if (data is List) {
          return data.map((json) => Results.fromJson(json as Map<String, dynamic>)).toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH ADMIN TAGS API ERROR: $error");
      rethrow;
    }
  }

  Future<bool> postVendorTag(String adminTagId) async {
    try {
      final vendorId = appData.read(kKeyUserID)?.toString() ?? '';
      if (vendorId.isEmpty) {
        Get.snackbar("Error", "Vendor ID is missing. Please log out and log in again.");
        return false;
      }
      final response = await postHttp(Endpoints.vendorTags(), {
        'admin_tag': adminTagId,
        'vendor': vendorId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      Get.snackbar("API Error", "Server returned ${response.statusCode}: ${response.data}");
      return false;
    } on DioException catch (e) {
      log("POST VENDOR TAG API DIO ERROR: $e");
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map && data['non_field_errors'] != null) {
          final errors = data['non_field_errors'] as List;
          if (errors.any((err) => err.toString().contains('unique set'))) {
            Get.snackbar("Already Added", "This tag is already added to your store.");
            return true;
          }
        }
      }
      Get.snackbar("API Error", "Failed to add tag: ${e.response?.data ?? e.message}");
      return false;
    } catch (error) {
      log("POST VENDOR TAG API ERROR: $error");
      Get.snackbar("API Error", "Failed to add tag: $error");
      return false;
    }
  }

  Future<bool> deleteVendorTag(String vendorTagId) async {
    try {
      final response = await deleteHttp("${Endpoints.vendorTags()}$vendorTagId/");
      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (error) {
      log("DELETE VENDOR TAG API ERROR: $error");
      return false;
    }
  }
}
