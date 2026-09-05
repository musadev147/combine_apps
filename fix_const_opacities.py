import os
import re
import subprocess

def fix_const_errors():
    process = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True, cwd='/Users/laptopheaven/StudioProjects/bd_shope_combined')
    output = process.stdout + process.stderr
    
    files_to_fix = {}
    
    for line in output.splitlines():
        if "Error: Not a constant expression" in line or "Error: Method invocation is not a constant expression" in line or "error •" in line:
            # Format: '  error • Not a constant expression • lib/features/...:240:46 • non_constant_identifier'
            # Or from build output: 'lib/features/...:240:46: Error: Not a constant expression'
            match1 = re.search(r'(lib/[^:]+\.dart):(\d+):', line)
            match2 = re.search(r'error • [^•]+ • (lib/[^:]+\.dart):(\d+):', line)
            
            match = match1 or match2
            if match:
                filepath = os.path.join('/Users/laptopheaven/StudioProjects/bd_shope_combined', match.group(1))
                line_num = int(match.group(2))
                if filepath not in files_to_fix:
                    files_to_fix[filepath] = set()
                files_to_fix[filepath].add(line_num)
                
    for filepath, lines in files_to_fix.items():
        if not os.path.exists(filepath): continue
        with open(filepath, 'r') as f:
            content = f.read().splitlines()
            
        modified = False
        for line_num in lines:
            idx = line_num - 1
            if idx < len(content):
                # Try to remove const on the same line
                original = content[idx]
                content[idx] = re.sub(r'\bconst\s+', '', content[idx])
                if content[idx] != original:
                    modified = True
                else:
                    # Look backwards a few lines for 'const'
                    for i in range(idx, max(-1, idx-5), -1):
                        original_i = content[i]
                        content[i] = re.sub(r'\bconst\s+', '', content[i])
                        if content[i] != original_i:
                            modified = True
                            break
                            
        if modified:
            with open(filepath, 'w') as f:
                f.write('\n'.join(content) + '\n')
            print(f"Fixed {filepath}")

if __name__ == '__main__':
    fix_const_errors()
