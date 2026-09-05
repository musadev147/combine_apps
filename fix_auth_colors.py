import os
import re

directories = [
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/buyer/auth',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/seller/auth',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/buyer/onboarding',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/seller/onboarding',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/seller/home/presentation/widgets',
]

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content

    # Fix Damadami text color: from cardBackground/Colors.white to textColor
    content = re.sub(
        r"color: Get\.isRegistered<ThemeController>\(\) \? Get\.find<ThemeController>\(\)\.cardBackground : Colors\.white",
        r"color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black",
        content
    )

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed colors in {filepath}")

for d in directories:
    for root, _, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))
