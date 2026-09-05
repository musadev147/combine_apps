import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/features/buyer/auth/forgot_password_screen/model/forgot_password_model.dart';
import 'api.dart';

class PostForgotPasswordRx extends RxResponseInt<ForgotPasswordModel> {
  final api = PostForgotPasswordApi.instance;

  PostForgotPasswordRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<ForgotPasswordModel> get valueStreamData => dataFetcher.stream;

  Future<bool> forgotPasswordFunc({
    required String email,
  }) async {
    try {
      await EasyLoading.show(status: 'Sending code...');

      final data = await api.forgotPassword(
        email: email,
      );

      await EasyLoading.dismiss();
      return await handleSuccessWithReturn(data);
    } catch (error) {
      await EasyLoading.dismiss();
      log('ForgotPassword Rx error: $error');
      return await handleErrorWithReturn(error);
    }
  }

  @override
  Future<bool> handleSuccessWithReturn(ForgotPasswordModel data) async {
    AppToast.success(data.message ?? 'Verification code sent successfully');
    dataFetcher.sink.add(data);
    return true;
  }

  @override
  Future<bool> handleErrorWithReturn(error) async {
    String message = 'Failed to send code';

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
