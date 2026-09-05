import 'dart:convert';
import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/get_invoice_model.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/get_invoices_details-model.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

import 'package:bd_shope_combined/features/seller/home/presentation/model/post_invoice_model.dart';

class InvoiceApi {
  static final InvoiceApi _singleton = InvoiceApi._internal();
  InvoiceApi._internal();
  static InvoiceApi get instance => _singleton;

  Future<List<GetInvoiceModel>> fetchInvoices() async {
    try {
      final response = await getHttp(Endpoints.invoice());

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }
        if (data is List) {
          return data.map((json) => GetInvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map && data.containsKey('results')) {
          final results = data['results'];
          if (results is List) {
            return results.map((json) => GetInvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
          }
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH INVOICES API ERROR: $error");
      rethrow;
    }
  }

  Future<bool> createInvoice(PostInvoiceModel invoiceModel) async {
    try {
      final payload = invoiceModel.toJson();
      log("CREATE INVOICE REQUEST PAYLOAD: $payload");
      final response = await postHttp(Endpoints.invoice(), payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (error) {
      log("CREATE INVOICE API ERROR: $error");
      return false;
    }
  }

  Future<GetDetailsInvoiceModel?> fetchInvoiceDetails(String id) async {
    try {
      final response = await getHttp(Endpoints.invoiceDetails(id: id));

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }
        if (data is Map) {
          return GetDetailsInvoiceModel.fromJson(data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (error) {
      log("FETCH INVOICE DETAILS API ERROR: $error");
      return null;
    }
  }

  Future<bool> updateDeliveryStatus(String id, bool confirmed) async {
    try {
      final response = await patchHttp(
        Endpoints.invoiceDetails(id: id),
        {"buyer_confirmed_delivery": confirmed},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (error) {
      log("UPDATE DELIVERY STATUS API ERROR: $error");
      return false;
    }
  }

  Future<bool> updateInvoiceStatus(String id, String status) async {
    try {
      final response = await patchHttp(
        Endpoints.invoiceDetails(id: id),
        {"status": status},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (error) {
      log("UPDATE INVOICE STATUS API ERROR: $error");
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchDailyBalance() async {
    try {
      final response = await getHttp("/invoice/vendor/daily-balance/");
      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
      return null;
    } catch (error) {
      log("FETCH DAILY BALANCE API ERROR: $error");
      return null;
    }
  }
}
