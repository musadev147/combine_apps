import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/get_invoice_model.dart';
import 'invoice_api.dart';

class GetInvoiceRx extends RxResponseInt<List<GetInvoiceModel>> {
  final api = InvoiceApi.instance;

  GetInvoiceRx({required super.empty, required super.dataFetcher});

  ValueStream<List<GetInvoiceModel>> get valueStreamData => dataFetcher.stream;

  Future<List<GetInvoiceModel>> fetchInvoices() async {
    try {
      List<GetInvoiceModel> data = await api.fetchInvoices();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  List<GetInvoiceModel> handleSuccessWithReturn(List<GetInvoiceModel> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  List<GetInvoiceModel> handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return [];
  }
}
