import re
import os

replacements = [
    # lib/ui/home_screen.dart
    (r"if \(hour < 12\) return 'শুভ সকাল';", r"if (hour < 12) return AppLocalizations.of(context)!.greeting_morning;"),
    (r"if \(hour < 17\) return 'শুভ দুপুর';", r"if (hour < 17) return AppLocalizations.of(context)!.greeting_afternoon;"),
    (r"return 'শুভ সন্ধ্যা';", r"return AppLocalizations.of(context)!.greeting_evening;"),
    (r"if \(lang == 'bn'\) return 'গত দিনের তুলনায়';", r"return AppLocalizations.of(context)!.compared_to_yesterday;"),
    
    # lib/ui/result_screen.dart
    (r"\? \(provider\.selectedLanguageCode == 'bn' \? 'হ্যাঁ' : provider\.selectedLanguageCode == 'tr' \? 'Evet' : 'Yes'\)", r"? AppLocalizations.of(context)!.yes_text"),
    (r": \(provider\.selectedLanguageCode == 'bn' \? 'না' : provider\.selectedLanguageCode == 'tr' \? 'Hayır' : 'No'\)", r": AppLocalizations.of(context)!.no_text"),

    # lib/ui/wizard/zakat_wizard.dart
    (r"'ধাপ ১: সম্পদ ও দায়ের পরিমাণ দিন\\n'", r"AppLocalizations.of(context)!.guide_step_1 + '\\n'"),
    (r"'ধাপ ২: নিসাব পদ্ধতি বাছাই করে হিসাব দেখুন\\n'", r"AppLocalizations.of(context)!.guide_step_2 + '\\n'"),
    (r"'ধাপ ৩: ফলাফল থেকে শেয়ার/সেভ করুন'", r"AppLocalizations.of(context)!.guide_step_3"),
    (r"Text\('১\) প্রথম ধাপে আপনার সম্পদ, পাওনা, এবং ঋণের পরিমাণ লিখুন।'\)", r"Text(AppLocalizations.of(context)!.guide_instruction_1)"),
    (r"Text\('২\) দ্বিতীয় ধাপে নিসাব \(রুপা/স্বর্ণ\) নির্বাচন করুন।'\)", r"Text(AppLocalizations.of(context)!.guide_instruction_2)"),
    (r"Text\('৩\) হাওল পূর্ণ হলে ২\.৫% হারে যাকাত গণনা হবে।'\)", r"Text(AppLocalizations.of(context)!.guide_instruction_3)"),
    (r"'১\. সম্পদ ও দায়ের বিবরণ'", r"AppLocalizations.of(context)!.step_1_title_detailed"),
    (r"subLabel: '৫৯২\.৮ গ্রাম',", r"subLabel: AppLocalizations.of(context)!.silver_nisab_weight,"),
    (r"subLabel: '৮৭\.৪৮ গ্রাম',", r"subLabel: AppLocalizations.of(context)!.gold_nisab_weight,"),
    (r"'২\.৫% হারে'", r"AppLocalizations.of(context)!.zakat_rate_label"),
]

files_to_process = [
    'lib/ui/home_screen.dart',
    'lib/ui/result_screen.dart',
    'lib/ui/wizard/zakat_wizard.dart'
]

for filepath in files_to_process:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    for pattern, repl in replacements:
        content = re.sub(pattern, repl, content)
        
    # Also fix _manualOtherAssets string replacement
    content = content.replace("? 'অন্যান্য সম্পদ: ৳ ${_manualOtherAssets.toStringAsFixed(0)}'",
                              "? '${AppLocalizations.of(context)!.add_wealth_type}: ${_manualOtherAssets.toStringAsFixed(0)}'")

    if content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")
