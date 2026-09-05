import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Replace color: Colors.white
    new_content = re.sub(r'color:\s*Colors\.white([^a-zA-Z0-9_])', r'color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black\1', content)
    
    # Very crude const removal for Text and Icon
    new_content = re.sub(r'const\s+(Text|Icon|TextStyle|GoogleFonts|Row|Column|Container|Padding|SizedBox|Expanded|Flexible|Align|Center)', r'\1', new_content)

    if new_content != content:
        # Add imports if needed
        if 'package:get/get.dart' not in new_content:
            new_content = "import 'package:get/get.dart';\n" + new_content
        if 'theme_controller.dart' not in new_content:
            new_content = "import 'package:bd_shope_combined/controllers/theme_controller.dart';\n" + new_content
            
        with open(filepath, 'w') as f:
            f.write(new_content)

directories = [
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/buyer',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/seller',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/common_wigdets',
    '/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/common_widgets'
]

for directory in directories:
    if os.path.exists(directory):
        for root, _, files in os.walk(directory):
            if 'coustomer' in root: # already processed
                continue
            for file in files:
                if file.endswith('.dart'):
                    process_file(os.path.join(root, file))
print("Done")
