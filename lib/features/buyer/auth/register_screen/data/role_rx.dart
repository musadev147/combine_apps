import 'package:bd_shope_combined/features/buyer/auth/register_screen/model/register_role.dart';
import 'role_api.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';

class GetRolesRx extends RxResponseInt<List<GetRoleModel>> {
  final api = GetRoleApi.instance;

  GetRolesRx({required super.empty, required super.dataFetcher});

  ValueStream<List<GetRoleModel>> get valueStreamData => dataFetcher.stream;

  Future<List<GetRoleModel>> fetchRoles() async {
    try {
      List<GetRoleModel> data = await api.getRoles();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  List<GetRoleModel> handleSuccessWithReturn(List<GetRoleModel> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  List<GetRoleModel> handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return [];
  }
}
