import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg.dart';
import 'package:bd_shope_combined/constants/app_colors.dart';

class CustomDropdownNew<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemToString;
  final void Function(T?) onChanged;
  final String? hint;
  final String? iconPath;
  final double? height;
  final bool? circularColor;

  const CustomDropdownNew({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.itemToString,
    required this.onChanged,
    this.hint,
    this.iconPath,
    this.height,
    this.circularColor,
  });

  @override
  State<CustomDropdownNew<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdownNew<T>> {
  T? selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = widget.selectedItem;
  }

  @override
  void didUpdateWidget(covariant CustomDropdownNew<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItem != oldWidget.selectedItem) {
      setState(() {
        selectedItem = widget.selectedItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 50,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xffC0C0C0)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          if (widget.iconPath != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 12),
              child: SvgPicture.asset(widget.iconPath!, width: 24, height: 24),
            ),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: SizedBox.expand(
                child: DropdownButton<T>(
                  borderRadius: BorderRadius.circular(16),
                  hint: Text(
                    widget.hint ?? '',
                    style: TextStyle(color: Color(0xffA1A1A1), fontSize: 16),
                  ),
                  value: selectedItem,
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                    widget.onChanged(value);
                  },
                  items: widget.items.map((item) {
                    final title = widget.itemToString(item);
                    Color? circleColor;
                    if (widget.circularColor == true) {
                      final found = urgencyLevels.firstWhere(
                        (el) => el['title'].toString().toLowerCase() == title.toLowerCase(),
                        orElse: () => {},
                      );
                      circleColor = found['color'] as Color?;
                    }
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Row(
                        children: [
                          if (widget.circularColor == true) ...[
                            CircleAvatar(
                              radius: 6,
                              backgroundColor: circleColor ?? Colors.transparent,
                            ),
                            SizedBox(width: 15),
                          ],
                          Text(
                            title,
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> urgencyLevels = [
  {'id': 1, 'title': 'ESI Level 1', 'color': Color(0xFFFF0000)},
  {'id': 2, 'title': 'ESI Level 2', 'color': Color(0xFFFFA500)},
  {'id': 3, 'title': 'ESI Level 3', 'color': Color(0xFFFFFF00)},
  {'id': 4, 'title': 'ESI Level 4', 'color': Color(0xFF00FF00)},
  {'id': 5, 'title': 'ESI Level 5', 'color': Color(0xFF0000FF)},
];
