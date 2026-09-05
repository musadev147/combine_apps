import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

Widget buildGlassInputField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  bool readOnly = false,
}) {
  final tc = Get.find<ThemeController>();
  return Obx(() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: tc.textSecondaryColor, fontSize: 11.sp, fontWeight: FontWeight.bold)),
      SizedBox(height: 4.h),
      Container(
        decoration: BoxDecoration(
          color: tc.inputBackground,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: tc.inputBorderColor),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: TextStyle(color: readOnly ? tc.textSecondaryColor : tc.inputTextColor, fontSize: 13.sp),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: tc.iconColor, size: 18.sp),
            hintText: hint,
            hintStyle: TextStyle(color: tc.inputHintColor, fontSize: 13.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          ),
        ),
      ),
    ],
  ));
}

Widget buildSectionHeader(String title) {
  final tc = Get.find<ThemeController>();
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    child: Obx(() => Text(
      title,
      style: TextStyle(color: tc.textColor, fontSize: 14.sp, fontWeight: FontWeight.bold, letterSpacing: 0.3),
    )),
  );
}

Widget buildActionBtn(String text, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    height: 48.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      gradient: const LinearGradient(
        colors: [AppColors.c053A4CA, AppColors.c5369CA, AppColors.c7953CA],
      ),
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(
          color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold
      ),
      ),
    ),
  );
}
