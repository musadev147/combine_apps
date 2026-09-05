class AllSubCategoryModel {
  String? id;
  String? categoryName;
  String? tagname;
  String? region;
  bool? isTrending;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? category;

  AllSubCategoryModel(
      {this.id,
      this.categoryName,
      this.tagname,
      this.region,
      this.isTrending,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.category});

  AllSubCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    tagname = json['tagname'];
    region = json['region'];
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
    data['region'] = this.region;
    data['is_trending'] = this.isTrending;
    data['is_active'] = this.isActive;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['category'] = this.category;
    return data;
  }
}
