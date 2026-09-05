class PostTagCreateModel {
  String? id;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? vendor;
  String? adminTag;

  PostTagCreateModel(
      {this.id,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.vendor,
        this.adminTag});

  PostTagCreateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    vendor = json['vendor'];
    adminTag = json['admin_tag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['vendor'] = this.vendor;
    data['admin_tag'] = this.adminTag;
    return data;
  }
}
