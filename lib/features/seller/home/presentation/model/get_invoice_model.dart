class GetInvoiceDetailsModel {
  int? count;
  String? next;
  String? previous;
  List<GetInvoiceModel>? results;

  GetInvoiceDetailsModel({this.count, this.next, this.previous, this.results});

  GetInvoiceDetailsModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    next = json['next'];
    previous = json['previous'];
    if (json['results'] != null) {
      results = <GetInvoiceModel>[];
      json['results'].forEach((v) {
        results!.add(new GetInvoiceModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    if (this.results != null) {
      data['results'] = this.results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetInvoiceModel {
  String? id;
  String? totalPrice;
  String? address;
  String? phoneNumber;
  String? pricePerPiece;
  int? quantity;
  String? productName;
  String? invoiceNumber;
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

  GetInvoiceModel(
      {this.id,
        this.totalPrice,
        this.address,
        this.phoneNumber,
        this.pricePerPiece,
        this.quantity,
        this.productName,
        this.invoiceNumber,
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

  GetInvoiceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalPrice = json['total_price'];
    address = json['address'];
    phoneNumber = json['phone_number'];
    pricePerPiece = json['price_per_piece'];
    quantity = json['quantity'];
    productName = json['product_name'];
    invoiceNumber = json['invoice_number'];
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
    data['invoice_number'] = this.invoiceNumber;
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
