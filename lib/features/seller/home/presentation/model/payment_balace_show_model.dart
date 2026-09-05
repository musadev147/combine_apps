class GetMybleanceModel {
  String? id;
  num? totalMinutes;
  num? totalWalletBalance;
  num? paidWalletBalance;
  num? currentWalletBalance;
  String? password;
  String? lastLogin;
  bool? isSuperuser;
  String? firstName;
  String? lastName;
  bool? isStaff;
  bool? isActive;
  String? dateJoined;
  String? email;
  String? name;
  String? permanentAddress;
  String? presentAddress;
  String? phoneNumber;
  String? image;
  bool? isOnline;
  bool? isEmailVerified;
  String? role;
  List<dynamic>? groups;
  List<dynamic>? userPermissions;

  GetMybleanceModel(
      {this.id,
        this.totalMinutes,
        this.totalWalletBalance,
        this.paidWalletBalance,
        this.currentWalletBalance,
        this.password,
        this.lastLogin,
        this.isSuperuser,
        this.firstName,
        this.lastName,
        this.isStaff,
        this.isActive,
        this.dateJoined,
        this.email,
        this.name,
        this.permanentAddress,
        this.presentAddress,
        this.phoneNumber,
        this.image,
        this.isOnline,
        this.isEmailVerified,
        this.role,
        this.groups,
        this.userPermissions});

  GetMybleanceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalMinutes = json['total_minutes'];
    totalWalletBalance = json['total_wallet_balance'];
    paidWalletBalance = json['paid_wallet_balance'];
    currentWalletBalance = json['current_wallet_balance'];
    password = json['password'];
    lastLogin = json['last_login'];
    isSuperuser = json['is_superuser'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    isStaff = json['is_staff'];
    isActive = json['is_active'];
    dateJoined = json['date_joined'];
    email = json['email'];
    name = json['name'];
    permanentAddress = json['permanent_address'];
    presentAddress = json['present_address'];
    phoneNumber = json['phone_number'];
    image = json['image'];
    isOnline = json['is_online'];
    isEmailVerified = json['is_email_verified'];
    role = json['role'];
    if (json['groups'] != null) {
      groups = json['groups'] as List<dynamic>;
    }
    if (json['user_permissions'] != null) {
      userPermissions = json['user_permissions'] as List<dynamic>;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['total_minutes'] = this.totalMinutes;
    data['total_wallet_balance'] = this.totalWalletBalance;
    data['paid_wallet_balance'] = this.paidWalletBalance;
    data['current_wallet_balance'] = this.currentWalletBalance;
    data['password'] = this.password;
    data['last_login'] = this.lastLogin;
    data['is_superuser'] = this.isSuperuser;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['is_staff'] = this.isStaff;
    data['is_active'] = this.isActive;
    data['date_joined'] = this.dateJoined;
    data['email'] = this.email;
    data['name'] = this.name;
    data['permanent_address'] = this.permanentAddress;
    data['present_address'] = this.presentAddress;
    data['phone_number'] = this.phoneNumber;
    data['image'] = this.image;
    data['is_online'] = this.isOnline;
    data['is_email_verified'] = this.isEmailVerified;
    data['role'] = this.role;
    if (this.groups != null) {
      data['groups'] = this.groups;
    }
    if (this.userPermissions != null) {
      data['user_permissions'] = this.userPermissions;
    }
    return data;
  }
}
