class GetAllInvoiceModel {
  String? id;
  String? session;
  String? channelName;
  String? buyer;
  String? buyerName;
  String? vendor;
  String? tag;
  String? productName;
  String? price;
  int? quantity;
  String? deliveryCharge;
  String? serviceCharge;
  String? packingCharge;
  String? note;
  String? phoneNumber;
  String? address;
  bool? isProcessed;
  bool? isUnpromised;
  String? createdAt;
  String? updatedAt;

  GetAllInvoiceModel(
      {this.id,
      this.session,
      this.channelName,
      this.buyer,
      this.buyerName,
      this.vendor,
      this.tag,
      this.productName,
      this.price,
      this.quantity,
      this.deliveryCharge,
      this.serviceCharge,
      this.packingCharge,
      this.note,
      this.phoneNumber,
      this.address,
      this.isProcessed,
      this.isUnpromised,
      this.createdAt,
      this.updatedAt});

  GetAllInvoiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    session = json['session'];
    channelName = json['channel_name'];
    phoneNumber = json['phone_number']?.toString();
    address = json['address']?.toString();
    if (json['buyer'] is Map) {
      buyer = json['buyer']['id']?.toString();
      buyerName = json['buyer']['name']?.toString() ?? json['buyer']['email']?.toString() ?? json['buyer']['username']?.toString();
      if (phoneNumber == null || phoneNumber!.isEmpty) {
        phoneNumber = json['buyer']['phone_number']?.toString();
      }
      if (address == null || address!.isEmpty) {
        address = json['buyer']['address']?.toString();
      }
    } else {
      buyer = json['buyer']?.toString();
    }
    vendor = json['vendor']?.toString();
    if (json['tag'] is Map) {
      tag = json['tag']['id']?.toString();
    } else {
      tag = json['tag']?.toString();
    }
    productName = json['product_name']?.toString();
    price = json['price']?.toString();
    quantity = json['quantity'];
    deliveryCharge = json['delivery_charge']?.toString();
    serviceCharge = json['service_charge']?.toString();
    packingCharge = json['packing_charge']?.toString();
    note = json['note']?.toString();
    isProcessed = json['is_processed'];
    isUnpromised = json['is_unpromised'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['session'] = this.session;
    data['channel_name'] = this.channelName;
    data['buyer'] = this.buyer;
    data['buyer_name'] = this.buyerName;
    data['vendor'] = this.vendor;
    data['tag'] = this.tag;
    data['product_name'] = this.productName;
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    data['delivery_charge'] = this.deliveryCharge;
    data['service_charge'] = this.serviceCharge;
    data['packing_charge'] = this.packingCharge;
    data['note'] = this.note;
    data['phone_number'] = this.phoneNumber;
    data['address'] = this.address;
    data['is_processed'] = this.isProcessed;
    data['is_unpromised'] = this.isUnpromised;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

