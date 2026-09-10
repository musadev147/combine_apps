import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'common_components.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/create_invoice_screen.dart';

class PromiseNotesTab extends StatefulWidget {
  final bool isPromise;
  final int? refreshTrigger;

  const PromiseNotesTab({
    super.key,
    required this.isPromise,
    this.refreshTrigger = 0,
  });

  @override
  State<PromiseNotesTab> createState() => _PromiseNotesTabState();
}

class _PromiseNotesTabState extends State<PromiseNotesTab> {
  bool _isLoading = true;
  List<dynamic> _notesList = [];
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  @override
  void didUpdateWidget(covariant PromiseNotesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _fetchNotes();
    }
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final endpoint = widget.isPromise ? "/invoice/promised-notes/" : "/invoice/unpromised-notes/";
      final response = await DioSingleton.instance.dio.get(endpoint);

      if (response.statusCode == 200) {
        setState(() {
          _notesList = response.data['results'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load data. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error connecting to server.";
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'Just now';
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = months[dateTime.month - 1];
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$day $month, $hour:$minute $period';
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    final tabName = widget.isPromise ? "Promised Notes" : "Unpromised Notes";
    
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSectionHeader(tabName),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: tc.textSecondaryColor),
                onPressed: _fetchNotes,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const CircularProgressIndicator(color: Color(0xFF53A4CA)),
              ),
            )
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(_errorMessage, style: TextStyle(color: Colors.redAccent)),
              ),
            )
          else if (_notesList.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text("No $tabName found.", style: TextStyle(color: tc.textSecondaryColor)),
              ),
            )
          else
            _buildNotesList(tc, _notesList),
        ],
      );
    });
  }

  Widget _buildNotesList(ThemeController tc, List<dynamic> list) {
    return Column(
      children: list.map((item) {
        final buyerName = item['buyer'] != null ? item['buyer']['name'] : 'Unknown Buyer';
        final tagname = item['tag'] != null ? item['tag']['tagname'] : 'No Tag';
        final productName = item['product_name'] ?? 'N/A';
        final formattedDate = _formatDate(item['created_at']);
        final isProcessed = item['is_processed'] == true;
        final statusColor = isProcessed ? const Color(0xFF10B981) : const Color(0xFFF39C12);
        
        return GlassCard(
          borderRadius: 12.r,
          backgroundColor: tc.inputBackground,
          margin: EdgeInsets.symmetric(vertical: 4.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: widget.isPromise ? Colors.blueAccent.withOpacity(0.1) : Colors.orangeAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.isPromise ? Icons.handshake_rounded : Icons.broken_image_rounded, 
                      color: widget.isPromise ? Colors.blueAccent : Colors.orangeAccent, size: 18.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$buyerName",
                        style: TextStyle(
                          color: tc.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF53A4CA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              "#$tagname",
                              style: TextStyle(
                                color: const Color(0xFF53A4CA),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              isProcessed ? "Processed" : "Pending",
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (item['note'] != null && item['note'].toString().isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          item['note'].toString(),
                          style: TextStyle(
                            color: tc.textSecondaryColor,
                            fontSize: 10.sp,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: tc.textSecondaryColor.withOpacity(0.5),
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7953CA),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateInvoiceScreen(
                                initialLog: {
                                  "id": item['id'] ?? "",
                                  "buyer": buyerName,
                                  "buyerId": item['buyer'] != null ? item['buyer']['id'] : null,
                                  "item": productName,
                                "qty": item['quantity'] ?? 1,
                                "price": double.tryParse(item['price']?.toString() ?? "") ?? 0.0,
                                "delivery": double.tryParse(item['delivery_charge']?.toString() ?? "") ?? 0.0,
                                "service_charge": double.tryParse(item['service_charge']?.toString() ?? "") ?? 0.0,
                                "packing_charge": double.tryParse(item['packing_charge']?.toString() ?? "") ?? 0.0,
                                "is_unpromised": item['is_unpromised'] ?? false,
                                "note": item['note'] ?? "",
                                "isShortNote": true,
                                "buyer_confirmed_delivery": false,
                              },
                              onCreateInvoice: (newInvoice) {
                                _fetchNotes();
                              },
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Create Invoice",
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
