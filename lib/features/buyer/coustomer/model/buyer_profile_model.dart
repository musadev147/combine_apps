class BuyerProfileModel {
  String? id;
  String? email;
  String? name;
  String? walletBalance;
  String? permanentAddress;
  String? presentAddress;
  String? phoneNumber;
  String? image;

  BuyerProfileModel({
    this.id,
    this.email,
    this.name,
    this.walletBalance,
    this.permanentAddress,
    this.presentAddress,
    this.phoneNumber,
    this.image,
  });

  BuyerProfileModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    walletBalance = json['wallet_balance'];
    permanentAddress = json['permanent_address'];
    presentAddress = json['present_address'];
    phoneNumber = json['phone_number'];
    image = json['image'];
  }
}
