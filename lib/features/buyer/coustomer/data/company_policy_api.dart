import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/get_company_model.dart';

class CompanyPolicyApi {
  static final CompanyPolicyApi _singleton = CompanyPolicyApi._internal();
  CompanyPolicyApi._internal();
  static CompanyPolicyApi get instance => _singleton;

  Future<GetCompanyModel> fetchCompanyPolicies() async {
    try {
      final response = await getHttp(Endpoints.companyPolicies());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetCompanyModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH COMPANY POLICIES API ERROR: $error");
      rethrow;
    }
  }
}
