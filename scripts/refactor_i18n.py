import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Pattern to match provider.translate('key') or context.read<ZakatProvider>().translate('key')
    # and optional fallback ?? 'string'
    pattern = r"(?:provider|context\.read<ZakatProvider>\(\))\.translate\('([^']+)'\)(?:\s*\?\?\s*'[^']*')?"
    
    new_content = re.sub(pattern, r"AppLocalizations.of(context)!.\1", content)
    
    if 'AppLocalizations.of(context)' in new_content and 'flutter_gen/gen_l10n/app_localizations.dart' not in new_content:
        import_stmt = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n"
        if "import 'package:flutter/material.dart';" in new_content:
            new_content = new_content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\n" + import_stmt)
        else:
            new_content = import_stmt + new_content

    if content != new_content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
