import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/get_owner_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/build_invoice_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/get_invoice_details_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/get_adds_model.dart';

class InvoiceApi {
  static final InvoiceApi _singleton = InvoiceApi._internal();
  InvoiceApi._internal();
  static InvoiceApi get instance => _singleton;

  Future<List<GetAdsModel>> fetchAds() async {
    try {
      final response = await getHttp(Endpoints.ads());
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        List? resultsList;
        if (data is List) {
          resultsList = data;
        } else if (data is Map && data.containsKey('results')) {
          resultsList = data['results'] as List?;
        }
        if (resultsList != null) {
          return resultsList.map((json) {
            return GetAdsModel.fromJson(json as Map<String, dynamic>);
          }).toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH ADS API ERROR: $error");
      rethrow;
    }
  }

  Future<List<GetOwnerAccountModel>> fetchOwnerPayoutMethods(String vendorId) async {
    try {
      final response = await getHttp(Endpoints.ownerPayoutMethods());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        log("RAW OWNER PAYOUT METHODS RESPONSE: $data");
        
        List? resultsList;
        if (data is List) {
          resultsList = data;
        } else if (data is Map && data.containsKey('results')) {
          resultsList = data['results'] as List?;
        } else if (data is Map) {
          return [GetOwnerAccountModel.fromJson(data as Map<String, dynamic>)];
        }

        if (resultsList != null) {
          return resultsList.map((json) {
            try {
              return GetOwnerAccountModel.fromJson(json as Map<String, dynamic>);
            } catch (e, stack) {
              log("JSON DECODING ERROR for owner payout method $json: $e", stackTrace: stack);
              rethrow;
            }
          }).toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error, stackTrace) {
      log("FETCH OWNER PAYOUT METHODS API ERROR: $error", stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<GetNotifiInvoiceModel>> fetchInvoices() async {
    try {
      final response = await getHttp(Endpoints.invoice());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        log("RAW INVOICE RESPONSE: $data");
        
        List? resultsList;
        if (data is List) {
          resultsList = data;
        } else if (data is Map && data.containsKey('results')) {
          resultsList = data['results'] as List?;
        }

        if (resultsList != null) {
          return resultsList.map((json) {
            try {
              return GetNotifiInvoiceModel.fromJson(json as Map<String, dynamic>);
            } catch (e, stack) {
              log("JSON DECODING ERROR for item $json: $e", stackTrace: stack);
              rethrow;
            }
          }).toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error, stackTrace) {
      log("FETCH INVOICES API ERROR: $error", stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<GetInvoiceDetailsModel> fetchInvoiceDetails(String id) async {
    try {
      final response = await getHttp(Endpoints.invoiceDetails(id: id));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetInvoiceDetailsModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH INVOICE DETAILS API ERROR: $error");
      rethrow;
    }
  }

  Future<bool> updateDeliveryStatus(String id, bool confirmed) async {
    try {
      final response = await postHttp(
        '/invoice/confirm-delivery/',
        {"invoice_id": id},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final errorMsg = e.response!.data['error'];
        if (errorMsg != null) {
          if (errorMsg.toString().toLowerCase().contains('already confirmed')) {
            // If backend says it's already confirmed, treat it as a success for the UI
            return true;
          }
          throw Exception(errorMsg.toString());
        }
      }
      log("UPDATE DELIVERY STATUS API ERROR: $e");
      rethrow;
    } catch (error) {
      log("UPDATE DELIVERY STATUS API ERROR: $error");
      rethrow;
    }
  }
}
