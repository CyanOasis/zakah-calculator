import re

with open('lib/providers/zakat_provider.dart', 'r') as f:
    content = f.read()

content = re.sub(r"  final Map<String, Map<String, String>> _translations = \{.*?\n  };\n", "", content, flags=re.DOTALL)
content = re.sub(r"  String translate\(String key\) \{\n    return _translations\[_selectedLanguageCode\]\?\[key\] \?\? _translations\['en'\]\?\[key\] \?\? key;\n  \}\n", "", content)
content = re.sub(r"  List<String> get supportedLanguageCodes => _translations\.keys\.toList\(growable: false\);", "  List<String> get supportedLanguageCodes => ['bn', 'tr', 'en'];", content)

with open('lib/providers/zakat_provider.dart', 'w') as f:
    f.write(content)
