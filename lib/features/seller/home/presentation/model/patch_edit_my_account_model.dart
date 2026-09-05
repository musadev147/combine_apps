class PatchEditMyAccountModel {
  String? id;
  String? user;
  String? bankName;
  String? accountName;
  String? accountNumber;
  String? branchName;
  String? bkashNumber;
  String? nagadNumber;
  String? createdAt;
  String? updatedAt;

  PatchEditMyAccountModel(
      {this.id,
      this.user,
      this.bankName,
      this.accountName,
      this.accountNumber,
      this.branchName,
      this.bkashNumber,
      this.nagadNumber,
      this.createdAt,
      this.updatedAt});

  PatchEditMyAccountModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'];
    bankName = json['bank_name'];
    accountName = json['account_name'];
    accountNumber = json['account_number'];
    branchName = json['branch_name'];
    bkashNumber = json['bkash_number'];
    nagadNumber = json['nagad_number'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user'] = this.user;
    data['bank_name'] = this.bankName;
    data['account_name'] = this.accountName;
    data['account_number'] = this.accountNumber;
    data['branch_name'] = this.branchName;
    data['bkash_number'] = this.bkashNumber;
    data['nagad_number'] = this.nagadNumber;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
