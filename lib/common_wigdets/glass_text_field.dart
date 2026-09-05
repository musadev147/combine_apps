import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/controllers/theme_controller.dart';

class GlassTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final int maxLines;
  final bool isReadOnly;
  final VoidCallback? onTap;

  const GlassTextField({
    super.key,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.isReadOnly = false,
    this.onTap,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isPasswordVisible = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().isDarkMode.value : false;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white.withOpacity(0.4) : Colors.black45;
    final labelColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black54;
    final iconColor = isDark ? Colors.white.withOpacity(0.7) : Colors.black54;
    final bgColor = isDark 
        ? Colors.white.withOpacity(_isFocused ? 0.15 : 0.08) 
        : Colors.black.withOpacity(_isFocused ? 0.05 : 0.02);
    final borderColor = isDark 
        ? Colors.white.withOpacity(0.2) 
        : Colors.black.withOpacity(0.05);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _isFocused
                    ? AppColors.allPrimaryColor.withOpacity(0.8)
                    : borderColor,
                width: 1.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.allPrimaryColor.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword && !_isPasswordVisible,
              validator: widget.validator,
              inputFormatters: widget.inputFormatters,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onFieldSubmitted,
              maxLines: widget.isPassword ? 1 : widget.maxLines,
              readOnly: widget.isReadOnly,
              onTap: widget.onTap,
              style: TextStyle(
                color: textColor,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              cursorColor: AppColors.allPrimaryColor,
              decoration: InputDecoration(
                labelText: widget.labelText,
                labelStyle: TextStyle(
                  color: labelColor,
                  fontSize: 13.sp,
                ),
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: 13.sp,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? IconTheme(
                        data: IconThemeData(color: iconColor),
                        child: widget.prefixIcon!,
                      )
                    : null,
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: iconColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                    : widget.suffixIcon,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: widget.maxLines > 1 ? 16.h : 14.h,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
