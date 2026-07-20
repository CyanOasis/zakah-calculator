import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # 1. Remove const before Text(AppLocalizations...
    content = re.sub(r'const\s+Text\(\s*AppLocalizations', r'Text(AppLocalizations', content)
    
    # 2. Remove const before DropdownMenuItem... if it has AppLocalizations inside.
    # Actually, let's just find `const [` that contains AppLocalizations inside the brackets.
    # For DropdownMenuItem: 
    # `items: const [DropdownMenuItem(value: AppLocalizations.of(context)!.unit_name, child: Text(AppLocalizations.of(context)!.unit_name, style: TextStyle(fontSize: 13)))],`
    content = re.sub(r'const\s+\[\s*DropdownMenuItem\(\s*value:\s*AppLocalizations', r'[DropdownMenuItem(value: AppLocalizations', content)
    
    # 3. Add default: return ''; to _titleFor
    content = re.sub(r'(case _WealthEntryType\.debt: return AppLocalizations\.of\(context\)!\.debt_entry;)', r'\1\n      default: return \'\';', content)
    
    # 4. Handle const SnackBar(content: Text(AppLocalizations...
    content = re.sub(r'const\s+SnackBar\(\s*content:\s*Text\(\s*AppLocalizations', r'SnackBar(content: Text(AppLocalizations', content)

    with open(filepath, 'w') as f:
        f.write(content)
        
for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
