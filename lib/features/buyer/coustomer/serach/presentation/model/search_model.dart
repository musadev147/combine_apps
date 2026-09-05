class GetSerachModel {
  String? id;
  String? categoryName;
  String? tagname;
  String? region;
  bool? isTrending;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? category;

  GetSerachModel({
    this.id,
    this.categoryName,
    this.tagname,
    this.region,
    this.isTrending,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  GetSerachModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    categoryName = json['category_name']?.toString();
    tagname = (json['tagname'] ?? json['tag_name'] ?? json['name'])?.toString();
    region = json['region']?.toString();
    isTrending = json['is_trending'] is bool 
        ? json['is_trending'] as bool 
        : (json['is_trending']?.toString() == 'true');
    isActive = json['is_active'] is bool 
        ? json['is_active'] as bool 
        : (json['is_active']?.toString() == 'true');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    category = (json['category'] ?? json['category_id'])?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_name'] = categoryName;
    data['tagname'] = tagname;
    data['region'] = region;
    data['is_trending'] = isTrending;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['category'] = category;
    return data;
  }
}
