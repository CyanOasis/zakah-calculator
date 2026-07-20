import re

with open('lib/ui/wizard/zakat_wizard.dart', 'r') as f:
    content = f.read()

# 1. Remove _manualOtherAssets declaration
content = re.sub(r'\s*double _manualOtherAssets = 0\.0;\n', '\n', content)

# 2. Remove _buildAddOtherButton call
content = re.sub(r'\s*const SizedBox\(height: 12\);\s*_buildAddOtherButton\(provider\);\n', '\n', content)

# 3. Remove _manualOtherAssets from _resetAll
content = re.sub(r'\s*_manualOtherAssets = 0\.0;\n', '\n', content)

# 4. Remove _manualOtherAssets from _syncProvider
content = re.sub(r'\s*provider\.otherAssets = _manualOtherAssets;\n', '\n    provider.otherAssets = 0.0;\n', content)

# 5. Remove _buildAddOtherButton method (regex for the whole method)
build_add_method_pattern = r'  Widget _buildAddOtherButton\(ZakatProvider provider\)\s*\{.*?\n  \}\n'
content = re.sub(build_add_method_pattern, '\n', content, flags=re.DOTALL)

# 6. Remove _editOtherAssetAmount method (regex for the whole method)
edit_other_method_pattern = r'  Future<void> _editOtherAssetAmount\(ZakatProvider provider\)\s*async\s*\{.*?\n  \}\n'
content = re.sub(edit_other_method_pattern, '\n', content, flags=re.DOTALL)

with open('lib/ui/wizard/zakat_wizard.dart', 'w') as f:
    f.write(content)
print("Removed manualOtherAssets logic.")
