import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/all_catagory_model.dart';
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
