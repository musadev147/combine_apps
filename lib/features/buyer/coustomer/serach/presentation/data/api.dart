import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/model/search_model.dart';

class GetSerachTagApi {
  static final GetSerachTagApi _singleton = GetSerachTagApi._internal();
  GetSerachTagApi._internal();
  static GetSerachTagApi get instance => _singleton;

  Future<List<GetSerachModel>> fetchTags({required String query}) async {
    try {
      final endpoint = Endpoints.searchTag(query: query);
      print("FETCH TAGS REQUEST: $endpoint");
      Response<dynamic> response = await getHttp(endpoint);
      print("FETCH TAGS RESPONSE STATUS: ${response.statusCode}");
      print("FETCH TAGS RESPONSE DATA: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> dataList = [];
        if (response.data is List) {
          dataList = response.data as List<dynamic>;
        } else if (response.data is Map) {
          final map = response.data as Map<String, dynamic>;
          if (map.containsKey('results') && map['results'] is List) {
            dataList = map['results'] as List<dynamic>;
          } else if (map.containsKey('data') && map['data'] is List) {
            dataList = map['data'] as List<dynamic>;
          } else if (map.containsKey('tags') && map['tags'] is List) {
            dataList = map['tags'] as List<dynamic>;
          } else {
            for (var val in map.values) {
              if (val is List) {
                dataList = val;
                break;
              }
            }
          }
        }
        final parsed = dataList.map((json) => GetSerachModel.fromJson(json as Map<String, dynamic>)).toList();
        print("FETCH TAGS PARSED RESULTS COUNT: ${parsed.length}");
        print("FETCH TAGS PARSED NAMES: ${parsed.map((e) => e.tagname).toList()}");
        return parsed;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      print("FETCH TAGS ERROR: $error");
      log('SEARCH TAG API ERROR: $error');
      rethrow;
    }
  }
}
