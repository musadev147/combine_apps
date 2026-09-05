import os
import re

directories = [
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/buyer',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/seller',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/common_wigdets',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/common_widgets'
]

# Replacement for text/icon opacities
text_secondary_replacement = r'Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textSecondaryColor : Colors.black54'
icon_color_replacement = r'Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().iconColor : Colors.black45'
divider_color_replacement = r'Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12'

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    new_content = content

    # Replace Colors.white70, Colors.white60, Colors.white54 with textSecondaryColor
    new_content = re.sub(r'Colors\.white(?:70|60|54)', text_secondary_replacement, new_content)
    
    # Replace Colors.white38 with iconColor (often used for hints/icons)
    new_content = re.sub(r'Colors\.white38', icon_color_replacement, new_content)
    
    # Replace Colors.white24, Colors.white12, Colors.white10 with dividerColor
    new_content = re.sub(r'Colors\.white(?:24|12|10)', divider_color_replacement, new_content)

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)

for directory in directories:
    if os.path.exists(directory):
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith('.dart'):
                    process_file(os.path.join(root, file))

print("Done fixing white opacities")
