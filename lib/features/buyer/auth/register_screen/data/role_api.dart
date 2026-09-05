import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/features/buyer/auth/register_screen/model/register_role.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';

class GetRoleApi {
  static final GetRoleApi _singleton = GetRoleApi._internal();
  GetRoleApi._internal();
  static GetRoleApi get instance => _singleton;

  Future<List<GetRoleModel>> getRoles() async {
    try {
      Response response = await getHttp(Endpoints.lookupRoles());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List) {
          return data
              .map((json) => GetRoleModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data['data'] is List) {
          return (data['data'] as List)
              .map((json) => GetRoleModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map && data['roles'] is List) {
          return (data['roles'] as List)
              .map((json) => GetRoleModel.fromJson(json as Map<String, dynamic>))
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
