import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/buyer_profile_model.dart';

class BuyerProfileApi {
  static final BuyerProfileApi _singleton = BuyerProfileApi._internal();
  BuyerProfileApi._internal();
  static BuyerProfileApi get instance => _singleton;

  Future<BuyerProfileModel> getProfile(String id) async {
    try {
      final response = await getHttp(Endpoints.buyerProfile(id: id));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return BuyerProfileModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("GET BUYER PROFILE API ERROR: $error");
      rethrow;
    }
  }
}
