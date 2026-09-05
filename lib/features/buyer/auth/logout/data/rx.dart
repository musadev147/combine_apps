import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide Response;
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/services/web_socket_service.dart';

class PostLogoutApi {
  static final PostLogoutApi _singleton = PostLogoutApi._internal();
  PostLogoutApi._internal();
  static PostLogoutApi get instance => _singleton;

  Future<Map<String, dynamic>> logout() async {
    try {
      Response response = await postHttp(Endpoints.logOut(), {});
      return (response.data as Map<String, dynamic>?) ?? {};
    } catch (error) {
      log("LOGOUT API ERROR: $error");
      rethrow;
    }
  }
}

class PostLogoutRx extends RxResponseInt<Map<String, dynamic>> {
  final api = PostLogoutApi.instance;

  PostLogoutRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<Map<String, dynamic>> get valueStreamData => dataFetcher.stream;

  Future<bool> logOut() async {
    try {
      await EasyLoading.show(status: "Logging out...");
      final data = await api.logout();
      await EasyLoading.dismiss();
      return await handleSuccessWithReturn(data);
    } catch (error) {
      await EasyLoading.dismiss();
      log("Logout error: $error");
      return await handleErrorWithReturn(error);
    }
  }

  @override
  Future<bool> handleSuccessWithReturn(Map<String, dynamic> data) async {
    AppToast.success("Logged Out Successfully");

    await appData.write(kKeyIsLoggedIn, false);
    await appData.remove(kKeyAccessToken);
    await appData.remove(kKeyUserID);
    await appData.remove(kKeyEmail);
    DioSingleton.instance.update("");

    Get.find<WebSocketService>().disconnect();

    Get.offAllNamed(Routes.LOGIN);
    return true;
  }

  @override
  Future<bool> handleErrorWithReturn(error) async {
    // Force logout on client side even if API fails
    await appData.write(kKeyIsLoggedIn, false);
    await appData.remove(kKeyAccessToken);
    await appData.remove(kKeyUserID);
    await appData.remove(kKeyEmail);
    DioSingleton.instance.update("");
    
    Get.find<WebSocketService>().disconnect();

    Get.offAllNamed(Routes.LOGIN);
    return true;
  }
}
