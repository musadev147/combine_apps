class EditProfileResponseModel {
  bool? success;
  String? message;
  UserProfile? user;

  EditProfileResponseModel({this.success, this.message, this.user});

  EditProfileResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    message = json['message'] as String?;
    if (json.containsKey('user')) {
      user = json['user'] != null
          ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
          : null;
    } else if (json.containsKey('id')) {
      user = UserProfile.fromJson(json);
      success = true;
      message = "Profile updated successfully";
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class UserProfile {
  String? id;
  String? email;
  String? name;
  String? permanentAddress;
  String? presentAddress;
  String? phoneNumber;
  String? image;
  String? role;
  bool? isActive;

  UserProfile({
    this.id,
    this.email,
    this.name,
    this.permanentAddress,
    this.presentAddress,
    this.phoneNumber,
    this.image,
    this.role,
    this.isActive,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    email = json['email'] as String?;
    name = json['name'] as String?;
    permanentAddress = json['permanent_address'] as String?;
    presentAddress = json['present_address'] as String?;
    phoneNumber = json['phone_number'] as String?;
    image = json['image'] as String?;
    role = json['role'] as String?;
    isActive = json['is_active'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['name'] = name;
    data['permanent_address'] = permanentAddress;
    data['present_address'] = presentAddress;
    data['phone_number'] = phoneNumber;
    data['image'] = image;
    data['role'] = role;
    data['is_active'] = isActive;
    return data;
  }
}
