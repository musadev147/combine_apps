class PostSupportModel {
  String? id;
  String? user;
  String? userDetails;
  String? name;
  String? phoneNumber;
  String? email;
  String? description;
  String? status;
  String? adminNote;
  String? createdAt;
  String? updatedAt;

  PostSupportModel(
      {this.id,
        this.user,
        this.userDetails,
        this.name,
        this.phoneNumber,
        this.email,
        this.description,
        this.status,
        this.adminNote,
        this.createdAt,
        this.updatedAt});

  PostSupportModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    userDetails = json['user_details'];
    name = json['name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
    description = json['description'];
    status = json['status'];
    adminNote = json['admin_note'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user'] = this.user;
    data['user_details'] = this.userDetails;
    data['name'] = this.name;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['description'] = this.description;
    data['status'] = this.status;
    data['admin_note'] = this.adminNote;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
