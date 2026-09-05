import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/common_widgets/glass_card.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/data/short_note_api.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/model/get_all_invoice_model.dart';
import 'common_components.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/create_invoice_screen.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class ShortNotesTab extends StatefulWidget {
  final int? refreshTrigger;

  const ShortNotesTab({
    super.key,
    this.refreshTrigger = 0,
  });

  @override
  State<ShortNotesTab> createState() => _ShortNotesTabState();
}

class _ShortNotesTabState extends State<ShortNotesTab> {
  late Future<List<GetAllInvoiceModel>> _futureNotes;

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  @override
  void didUpdateWidget(covariant ShortNotesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _refreshNotes();
    }
  }

  void _refreshNotes() {
    setState(() {
      _futureNotes = ShortNoteApi.instance.fetchShortNotes();
    });
  }

  void _deleteNote(String id) async {
    final success = await ShortNoteApi.instance.deleteShortNote(id);
    if (success) {
      Get.snackbar(
        "Deleted",
        "Short note deleted successfully",
        colorText: Colors.white,
        backgroundColor: Colors.greenAccent.withOpacity(0.8),
      );
      _refreshNotes();
    } else {
      Get.snackbar(
        "Error",
        "Failed to delete short note",
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(0.8),
      );
    }
  }

  void _confirmDeleteDialog(String id) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Note?", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete this short note? This action cannot be undone.", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteNote(id);
            },
            child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();
    return Obx(() {
      final isDark = tc.isDarkMode.value;
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildSectionHeader("Short Note Invoices"),
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: tc.textSecondaryColor),
              onPressed: _refreshNotes,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        FutureBuilder<List<GetAllInvoiceModel>>(
          future: _futureNotes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const CircularProgressIndicator(color: Color(0xFF53A4CA)),
                ),
              );
            } else if (snapshot.hasError) {
              // Mock fallback data in case server is not running
              final mockData = [
                GetAllInvoiceModel(
                  id: "INV-0012",
                  buyer: "Tasin Rahman",
                  productName: "Logitech G Pro Mouse",
                  price: "8500",
                  quantity: 1,
                  note: "Please deliver it after 6 PM.",
                  isProcessed: false,
                  createdAt: "10 mins ago",
                ),
                GetAllInvoiceModel(
                  id: "INV-0011",
                  buyer: "Sumaiya Jahan",
                  productName: "Mechanical Keyboard Keycaps",
                  price: "1800",
                  quantity: 2,
                  note: "Gift wrapping requested.",
                  isProcessed: true,
                  createdAt: "Yesterday",
                ),
              ];
              return _buildNotesList(tc, mockData, isFallback: true);
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: Text(
                    "No short note invoices found.",
                    style: TextStyle(color: tc.textSecondaryColor),
                  ),
                ),
              );
            }

            return _buildNotesList(tc, snapshot.data!);
          },
        ),
      ],
    );
    });
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
      if (isoString.contains('T')) {
        final parts = isoString.split('T');
        final date = parts[0];
        final time = parts[1].split('.')[0];
        return '$date $time';
      }
      return isoString;
    }
  }

  Widget _buildNotesList(ThemeController tc, List<GetAllInvoiceModel> list, {bool isFallback = false}) {
    return Column(
      children: [
        if (isFallback)
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orangeAccent, size: 16.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    "Demo Mode: Displaying mock short notes (API offline)",
                    style: TextStyle(color: Colors.orangeAccent, fontSize: 10.sp),
                  ),
                ),
              ],
            ),
          ),
        ...list.map((note) {
          final isProcessed = note.isProcessed ?? false;
          final statusColor = isProcessed ? const Color(0xFF10B981) : const Color(0xFFF39C12);
          final formattedDate = _formatDate(note.createdAt);

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
                      color: const Color(0xFF53A4CA).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sticky_note_2_outlined, color: const Color(0xFF53A4CA), size: 18.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.productName ?? 'N/A',
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
                            Text(
                              "৳${note.price ?? '0'} • Qty: ${note.quantity ?? 1}",
                              style: TextStyle(
                                color: const Color(0xFF53A4CA),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
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
                        if (note.note != null && note.note!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            note.note!,
                            style: TextStyle(
                              color: tc.textSecondaryColor,
                              fontSize: 10.sp,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
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
                                  "id": note.id ?? "",
                                  "buyer": note.buyer ?? "",
                                  "item": note.productName ?? "",
                                  "qty": note.quantity ?? 1,
                                  "price": double.tryParse(note.price ?? "") ?? 0.0,
                                  "delivery": double.tryParse(note.deliveryCharge ?? "") ?? 0.0,
                                  "note": note.note ?? "",
                                  "isShortNote": true,
                                  "buyer_confirmed_delivery": false,
                                },
                                onCreateInvoice: (newInvoice) {
                                  _refreshNotes();
                                },
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Create Invoice",
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      GestureDetector(
                        onTap: () {
                          if (note.id != null) {
                            _confirmDeleteDialog(note.id!);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 14.sp),
                            SizedBox(width: 4.w),
                            Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
