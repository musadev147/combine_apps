class GetCompanyModel {
  bool? success;
  String? accessToken;
  User? user;

  GetCompanyModel({this.success, this.accessToken, this.user});

  GetCompanyModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    accessToken = json['access_token'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['access_token'] = this.accessToken;
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
  String? image;
  String? role;
  bool? isActive;
  bool? isEmailVerified;
  bool? isStaff;

  User(
      {this.id,
        this.email,
        this.name,
        this.permanentAddress,
        this.presentAddress,
        this.phoneNumber,
        this.image,
        this.role,
        this.isActive,
        this.isEmailVerified,
        this.isStaff});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    permanentAddress = json['permanent_address'];
    presentAddress = json['present_address'];
    phoneNumber = json['phone_number'];
    image = json['image'];
    role = json['role'];
    isActive = json['is_active'];
    isEmailVerified = json['is_email_verified'];
    isStaff = json['is_staff'];
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
    data['is_email_verified'] = this.isEmailVerified;
    data['is_staff'] = this.isStaff;
    return data;
  }
}
