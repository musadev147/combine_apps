class PostInvoiceModel {
  String? totalPrice;
  String? address;
  String? phoneNumber;
  String? pricePerPiece;
  int? quantity;
  String? productName;
  bool? isConfirm;
  bool? buyerConfirmedDelivery;
  String? status;
  String? buyer;
  String? tag;
  String? shortNote;
  String? deliveryCharge;

  PostInvoiceModel({
    this.totalPrice,
    this.address,
    this.phoneNumber,
    this.pricePerPiece,
    this.quantity,
    this.productName,
    this.isConfirm,
    this.buyerConfirmedDelivery,
    this.status,
    this.buyer,
    this.tag,
    this.shortNote,
    this.deliveryCharge,
  });

  PostInvoiceModel.fromJson(Map<String, dynamic> json) {
    totalPrice = json['total_price'];
    address = json['address'];
    phoneNumber = json['phone_number'];
    pricePerPiece = json['price_per_piece'];
    quantity = json['quantity'];
    productName = json['product_name'];
    isConfirm = json['is_confirm'];
    buyerConfirmedDelivery = json['buyer_confirmed_delivery'];
    status = json['status'];
    buyer = json['buyer'];
    tag = json['tag'];
    shortNote = json['short_note'];
    deliveryCharge = json['delivery_charge']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_price'] = totalPrice;
    data['address'] = address;
    data['phone_number'] = phoneNumber;
    data['price_per_piece'] = pricePerPiece;
    data['quantity'] = quantity;
    data['product_name'] = productName;
    data['is_confirm'] = isConfirm;
    data['buyer_confirmed_delivery'] = buyerConfirmedDelivery;
    data['status'] = status;
    data['buyer'] = buyer;
    data['tag'] = tag;
    data['short_note'] = shortNote;
    data['delivery_charge'] = deliveryCharge;
    return data;
  }
}
