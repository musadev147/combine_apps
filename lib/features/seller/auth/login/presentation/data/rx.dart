import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/auth/register/presentation/data/api.dart';
import 'package:bd_shope_combined/features/seller/auth/register/presentation/model/register_model.dart';
import 'package:bd_shope_combined/features/seller/auth/login/presentation/model/login_model.dart';
import 'api.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/data/call_controller.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/data/notification_service.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/services/web_socket_service.dart';
import 'package:bd_shope_combined/services/agora_service.dart';

class PostLoginRx extends RxResponseInt<PostLoginModel> {
  final api = PostLoginApi.instance;

  PostLoginRx({required super.empty, required super.dataFetcher});

  ValueStream<PostLoginModel> get valueStreamData => dataFetcher.stream;

  Future<bool> loginFunc({
    required String email,
    required String password,
  }) async {
    try {
      await EasyLoading.show(status: "Logging in...");

      final data = await api.loginData(email: email, password: password);

      await EasyLoading.dismiss();
      return await handleSuccessWithReturn(data);
    } catch (error) {
      await EasyLoading.dismiss();
      log("Login error: $error");
      return await handleErrorWithReturn(error);
    }
  }

  @override
  Future<bool> handleSuccessWithReturn(PostLoginModel data) async {
    final roleId = data.user?.role?.toLowerCase() ?? "";
    String roleName = roleId;

    if (roleId.isNotEmpty && roleId.contains('-')) {
      try {
        final roles = await PostRegisterApi.instance.getRoles();
        final role = roles.firstWhere((r) => r.id == roleId, orElse: () => PostRegisterRole());
        if (role.value != null) {
          roleName = role.value!.toLowerCase();
        }
      } catch (e) {
        log("Role fetch error during login: $e");
      }
    }

    if (roleName != 'vendor' && roleName != 'seller') {
      AppToast.error("Role mismatch: Account is '$roleName', not Vendor. Please use the correct app.");
      return false;
    }

    AppToast.success("Login Successful");

    final accessToken = data.accessToken ?? "";
    final refreshToken = data.refreshToken ?? "";
    final id = data.user?.id ?? "";
    final email = data.user?.email ?? "";
    final name = data.user?.name ?? "";
    final phone = data.user?.phoneNumber ?? "";
    final image = data.user?.image ?? "";
    final presentAddress = data.user?.presentAddress ?? "";
    final permanentAddress = data.user?.permanentAddress ?? "";

    await appData.write(kKeyIsLoggedIn, true);
    await appData.write('userRole', roleName);
    await appData.write(kKeyEmail, email);
    await appData.write(kKeyAccessToken, accessToken);
    if (refreshToken.isNotEmpty) {
      await appData.write('refresh_token', refreshToken);
    }
    await appData.write(kKeyUserID, id.toString());
    if (name.isNotEmpty) await appData.write(kKeyUserName, name);
    if (phone.isNotEmpty) await appData.write(kPhone, phone);
    if (image.isNotEmpty) await appData.write('avatar_path', image);
    if (presentAddress.isNotEmpty) await appData.write('present_address', presentAddress);
    if (permanentAddress.isNotEmpty) await appData.write('permanent_address', permanentAddress);

    DioSingleton.instance.update(accessToken);

    // Establish real-time WebSocket connection
    try {
      if (!Get.isRegistered<WebSocketService>()) {
        Get.put(WebSocketService(), permanent: true);
      }
      if (!Get.isRegistered<AgoraService>()) {
        Get.put(AgoraService(), permanent: true);
      }
      if (!Get.isRegistered<ConnectionController>()) {
        Get.put(ConnectionController(), permanent: true);
      }
      if (!Get.isRegistered<CallController>()) {
        Get.put(CallController(), permanent: true);
      }
      Get.find<WebSocketService>().connect();
      Get.find<CallController>().connectSocket(accessToken);
    } catch (e) {
      log("PostLoginRx: Failed to auto-connect Call WebSocket: $e");
    }

    try {
      final notificationService = Get.put(NotificationService.instance);
      notificationService.registerToken();
    } catch (e) {
      log("PostLoginRx: Failed to register FCM token: $e");
    }

    return true;
  }

  @override
  Future<bool> handleErrorWithReturn(error) async {
    String message = "Login failed";

    if (error is DioException) {
      final failure = ErrorHandler.handle(error).failure;
      message = failure.responseMessage;
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    AppToast.error(message);
    return false;
  }
}
