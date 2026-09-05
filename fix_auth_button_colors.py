import os
import re

directories = [
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/buyer/auth',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/seller/auth',
]

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content

    # Replace the specific textColor with Colors.white inside gradient buttons.
    # It looks like the pattern is mostly within ElevatedButton child Text widgets, after a LinearGradient.
    # We can just replace the specific text color string when it's inside ElevatedButton.
    # But a simpler regex: 
    # color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,
    # wait, this pattern is used in many places, some are NOT in gradient buttons.
    
    # We can just look for "Login Now", "Reset Password", "Sign Up", "Verify OTP", "Update Password", etc.
    # Since they are the primary buttons, their text is white.
    
    if "LinearGradient" in content and "ElevatedButton" in content:
        # We replace the text color of the button
        # This is a bit tricky with regex, let's just do a specific replacement.
        content = content.replace(
            "color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black,\n                            fontSize: 14.sp,\n                            fontWeight: FontWeight.bold,",
            "color: Colors.white,\n                            fontSize: 14.sp,\n                            fontWeight: FontWeight.bold,"
        )

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed button colors in {filepath}")

for d in directories:
    for root, _, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))
