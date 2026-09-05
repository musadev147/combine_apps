import os
import re

directories = [
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/buyer',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/seller',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/common_wigdets',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/common_widgets'
]

# The string we mistakenly inserted for all Colors.white replacements
wrong_str = r'color:\s*Get\.isRegistered<ThemeController>\(\)\s*\?\s*Get\.find<ThemeController>\(\)\.textColor\s*:\s*Colors\.black'
correct_bg_str = 'color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white'

wrong_bg_str = r'backgroundColor:\s*Get\.isRegistered<ThemeController>\(\)\s*\?\s*Get\.find<ThemeController>\(\)\.textColor\s*:\s*Colors\.black'
correct_bg_str2 = 'backgroundColor: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().cardBackground : Colors.white'

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Split by the wrong_str to see context
    parts = re.split(wrong_str, content)
    if len(parts) == 1:
        # Check for backgroundColor
        parts2 = re.split(wrong_bg_str, content)
        if len(parts2) > 1:
            new_content = parts2[0]
            for i in range(1, len(parts2)):
                # If it's a backgroundColor property, it's definitely a background!
                new_content += correct_bg_str2 + parts2[i]
            
            with open(filepath, 'w') as f:
                f.write(new_content)
        return

    new_content = parts[0]
    for i in range(1, len(parts)):
        # Look backwards from this match to see if it's a background or text
        # If the last word characters before this were something like `style: TextStyle(` or `Text(` or `Icon(`, it should stay textColor.
        # Otherwise, if it was `BoxDecoration(` or `Container(` or `Card(` or `Color(` or `BorderSide(`, it's a background or border.
        
        prev_text = parts[i-1]
        
        # very simple heuristic:
        # get the last 50 characters before the replacement
        context = prev_text[-100:]
        
        if 'TextStyle' in context or 'GoogleFonts' in context or 'Icon' in context or 'TextSpan' in context:
            # It's text or icon, keep it as textColor
            new_content += 'color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black' + parts[i]
        elif 'Border' in context or 'Divider' in context or 'border' in context:
            # If it's a border, we can use a border color
            new_content += 'color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().dividerColor : Colors.black12' + parts[i]
        else:
            # It's likely a background (BoxDecoration, Container, Card, etc)
            new_content += correct_bg_str + parts[i]

    # Also check backgroundColor
    parts2 = re.split(wrong_bg_str, new_content)
    if len(parts2) > 1:
        final_content = parts2[0]
        for i in range(1, len(parts2)):
            final_content += correct_bg_str2 + parts2[i]
        new_content = final_content

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)

for directory in directories:
    if os.path.exists(directory):
        for root, _, files in os.walk(directory):
            for file in files:
                if file.endswith('.dart'):
                    process_file(os.path.join(root, file))

print("Done")
