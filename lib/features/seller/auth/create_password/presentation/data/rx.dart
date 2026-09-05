// Rx variables/state for create_password
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/features/seller/auth/create_password/presentation/model/create_password.dart';
import 'api.dart';

class PostResetPasswordRx extends RxResponseInt<PostResetPasswordModel> {
  final api = PostResetPasswordApi.instance;

  PostResetPasswordRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<PostResetPasswordModel> get valueStreamData => dataFetcher.stream;

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await EasyLoading.show(status: 'Updating password...');

      final data = await api.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      await EasyLoading.dismiss();
      return await handleSuccessWithReturn(data);
    } catch (error) {
      await EasyLoading.dismiss();
      log('ResetPassword Rx error: $error');
      return await handleErrorWithReturn(error);
    }
  }

  @override
  Future<bool> handleSuccessWithReturn(PostResetPasswordModel data) async {
    AppToast.success(data.message ?? 'Password reset successfully');
    dataFetcher.sink.add(data);
    return true;
  }

  @override
  Future<bool> handleErrorWithReturn(error) async {
    String message = 'Failed to reset password';

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
