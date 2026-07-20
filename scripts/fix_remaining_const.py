import re

with open('lib/ui/wizard/zakat_wizard.dart', 'r') as f:
    content = f.read()

content = content.replace("children: const [\n            Text(AppLocalizations.of(context)!.guide_view", 
                          "children: [\n            Text(AppLocalizations.of(context)!.guide_view")

content = content.replace("const Expanded(\n                child: Column(\n                  crossAxisAlignment: CrossAxisAlignment.start,\n                  children: [\n                    Text(\n                      AppLocalizations.of(context)!.result_title", 
                          "Expanded(\n                child: Column(\n                  crossAxisAlignment: CrossAxisAlignment.start,\n                  children: [\n                    Text(\n                      AppLocalizations.of(context)!.result_title")

content = content.replace("decoration: const InputDecoration(\n            labelText: AppLocalizations.of(context)!.receivables", 
                          "decoration: InputDecoration(\n            labelText: AppLocalizations.of(context)!.receivables")

with open('lib/ui/wizard/zakat_wizard.dart', 'w') as f:
    f.write(content)
