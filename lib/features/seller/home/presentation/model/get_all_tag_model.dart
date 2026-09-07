class GetAllTagModel {
  int? count;
  String? next;
  String? previous;
  List<Results>? results;

  GetAllTagModel({this.count, this.next, this.previous, this.results});

  GetAllTagModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String? id;
  String? categoryName;
  String? tagname;
  bool? isTrending;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  String? category;
  String? adminTag;
  String? region;
  String? vendor;

  String get tagName {
    final base = tagname ?? '';
    if (region != null && region!.trim().isNotEmpty) {
      return "$base (${region!.trim()})";
    }
    return base;
  }
  set tagName(String value) => tagname = value;

  Results(
      {this.id,
        this.categoryName,
        this.tagname,
        this.isTrending,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.category,
        this.adminTag,
        this.region,
        this.vendor});

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryName = json['category_name'];
    tagname = json['tagname'] ?? json['tag_name'] ?? json['name'];
    isTrending = json['is_trending'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    category = json['category'];
    
    if (json['admin_tag'] is Map) {
      adminTag = json['admin_tag']['id']?.toString();
    } else {
      adminTag = json['admin_tag']?.toString();
    }
    
    region = json['region']?.toString();
    
    if (json['vendor'] is Map) {
      vendor = json['vendor']['id']?.toString();
    } else {
      vendor = json['vendor']?.toString();
    }
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
    data['admin_tag'] = this.adminTag;
    data['region'] = this.region;
    data['vendor'] = this.vendor;
    return data;
  }
}
