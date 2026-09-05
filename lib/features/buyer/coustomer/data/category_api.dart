import 'dart:developer';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/all_catagory_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/sub_category_model.dart';
import 'package:bd_shope_combined/features/buyer/home/home_screen/model/tranding_model.dart';
import '/networks/endpoints.dart';

class CategoryApi {
  static final CategoryApi _singleton = CategoryApi._internal();
  CategoryApi._internal();
  static CategoryApi get instance => _singleton;

  Future<List<Results>> fetchCategories() async {
    try {
      final response = await getHttp(Endpoints.categories());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final model = AllCategoryModel.fromJson(data);
          return model.results ?? [];
        } else if (data is List) {
          return data.map((json) => Results.fromJson(json as Map<String, dynamic>)).toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH CATEGORIES API ERROR: $error");
      rethrow;
    }
  }

  Future<List<AllSubCategoryModel>> fetchSubCategories(String categoryId) async {
    try {
      final response = await getHttp(Endpoints.subCategories(id: categoryId));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => AllSubCategoryModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH SUB CATEGORIES API ERROR: $error");
      rethrow;
    }
  }

  Future<List<TrandingModel>> fetchTrendingTags() async {
    try {
      final response = await getHttp(Endpoints.trendingTags());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => TrandingModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        return [];
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      log("FETCH TRENDING TAGS API ERROR: $error");
      rethrow;
    }
  }
}
