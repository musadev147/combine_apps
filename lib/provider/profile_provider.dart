import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';

import 'package:bd_shope_combined/features/buyer/coustomer/data/buyer_profile_api.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = "";
  String _email = "";
  String _phone = "";
  String _gender = "";
  String _dateOfBirth = "";
  String _avatar = "";
  String _password = "";
  String _presentAddress = "";
  String _permanentAddress = "";
  File? selectedFile;

  ProfileProvider() {
    loadProfile();
  }

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get gender => _gender;
  String get dateOfBirth => _dateOfBirth;
  String get avatar => _avatar;
  String get password => _password;
  String get presentAddress => _presentAddress;
  String get permanentAddress => _permanentAddress;

  void loadProfile() async {
    _name = appData.read(kKeyUserName) ?? "John Doe";
    _email = appData.read(kKeyEmail) ?? "johndoe@email.com";
    _phone = appData.read(kPhone) ?? "";
    _gender = appData.read('gender') ?? "Male";
    _dateOfBirth = appData.read('date_of_birth') ?? "1995-01-01";
    _avatar = appData.read('avatar_path') ?? "";
    _password = appData.read('password') ?? "123456";
    _presentAddress = appData.read('present_address') ?? "shaymoli";
    _permanentAddress = appData.read('permanent_address') ?? "Dhaka,banani";
    notifyListeners();

    String? userId = appData.read(kKeyUserID);
    if (userId != null && userId.isNotEmpty) {
      try {
        final profile = await BuyerProfileApi.instance.getProfile(userId);
        if (profile.name != null && profile.name!.isNotEmpty) _name = profile.name!;
        if (profile.email != null && profile.email!.isNotEmpty) _email = profile.email!;
        if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty) _phone = profile.phoneNumber!;
        if (profile.presentAddress != null && profile.presentAddress!.isNotEmpty) _presentAddress = profile.presentAddress!;
        if (profile.permanentAddress != null && profile.permanentAddress!.isNotEmpty) _permanentAddress = profile.permanentAddress!;
        _avatar = profile.image ?? "";
        
        // Update local storage too
        appData.write(kKeyUserName, _name);
        appData.write(kKeyEmail, _email);
        appData.write(kPhone, _phone);
        appData.write('avatar_path', _avatar);
        
        notifyListeners();
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }
    }
  }

  void file(File? selectFile) {
    selectedFile = selectFile;
    if (selectFile != null) {
      _avatar = selectFile.path;
      appData.write('avatar_path', selectFile.path);
    }
    notifyListeners();
  }

  void updateProfile({
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String dateOfBirth,
    String? password,
    String? presentAddr,
    String? permanentAddr,
  }) {
    _name = fullName;
    _email = email;
    _phone = phone;
    _gender = gender;
    _dateOfBirth = dateOfBirth;
    if (password != null && password.isNotEmpty) {
      _password = password;
      appData.write('password', password);
    }
    if (presentAddr != null) {
      _presentAddress = presentAddr;
      appData.write('present_address', presentAddr);
    }
    if (permanentAddr != null) {
      _permanentAddress = permanentAddr;
      appData.write('permanent_address', permanentAddr);
    }

    appData.write(kKeyUserName, fullName);
    appData.write(kKeyEmail, email);
    appData.write(kPhone, phone);
    appData.write('gender', gender);
    appData.write('date_of_birth', dateOfBirth);
    
    notifyListeners();
  }

  void changeInformation({
    required String fullName,
    required String email,
    required String phone,
    required String gender,
    required String dateOfBirth,
    required String avatar,
    String? presentAddr,
    String? permanentAddr,
  }) {
    _name = fullName;
    _email = email;
    _phone = phone;
    _gender = gender;
    _dateOfBirth = dateOfBirth;
    _avatar = avatar;
    if (presentAddr != null) {
      _presentAddress = presentAddr;
      appData.write('present_address', presentAddr);
    }
    if (permanentAddr != null) {
      _permanentAddress = permanentAddr;
      appData.write('permanent_address', permanentAddr);
    }
    
    appData.write(kKeyUserName, fullName);
    appData.write(kKeyEmail, email);
    appData.write(kPhone, phone);
    appData.write('gender', gender);
    appData.write('date_of_birth', dateOfBirth);
    appData.write('avatar_path', avatar);
    
    notifyListeners();
  }
}