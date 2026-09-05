class TrandingModel {
  String? id;
  String? categoryName;
  String? tagname;
  bool? isTrending;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? category;

  TrandingModel(
      {this.id,
        this.categoryName,
        this.tagname,
        this.isTrending,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.category});

  TrandingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    tagname = json['tagname'];
    isTrending = json['is_trending'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_name'] = this.categoryName;
    data['tagname'] = this.tagname;
    data['is_trending'] = this.isTrending;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['category'] = this.category;
    return data;
  }
}
