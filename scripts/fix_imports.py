import os

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()
            if "import 'package:flutter_gen/gen_l10n/app_localizations.dart';" in content:
                content = content.replace("import 'package:flutter_gen/gen_l10n/app_localizations.dart';", 
                                          "import 'package:zakat/l10n/app_localizations.dart';")
                with open(filepath, 'w') as f:
                    f.write(content)
