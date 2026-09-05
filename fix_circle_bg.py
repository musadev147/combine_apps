import os

directories = [
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/buyer/auth',
]

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content

    content = content.replace(
        "color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black.withOpacity(0.06),",
        "color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white.withOpacity(0.06),"
    )

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Fixed circle background in {filepath}")

for d in directories:
    for root, _, files in os.walk(d):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file))
