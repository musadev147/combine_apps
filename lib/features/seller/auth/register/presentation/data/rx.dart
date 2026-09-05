import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/features/seller/auth/register/presentation/model/register_model.dart';
import 'api.dart';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dio/dio.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';


class PostRegisterRx extends RxResponseInt<PostRegisterModel> {
  final api = PostRegisterApi.instance;

  PostRegisterRx({required super.empty, required super.dataFetcher});

  ValueStream<PostRegisterModel> get valueStreamData => dataFetcher.stream;

  Future<bool> signUpdata({
    required String name,
    required String email,
    required String password,
    required String password_confirmation,
    required String role,
    required String phoneNumber,
    required String permanentAddress,
    required String presentAddress,
    File? avatar,
  }) async {
    try {
      await EasyLoading.show(status: "Creating account...");
      PostRegisterModel data = await api.signUpdata(
        name: name,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        user_role: role,
        phoneNumber: phoneNumber,
        permanentAddress: permanentAddress,
        presentAddress: presentAddress,
        avatar: avatar,
      );

      await EasyLoading.dismiss();
      return await handleSuccessWithReturn(data);
    } catch (error) {
      await EasyLoading.dismiss();
      log("RX ERROR: $error");
      return await handleErrorWithReturn(error);
    }
  }

  @override
  Future<bool> handleSuccessWithReturn(PostRegisterModel data) async {
    AppToast.success(data.user != null ? "Registration Successful" : "Success");
    dataFetcher.sink.add(data);
    return true;
  }

  @override
  Future<bool> handleErrorWithReturn(error) async {
    String message = "Something went wrong";
    if (error is DioException) {
      final failure = ErrorHandler.handle(error).failure;
      message = failure.responseMessage;
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }
    AppToast.error(message);
    await Future.delayed(const Duration(seconds: 2));
    return false;
  }
}

class GetRolesRx extends RxResponseInt<List<PostRegisterRole>> {
  final api = PostRegisterApi.instance;

  GetRolesRx({required super.empty, required super.dataFetcher});

  ValueStream<List<PostRegisterRole>> get valueStreamData => dataFetcher.stream;

  Future<List<PostRegisterRole>> fetchRoles() async {
    try {
      List<PostRegisterRole> data = await api.getRoles();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  List<PostRegisterRole> handleSuccessWithReturn(List<PostRegisterRole> data) {
    dataFetcher.sink.add(data);
    return data;
  }

  @override
  List<PostRegisterRole> handleErrorWithReturn(error) {
    dataFetcher.sink.add(empty);
    return [];
  }
}

