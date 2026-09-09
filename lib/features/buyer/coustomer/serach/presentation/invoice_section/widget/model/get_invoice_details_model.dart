class GetInvoiceDetailsModel {
  String? id;
  String? totalPrice;
  String? address;
  String? phoneNumber;
  String? pricePerPiece;
  int? quantity;
  String? productName;
  bool? isConfirm;
  bool? buyerConfirmedDelivery;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? buyer;
  String? vendor;
  Null? tag;
  String? shortNote;
  String? deliveryCharge;
  String? serviceCharge;

  GetInvoiceDetailsModel(
      {this.id,
        this.totalPrice,
        this.address,
        this.phoneNumber,
        this.pricePerPiece,
        this.quantity,
        this.productName,
        this.isConfirm,
        this.buyerConfirmedDelivery,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.buyer,
        this.vendor,
        this.tag,
        this.shortNote,
        this.deliveryCharge,
        this.serviceCharge});

  GetInvoiceDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalPrice = json['total_price'];
    address = json['address'];
    phoneNumber = json['phone_number'];
    pricePerPiece = json['price_per_piece'];
    quantity = json['quantity'];
    productName = json['product_name'];
    isConfirm = json['is_confirm'];
    buyerConfirmedDelivery = json['buyer_confirmed_delivery'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    buyer = json['buyer'];
    vendor = json['vendor'];
    tag = json['tag'];
    shortNote = json['short_note'];
    deliveryCharge = json['delivery_charge']?.toString();
    serviceCharge = json['service_charge']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['total_price'] = this.totalPrice;
    data['address'] = this.address;
    data['phone_number'] = this.phoneNumber;
    data['price_per_piece'] = this.pricePerPiece;
    data['quantity'] = this.quantity;
    data['product_name'] = this.productName;
    data['is_confirm'] = this.isConfirm;
    data['buyer_confirmed_delivery'] = this.buyerConfirmedDelivery;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['buyer'] = this.buyer;
    data['vendor'] = this.vendor;
    data['tag'] = this.tag;
    data['short_note'] = this.shortNote;
    data['delivery_charge'] = this.deliveryCharge;
    data['service_charge'] = this.serviceCharge;
    return data;
  }
}
