import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/networks/rx_base.dart';
import 'package:bd_shope_combined/networks/exception_handler/data_source.dart';
import 'package:bd_shope_combined/common_wigdets/app_toast.dart';
import 'package:bd_shope_combined/provider/profile_provider.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/edit_profile_model.dart';
import 'edit_profile_api.dart';

class EditProfileRx extends RxResponseInt<EditProfileResponseModel> {
  final api = EditProfileApi.instance;

  EditProfileRx({
    required super.empty,
    required super.dataFetcher,
  });

  ValueStream<EditProfileResponseModel> get valueStreamData => dataFetcher.stream;

  Future<bool> editProfileFunc({
    required BuildContext context,
    required String name,
    required String email,
    required String phoneNumber,
    required String permanentAddress,
    required String presentAddress,
    File? image,
  }) async {
    try {
      await EasyLoading.show(status: "Updating profile...");
      final userId = appData.read(kKeyUserID) ?? "";

      final data = await api.updateProfile(
        userId: userId,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        permanentAddress: permanentAddress,
        presentAddress: presentAddress,
        image: image,
      );

      await EasyLoading.dismiss();
      
      // Update the local ProfileProvider
      final profile = Provider.of<ProfileProvider>(context, listen: false);
      profile.changeInformation(
        fullName: data.user?.name ?? name,
        email: data.user?.email ?? email,
        phone: data.user?.phoneNumber ?? phoneNumber,
        gender: profile.gender,
        dateOfBirth: profile.dateOfBirth,
        avatar: data.user?.image ?? profile.avatar,
        presentAddr: data.user?.presentAddress ?? presentAddress,
        permanentAddr: data.user?.permanentAddress ?? permanentAddress,
      );

      AppToast.success(data.message ?? "Profile updated successfully");
      return true;
    } catch (error) {
      await EasyLoading.dismiss();
      log("Edit profile error: $error");
      
      AppToast.error(error.toString());
      return false;
    }
  }
}
