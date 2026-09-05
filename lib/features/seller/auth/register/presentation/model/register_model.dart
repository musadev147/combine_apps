class PostRegisterModel {
  bool? success;
  User? user;

  PostRegisterModel({this.success, this.user});

  PostRegisterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'] as bool?;
    user = json['user'] != null ? new User.fromJson(json['user'] as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  String? id;
  String? email;
  String? name;
  String? permanentAddress;
  String? presentAddress;
  String? phoneNumber;
  Null? image;
  String? role;
  bool? isActive;
  bool? isStaff;

  User({
    this.id,
    this.email,
    this.name,
    this.permanentAddress,
    this.presentAddress,
    this.phoneNumber,
    this.image,
    this.role,
    this.isActive,
    this.isStaff,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    email = json['email'] as String?;
    name = json['name'] as String?;
    permanentAddress = json['permanent_address'] as String?;
    presentAddress = json['present_address'] as String?;
    phoneNumber = json['phone_number'] as String?;
    image = json['image'] as Null?;
    role = json['role'] as String?;
    isActive = json['is_active'] as bool?;
    isStaff = json['is_staff'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['name'] = this.name;
    data['permanent_address'] = this.permanentAddress;
    data['present_address'] = this.presentAddress;
    data['phone_number'] = this.phoneNumber;
    data['image'] = this.image;
    data['role'] = this.role;
    data['is_active'] = this.isActive;
    data['is_staff'] = this.isStaff;
    return data;
  }
}

class PostRegisterRole {
  String? id;
  String? value;

  PostRegisterRole({this.id, this.value});

  PostRegisterRole.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    value = json['value']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['value'] = this.value;
    return data;
  }
}
