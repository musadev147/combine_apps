import os

files_to_fix = [
    'lib/features/seller/home/presentation/payout_methods_screen.dart',
    'lib/features/seller/home/presentation/home_screen.dart',
    'lib/features/seller/home/presentation/widgets/short_notes_tab.dart',
    'lib/features/seller/home/presentation/widgets/dashboard_tab.dart',
    'lib/features/buyer/coustomer/home_screen/buyer_home_screen.dart',
]

target = 'backgroundColor: const Color(0xFF1E1B4B),'
replacement = 'backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white,'

for file_path in files_to_fix:
    with open(file_path, 'r') as f:
        content = f.read()
    
    if target in content:
        content = content.replace(target, replacement)
        with open(file_path, 'w') as f:
            f.write(content)
        print(f"Fixed {file_path}")

