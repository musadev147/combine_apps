import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
// // ignore_for_file: use_build_context_synchronously

// import 'dart:developer';
// import 'package:flutter/cupertino.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:bd_shope_combined/constants/text_font_style.dart';
// import 'package:bd_shope_combined/gen/colors.gen.dart';

// class ImageSourceDialog extends StatelessWidget {
//   final ValueChanged<String> onImageSelected;

//   const ImageSourceDialog({super.key, required this.onImageSelected});

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoActionSheet(
//       title: Text(
//         'Choose Your Image',
//         style: TextFontStyle.headline20StyleCabin600
//             .copyWith(color: AppColors.c000000), // Your custom text style
//       ),
//       actions: [
//         CupertinoActionSheetAction(
//           child: Text('Camera'),
//           onPressed: () async {
//             XFile? image =
//                 await ImagePicker().pickImage(source: ImageSource.camera);
//             if (image != null) {
//               onImageSelected(image.path);
//               log('Image path: ${image.path}');
//             } else {
//               log('No image selected.');
//             }
//             Navigator.of(context).pop();
//           },
//         ),
//         CupertinoActionSheetAction(
//           child: Text('Gallery'),
//           onPressed: () async {
//             XFile? image =
//                 await ImagePicker().pickImage(source: ImageSource.gallery);
//             if (image != null) {
//               onImageSelected(image.path);
//               log('Image path: ${image.path}');
//             } else {
//               log('No image selected.');
//             }
//             Navigator.of(context).pop();
//           },
//         ),
//       ],
//       cancelButton: CupertinoActionSheetAction(
//         isDestructiveAction: true,
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//         child: Text('Cancel'),
//       ),
//     );
//   }
// }
