// Models for forgot_password
class ForgotPasswordModel {
  String? message;
  bool? success;

  ForgotPasswordModel({this.message, this.success});

  ForgotPasswordModel.fromJson(Map<String, dynamic> json) {
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
