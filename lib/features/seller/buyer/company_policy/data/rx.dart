import 'dart:developer';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/features/seller/buyer/company_policy/model/get_company_model.dart';
import 'api.dart';

class GetCompanyPolicyRx extends RxResponseInt<GetCompanyModel> {
  final api = CompanyPolicyApi.instance;

  GetCompanyPolicyRx({required super.empty, required super.dataFetcher});

  ValueStream<GetCompanyModel> get valueStreamData => dataFetcher.stream;

  Future<GetCompanyModel> fetchCompanyPolicies() async {
    try {
      GetCompanyModel data = await api.fetchCompanyPolicies();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  GetCompanyModel handleSuccessWithReturn(GetCompanyModel data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  GetCompanyModel handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return empty;
  }
}
