import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/post_support_model.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';

class SupportApi {
  static final SupportApi _singleton = SupportApi._internal();
  SupportApi._internal();
  static SupportApi get instance => _singleton;

  Future<bool> submitSupportTicket(PostSupportModel supportModel) async {
    try {
      final payload = supportModel.toJson();
      log("SUBMIT SUPPORT TICKET REQUEST PAYLOAD: $payload");
      final response = await postHttp(Endpoints.supportSubmit(), payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (error) {
      log("SUBMIT SUPPORT TICKET API ERROR: $error");
      return false;
    }
  }
}
