import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/get_all_invoice_model.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';

class ShortNoteApi {
  static final ShortNoteApi _singleton = ShortNoteApi._internal();
  ShortNoteApi._internal();
  static ShortNoteApi get instance => _singleton;

  Future<List<GetAllInvoiceModel>> fetchShortNotes() async {
    try {
      final response = await getHttp(Endpoints.shortNotes());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => GetAllInvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
        } else if (data is Map && data.containsKey('results')) {
          final results = data['results'];
          if (results is List) {
            return results.map((json) => GetAllInvoiceModel.fromJson(json as Map<String, dynamic>)).toList();
          }
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH SHORT NOTES API ERROR: $error");
      rethrow;
    }
  }

  Future<bool> deleteShortNote(String id) async {
    try {
      final response = await deleteHttp(Endpoints.deleteShortNote(id: id));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }
      return false;
    } catch (error) {
      log("DELETE SHORT NOTE API ERROR: $error");
      return false;
    }
  }
}
