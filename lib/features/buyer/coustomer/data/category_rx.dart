import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/all_catagory_model.dart';
import 'package:bd_shope_combined/features/buyer/home/home_screen/model/tranding_model.dart';
import 'category_api.dart';

class GetCategoryRx extends RxResponseInt<List<Results>> {
  final api = CategoryApi.instance;

  GetCategoryRx({required super.empty, required super.dataFetcher});

  ValueStream<List<Results>> get valueStreamData => dataFetcher.stream;

  Future<List<Results>> fetchCategories() async {
    try {
      List<Results> data = await api.fetchCategories();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  List<Results> handleSuccessWithReturn(List<Results> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  List<Results> handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return [];
  }
}

class GetTrendingTagsRx extends RxResponseInt<List<TrandingModel>> {
  final api = CategoryApi.instance;

  GetTrendingTagsRx({required super.empty, required super.dataFetcher});

  ValueStream<List<TrandingModel>> get valueStreamData => dataFetcher.stream;

  Future<List<TrandingModel>> fetchTrendingTags() async {
    try {
      List<TrandingModel> data = await api.fetchTrendingTags();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  List<TrandingModel> handleSuccessWithReturn(List<TrandingModel> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  List<TrandingModel> handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return [];
  }
}
