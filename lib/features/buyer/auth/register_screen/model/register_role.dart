class GetRoleModel {
  String? id;
  String? value;

  GetRoleModel({this.id, this.value});

  GetRoleModel.fromJson(Map<String, dynamic> json) {
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
