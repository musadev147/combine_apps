// Models for buyer_profile
class ProfilePatchModel {
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

  ProfilePatchModel(
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

  ProfilePatchModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    permanentAddress = json['permanent_address'];
    presentAddress = json['present_address'];
    phoneNumber = json['phone_number'];
    image = json['image'];
    role = json['role'];
    isActive = json['is_active'];
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
    data['is_staff'] = this.isStaff;
    return data;
  }
}
