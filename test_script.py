import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Replace color: Colors.white
    # But only if it's not already dynamic
    new_content = re.sub(r'color:\s*Colors\.white([^a-zA-Z0-9_])', r'color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black\1', content)
    
    # Very crude const removal for Text and Icon
    new_content = re.sub(r'const\s+(Text|Icon|TextStyle|GoogleFonts)', r'\1', new_content)

    if new_content != content:
        # Add imports if needed
        if 'package:get/get.dart' not in new_content:
            new_content = "import 'package:get/get.dart';\n" + new_content
        if 'theme_controller.dart' not in new_content:
            new_content = "import 'package:bd_shope_combined/controllers/theme_controller.dart';\n" + new_content
            
        with open(filepath, 'w') as f:
            f.write(new_content)

for root, _, files in os.walk('/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/buyer/coustomer'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
print("Done")
