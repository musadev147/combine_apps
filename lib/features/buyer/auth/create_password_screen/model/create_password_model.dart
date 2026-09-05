class PostResetPasswordModel {
  String? message;
  bool? success;

  PostResetPasswordModel({this.message, this.success});

  PostResetPasswordModel.fromJson(Map<String, dynamic> json) {
    message = json['message'] as String?;
    success = json['success'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['success'] = success;
    return data;
  }
}
