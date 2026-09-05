class PostLoginModel {
  String? accessToken;
  String? refreshToken;
  User? user;

  PostLoginModel({this.accessToken, this.refreshToken, this.user});

  PostLoginModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'] as String? ?? json['token'] as String?;
    refreshToken = json['refresh_token'] as String? ?? json['refresh'] as String?;
    user = json['user'] != null ? new User.fromJson(json['user'] as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['refresh_token'] = this.refreshToken;
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
        this.isStaff});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String?;
    email = json['email'] as String?;
    name = json['name'] as String?;
    permanentAddress = json['permanent_address'] as String?;
    presentAddress = json['present_address'] as String?;
    phoneNumber = json['phone_number'] as String?;
    image = json['image'] as String?;
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
