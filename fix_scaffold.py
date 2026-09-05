import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    new_content = re.sub(r'return\s+const\s+GlassBackgroundScaffold', r'return GlassBackgroundScaffold', content)

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)

for root, _, files in os.walk('/Users/laptopheaven/StudioProjects/bd_shope_combined/lib/features/seller/buyer/'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
print("Done")
