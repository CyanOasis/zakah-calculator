import re

with open('lib/ui/wizard/zakat_wizard.dart', 'r') as f:
    content = f.read()

# Fix the escaped quotes
content = content.replace(r"default: return \'\';", "default: return '';")

# Remove the duplicated corrupted block
idx = content.find("}\ns.of(context)!.silver_weight;")
if idx != -1:
    # Find the end of the enum _WealthEntryType right before this
    enum_idx = content.rfind("enum _WealthEntryType {", 0, idx)
    if enum_idx != -1:
        # find the end of the enum
        end_enum_idx = content.find("}", enum_idx) + 1
        # truncate after end_enum_idx
        content = content[:end_enum_idx] + "\n"

with open('lib/ui/wizard/zakat_wizard.dart', 'w') as f:
    f.write(content)
