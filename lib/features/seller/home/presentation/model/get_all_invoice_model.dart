class GetAllInvoiceModel {
  String? id;
  String? session;
  String? channelName;
  String? buyer;
  String? vendor;
  String? tag;
  String? productName;
  String? price;
  int? quantity;
  String? deliveryCharge;
  String? note;
  bool? isProcessed;
  String? createdAt;
  String? updatedAt;

  GetAllInvoiceModel(
      {this.id,
      this.session,
      this.channelName,
      this.buyer,
      this.vendor,
      this.tag,
      this.productName,
      this.price,
      this.quantity,
      this.deliveryCharge,
      this.note,
      this.isProcessed,
      this.createdAt,
      this.updatedAt});

  GetAllInvoiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    session = json['session'];
    channelName = json['channel_name'];
    buyer = json['buyer'];
    vendor = json['vendor'];
    tag = json['tag'];
    productName = json['product_name'];
    price = json['price'];
    quantity = json['quantity'];
    deliveryCharge = json['delivery_charge'];
    note = json['note'];
    isProcessed = json['is_processed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['session'] = this.session;
    data['channel_name'] = this.channelName;
    data['buyer'] = this.buyer;
    data['vendor'] = this.vendor;
    data['tag'] = this.tag;
    data['product_name'] = this.productName;
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    data['delivery_charge'] = this.deliveryCharge;
    data['note'] = this.note;
    data['is_processed'] = this.isProcessed;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
