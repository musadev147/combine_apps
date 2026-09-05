import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/model/search_model.dart';
import 'api.dart';

class GetSerachTagRx extends RxResponseInt<List<GetSerachModel>> {
  final api = GetSerachTagApi.instance;

  GetSerachTagRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<List<GetSerachModel>> get valueStreamData => dataFetcher.stream;

  Future<List<GetSerachModel>> searchTag({required String query}) async {
    try {
      final data = await api.fetchTags(query: query);
      return (handleSuccessWithReturn(data) as List<dynamic>).cast<GetSerachModel>();
    } catch (error) {
      log('Search tag rx error: $error');
      return (handleErrorWithReturn(error) as List<dynamic>).cast<GetSerachModel>();
    }
  }
}
