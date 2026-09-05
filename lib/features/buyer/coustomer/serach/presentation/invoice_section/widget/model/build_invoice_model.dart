class GetNotifiInvoiceModel {
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
  String? tag;
  String? shortNote;
  String? deliveryCharge;

  GetNotifiInvoiceModel(
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
        this.deliveryCharge});

  GetNotifiInvoiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    totalPrice = json['total_price']?.toString();
    address = json['address']?.toString();
    phoneNumber = json['phone_number']?.toString();
    pricePerPiece = json['price_per_piece']?.toString();
    quantity = json['quantity'] is int 
        ? json['quantity'] as int 
        : int.tryParse(json['quantity']?.toString() ?? '');
    productName = json['product_name']?.toString();
    isConfirm = json['is_confirm'] is bool 
        ? json['is_confirm'] as bool 
        : (json['is_confirm']?.toString() == 'true');
    buyerConfirmedDelivery = json['buyer_confirmed_delivery'] is bool 
        ? json['buyer_confirmed_delivery'] as bool 
        : (json['buyer_confirmed_delivery']?.toString() == 'true');
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    buyer = json['buyer']?.toString();
    vendor = json['vendor']?.toString();
    tag = json['tag']?.toString();
    shortNote = json['short_note']?.toString();
    deliveryCharge = json['delivery_charge']?.toString();
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
    return data;
  }
}
