import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/get_adds_model.dart';
import 'invoice_api.dart';

class GetAdsRx extends RxResponseInt<List<GetAdsModel>> {
  final api = InvoiceApi.instance;

  GetAdsRx({required super.empty, required super.dataFetcher});

  ValueStream<List<GetAdsModel>> get valueStreamData => dataFetcher.stream;

  Future<List<GetAdsModel>> fetchAds() async {
    try {
      List<GetAdsModel> data = await api.fetchAds();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  List<GetAdsModel> handleSuccessWithReturn(List<GetAdsModel> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  List<GetAdsModel> handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return [];
  }
}

final getAdsRx = GetAdsRx(
  empty: [],
  dataFetcher: BehaviorSubject<List<GetAdsModel>>(),
);
