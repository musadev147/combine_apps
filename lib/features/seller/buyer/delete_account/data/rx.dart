import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/features/seller/buyer/delete_account/model/post_delete_account_model.dart';
import 'api.dart';

class DeleteAccountRx extends RxResponseInt<PostAccountModel> {
  final api = DeleteAccountApi.instance;

  DeleteAccountRx({required super.empty, required super.dataFetcher});

  ValueStream<PostAccountModel> get valueStreamData => dataFetcher.stream;

  Future<bool> requestDelete({
    required String email,
    required String password,
  }) async {
    try {
      await EasyLoading.show(status: "Sending OTP...");
      final data = await api.requestDeleteAccount(email: email, password: password);
      await EasyLoading.dismiss();
      return handleSuccessWithReturn(data);
    } catch (error) {
      await EasyLoading.dismiss();
      log("Delete Account Request Rx error: $error");
      return handleErrorWithReturn(error);
    }
  }

  Future<bool> confirmDelete({required String email, required String otp}) async {
    try {
      await EasyLoading.show(status: "Deleting account...");
      final data = await api.confirmDeleteAccount(email: email, otp: otp);
      await EasyLoading.dismiss();
      return handleSuccessWithReturn(data);
    } catch (error) {
      await EasyLoading.dismiss();
      log("Delete Account Confirm Rx error: $error");
      return handleErrorWithReturn(error);
    }
  }

  @override
  Future<bool> handleSuccessWithReturn(PostAccountModel data) async {
    AppToast.success(data.message ?? "Operation successful");
    dataFetcher.sink.add(data);
    return true;
  }

  @override
  Future<bool> handleErrorWithReturn(error) async {
    String message = "Operation failed";

    if (error is DioException) {
      final failure = ErrorHandler.handle(error).failure;
      message = failure.responseMessage;
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    if (message.contains("<!DOCTYPE html>") || message.contains("<html>")) {
      message = "Server error (404/500). Please check endpoints.";
    } else if (message.length > 150) {
      message = "${message.substring(0, 150)}...";
    }

    AppToast.error(message);
    return false;
  }
}
