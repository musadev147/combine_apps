import 'dart:developer';
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
        List<Results> tags = [];
        if (data is Map<String, dynamic>) {
          final model = GetAllTagModel.fromJson(data);
          tags = model.results ?? [];
        } else if (data is List) {
          tags = data.map((json) => Results.fromJson(json as Map<String, dynamic>)).toList();
        }
        
        final vendorId = appData.read(kKeyUserID)?.toString();
        if (vendorId != null && vendorId.isNotEmpty) {
          tags = tags.where((element) => element.vendor == vendorId).toList();
        }
        
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
      final response = await postHttp(Endpoints.vendorTags(), {
        'admin_tag': adminTagId,
        'vendor': vendorId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (error) {
      log("POST VENDOR TAG API ERROR: $error");
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
