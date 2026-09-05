import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/build_invoice_model.dart';
import 'invoice_api.dart';

class GetInvoiceRx extends RxResponseInt<List<GetNotifiInvoiceModel>> {
  final api = InvoiceApi.instance;

  GetInvoiceRx({required super.empty, required super.dataFetcher});

  ValueStream<List<GetNotifiInvoiceModel>> get valueStreamData => dataFetcher.stream;

  Future<List<GetNotifiInvoiceModel>> fetchInvoices() async {
    try {
      List<GetNotifiInvoiceModel> data = await api.fetchInvoices();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  List<GetNotifiInvoiceModel> handleSuccessWithReturn(List<GetNotifiInvoiceModel> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  List<GetNotifiInvoiceModel> handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return [];
  }
}
