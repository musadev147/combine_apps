import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'data/invoice_api.dart';
import 'model/post_invoice_model.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final Map<String, dynamic>? initialLog; // Optional call log to autofill buyer info
  final Function(Map<String, dynamic> newInvoice) onCreateInvoice;

  const CreateInvoiceScreen({
    super.key,
    this.initialLog,
    required this.onCreateInvoice,
  });

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _buyerNameCtrl;
  late TextEditingController _buyerIdCtrl;
  late TextEditingController _itemNameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _qtyCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _deliveryChargeCtrl;

  double _subtotal = 0.0;
  double _total = 0.0;
  String? _realBuyerUuid;
  final List<Map<String, dynamic>> _uiUsersList = [];
  Map<String, dynamic>? _selectedUser;

  @override
  void initState() {
    super.initState();
    _buyerNameCtrl = TextEditingController(text: widget.initialLog?["buyer"] ?? "");
    _buyerIdCtrl = TextEditingController(text: widget.initialLog?["buyerId"] ?? "");
    _itemNameCtrl = TextEditingController(text: widget.initialLog?["item"] ?? "");
    _priceCtrl = TextEditingController(text: widget.initialLog?["price"]?.toString() ?? "");
    _qtyCtrl = TextEditingController(text: widget.initialLog?["qty"]?.toString() ?? "1");
    _addressCtrl = TextEditingController(text: widget.initialLog?["note"] ?? "");
    _deliveryChargeCtrl = TextEditingController(text: widget.initialLog?["delivery"]?.toString() ?? "0.0");

    _priceCtrl.addListener(_calculateTotals);
    _qtyCtrl.addListener(_calculateTotals);
    _deliveryChargeCtrl.addListener(_calculateTotals);
    
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final qty = double.tryParse(_qtyCtrl.text) ?? 0.0;
    final delivery = double.tryParse(_deliveryChargeCtrl.text) ?? 0.0;
    _subtotal = price * qty;
    _total = _subtotal + delivery;

    _fetchUsersList();
  }

  void _fetchUsersList() async {
    try {
      final response = await getHttp(Endpoints.allUser());
      log("ALL USERS RESPONSE: ${response.data}");
      _parseUsers(response.data);
    } catch (e) {
      log("Error fetching chatting users: $e");
    }
  }

  bool _isUserMatch(Map user, String targetName, String targetId) {
    final cleanTargetName = targetName.trim().toLowerCase();
    final cleanTargetId = targetId.trim().toLowerCase();

    // Check ID fields
    final userId = user['id']?.toString().toLowerCase() ?? '';
    final userUuid = user['uuid']?.toString().toLowerCase() ?? '';
    final userBuyerId = user['buyerId']?.toString().toLowerCase() ?? '';
    final userNumId = user['numeric_id']?.toString().toLowerCase() ?? '';

    if (cleanTargetId.isNotEmpty) {
      if (userId == cleanTargetId || 
          userUuid == cleanTargetId || 
          userBuyerId == cleanTargetId || 
          userNumId == cleanTargetId) {
        return true;
      }
      final targetDigits = RegExp(r'\d+').firstMatch(cleanTargetId)?.group(0) ?? '';
      if (targetDigits.isNotEmpty) {
        if (userId == targetDigits || userNumId == targetDigits || userBuyerId.contains(targetDigits)) {
          return true;
        }
      }
    }

    // Check Name fields
    final name = user['name']?.toString().toLowerCase() ?? '';
    final firstName = user['first_name']?.toString().toLowerCase() ?? '';
    final lastName = user['last_name']?.toString().toLowerCase() ?? '';
    final fullName = "$firstName $lastName".trim().toLowerCase();
    final username = user['user_name']?.toString().toLowerCase() ?? 
                     user['username']?.toString().toLowerCase() ?? '';
    final email = user['email']?.toString().toLowerCase() ?? '';

    if (cleanTargetName.isNotEmpty) {
      if (name == cleanTargetName || 
          fullName == cleanTargetName || 
          username == cleanTargetName || 
          email.contains(cleanTargetName)) {
        return true;
      }
      if (name.contains(cleanTargetName) || cleanTargetName.contains(name) && name.length > 2) {
        return true;
      }
      if (fullName.contains(cleanTargetName) || cleanTargetName.contains(fullName) && fullName.length > 2) {
        return true;
      }
    }

    return false;
  }

  void _parseUsers(dynamic rawData) {
    if (rawData == null) return;
    List<dynamic> usersList = [];
    if (rawData is List) {
      usersList = rawData;
    } else if (rawData is Map) {
      if (rawData['data'] is List) {
        usersList = rawData['data'];
      } else if (rawData['users'] is List) {
        usersList = rawData['users'];
      } else if (rawData['results'] is List) {
        usersList = rawData['results'];
      }
    }

    final targetName = widget.initialLog?["buyer"]?.toString() ?? '';
    final targetId = widget.initialLog?["buyerId"]?.toString() ?? '';

    setState(() {
      for (var user in usersList) {
        if (user is Map) {
          final mappedUser = Map<String, dynamic>.from(user);
          final id = mappedUser['id']?.toString() ?? '';
          if (id.isNotEmpty && !_uiUsersList.any((u) => (u['id']?.toString() ?? '') == id)) {
            _uiUsersList.add(mappedUser);
          }
        }
      }

      // Try to find matching user for initialLog
      for (var user in _uiUsersList) {
        if (_isUserMatch(user, targetName, targetId)) {
          _selectedUser = user;
          _realBuyerUuid = user['id']?.toString() ?? user['uuid']?.toString();
          log("FOUND AND SELECTED MATCHING BUYER: ${user['name'] ?? user['username']} (ID: $_realBuyerUuid)");
          return;
        }
      }

      // If no precise match, but we have an initial buyer name, try soft matching
      if (_selectedUser == null && targetName.isNotEmpty) {
        for (var user in _uiUsersList) {
          final name = (user['name'] ?? user['username'] ?? '').toString().toLowerCase();
          if (name.contains(targetName.toLowerCase()) || targetName.toLowerCase().contains(name)) {
            _selectedUser = user;
            _realBuyerUuid = user['id']?.toString() ?? user['uuid']?.toString();
            log("SOFT MATCHED BUYER: ${user['name'] ?? user['username']} (ID: $_realBuyerUuid)");
            return;
          }
        }
      }

      // If no matching user, and we have items, set the first user as selected by default
      if (_selectedUser == null && _uiUsersList.isNotEmpty) {
        _selectedUser = _uiUsersList.first;
        _realBuyerUuid = _selectedUser!['id']?.toString() ?? _selectedUser!['uuid']?.toString();
        log("DEFAULT SELECTED FIRST BUYER: ${_selectedUser!['name'] ?? _selectedUser!['username']} (ID: $_realBuyerUuid)");
      }
    });
  }

  @override
  void dispose() {
    _buyerNameCtrl.dispose();
    _buyerIdCtrl.dispose();
    _itemNameCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _addressCtrl.dispose();
    _deliveryChargeCtrl.dispose();
    super.dispose();
  }

  void _calculateTotals() {
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final qty = double.tryParse(_qtyCtrl.text) ?? 0.0;
    final delivery = double.tryParse(_deliveryChargeCtrl.text) ?? 0.0;

    setState(() {
      _subtotal = price * qty;
      _total = _subtotal + delivery;
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final tc = Get.find<ThemeController>();
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: tc.textColor),
        validator: validator,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: tc.textSecondaryColor),
          prefixIcon: Icon(icon, color: const Color(0xFF53A4CA), size: 20.sp),
          filled: true,
          fillColor: tc.inputBackground,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: tc.inputBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF53A4CA), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isShortNote = widget.initialLog?["isShortNote"] == true;
    final tc = Get.find<ThemeController>();

    return GlassBackgroundScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Create New Invoice",
          style: TextStyle(color: tc.textColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: !isShortNote,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section: Buyer Information
                    Text(
                      "Buyer / Tenant Selection",
                      style: TextStyle(color: tc.textColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    GlassCard(
                      borderRadius: 16.r,
                      backgroundColor: tc.inputBackground,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<Map<String, dynamic>>(
                              value: _selectedUser,
                              dropdownColor: tc.cardBackground,
                              style: TextStyle(color: tc.textColor),
                              iconEnabledColor: const Color(0xFF53A4CA),
                              decoration: InputDecoration(
                                labelText: "Select Buyer",
                                labelStyle: TextStyle(color: tc.textSecondaryColor),
                                prefixIcon: Icon(Icons.person_outline, color: const Color(0xFF53A4CA), size: 20.sp),
                                filled: true,
                                fillColor: tc.inputBackground,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: tc.inputBorderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: const BorderSide(color: Color(0xFF53A4CA), width: 1.5),
                                ),
                              ),
                              items: _uiUsersList.map((user) {
                                final name = user['name'] ?? user['username'] ?? user['first_name'] ?? 'Unknown User';
                                final role = user['role'] ?? user['user_role'] ?? 'Buyer';
                                final email = user['email'] != null ? " (${user['email']})" : "";
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: user,
                                  child: Text(
                                    "$name - $role$email",
                                    style: TextStyle(color: tc.textColor, fontSize: 13.sp),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedUser = val;
                                  if (val != null) {
                                    _realBuyerUuid = val['id']?.toString() ?? val['uuid']?.toString();
                                    _buyerIdCtrl.text = _realBuyerUuid ?? '';
                                    if (val['name'] != null) {
                                      _buyerNameCtrl.text = val['name'];
                                    }
                                  }
                                });
                              },
                              validator: (value) => (isShortNote || value != null) ? null : "Please select a buyer",
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),

              // Section: Product Details
              Text(
                "Product Details",
                style: TextStyle(color: tc.textColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              GlassCard(
                borderRadius: 16.r,
                backgroundColor: tc.inputBackground,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _itemNameCtrl,
                        labelText: "Product / Item Name",
                        icon: Icons.shopping_bag_outlined,
                        validator: (value) => value == null || value.trim().isEmpty ? "Please enter product name" : null,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _priceCtrl,
                              labelText: "Unit Price (৳)",
                              icon: Icons.payments_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Enter price";
                                if (double.tryParse(value) == null) return "Invalid price";
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _qtyCtrl,
                              labelText: "Quantity",
                              icon: Icons.unfold_more_rounded,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) return "Enter quantity";
                                if (int.tryParse(value) == null) return "Invalid quantity";
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Section: Delivery & Fees
              Text(
                "Shipping & Notes",
                style: TextStyle(color: tc.textColor, fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              GlassCard(
                borderRadius: 16.r,
                backgroundColor: tc.inputBackground,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _addressCtrl,
                        labelText: "Shipping Address / Notes",
                        icon: Icons.description_outlined,
                      ),
                      _buildTextField(
                        controller: _deliveryChargeCtrl,
                        labelText: "Delivery Charge (৳)",
                        icon: Icons.local_shipping_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                            return "Invalid delivery charge";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Section: Bill Summary
              GlassCard(
                borderRadius: 16.r,
                backgroundColor: const Color(0xFF53A4CA).withOpacity(0.08),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subtotal", style: TextStyle(color: tc.textSecondaryColor)),
                          Text("৳ ${_subtotal.toStringAsFixed(2)}", style: TextStyle(color: tc.textColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Delivery Charge", style: TextStyle(color: tc.textSecondaryColor)),
                          Text("৳ ${(double.tryParse(_deliveryChargeCtrl.text) ?? 0.0).toStringAsFixed(2)}", style: TextStyle(color: tc.textColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Divider(color: tc.dividerColor),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Bill", style: TextStyle(color: tc.textColor, fontSize: 15.sp, fontWeight: FontWeight.bold)),
                          Text(
                            "৳ ${_total.toStringAsFixed(2)}",
                            style: TextStyle(color: const Color(0xFF53A4CA), fontSize: 18.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF53A4CA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: Icon(Icons.send_rounded, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                  label: Text(
                    "Create & Send Invoice",
                    style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        await EasyLoading.show(status: "Creating Invoice...");

                         String buyer = _buyerIdCtrl.text.trim();
                         if (isShortNote) {
                           buyer = widget.initialLog?["buyer"]?.toString() ?? '';
                         } else if (!RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(buyer)) {
                           buyer = _realBuyerUuid ?? "3fa85f64-5717-4562-b3fc-2c963f66afa6";
                         }
                         final productName = _itemNameCtrl.text.trim();
                         final price = _priceCtrl.text.trim();
                         final quantity = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
                         final note = _addressCtrl.text.trim();
                         final delivery = _deliveryChargeCtrl.text.trim();

                         final buyerPhone = _selectedUser?['phone'] ?? _selectedUser?['phone_number'] ?? '';
                         final double totalPriceVal = (double.tryParse(price) ?? 0.0) * quantity + (double.tryParse(delivery) ?? 0.0);

                         final invoiceModel = PostInvoiceModel(
                           buyer: buyer,
                           pricePerPiece: price,
                           quantity: quantity,
                           totalPrice: totalPriceVal.toString(),
                           address: note,
                           phoneNumber: buyerPhone.isNotEmpty ? buyerPhone : "01700000000",
                           productName: productName,
                           isConfirm: true,
                           buyerConfirmedDelivery: true,
                           status: "pending",
                           tag: null,
                           shortNote: isShortNote ? (widget.initialLog?["id"]?.toString()) : null,
                           deliveryCharge: delivery,
                         );

                        final success = await InvoiceApi.instance.createInvoice(invoiceModel);

                        await EasyLoading.dismiss();

                        if (success) {
                          final newInv = {
                            "id": "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                            "buyer": buyer,
                            "item": productName,
                            "qty": quantity,
                            "status": "Pending",
                            "date": "Just now",
                            "price": double.tryParse(price) ?? 0.0,
                            "delivery": double.tryParse(delivery) ?? 0.0
                          };
                          widget.onCreateInvoice(newInv);
                          Navigator.pop(context);
                          Get.snackbar(
                            "Success",
                            "Invoice created and sent successfully!",
                            colorText: Colors.white,
                            backgroundColor: Colors.greenAccent.withOpacity(0.8),
                          );
                        } else {
                          Get.snackbar(
                            "Error",
                            "Failed to create invoice on server.",
                            colorText: Colors.white,
                            backgroundColor: Colors.redAccent.withOpacity(0.8),
                          );
                        }
                      } catch (e) {
                        await EasyLoading.dismiss();
                        Get.snackbar(
                          "Error",
                          "An error occurred: $e",
                          colorText: Colors.white,
                          backgroundColor: Colors.redAccent.withOpacity(0.8),
                        );
                      }
                    }
                  },
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
