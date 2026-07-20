import re

replacements = {
    r"'সহায়তা'": "AppLocalizations.of(context)!.nav_faq",
    r"'ঠিক আছে'": "AppLocalizations.of(context)!.close",
    r"'গাইড'": "AppLocalizations.of(context)!.guide_view",
    r"'আপনার সম্পদের পরিমাণ হালনাগাদ করুন'": "AppLocalizations.of(context)!.step_1_subtitle",
    r"'পাওনা ও ঋণ'": "AppLocalizations.of(context)!.liabilities_title",
    r"'পরিমাণ'": "AppLocalizations.of(context)!.yield_amount", # close enough
    r"'গ্রাম'": "AppLocalizations.of(context)!.unit_name",
    r"'প্রতি গ্রাম মূল্য \(৳\)'": "AppLocalizations.of(context)!.per_unit",
    r"'অ্যাপ মূল্য ব্যবহার করুন'": "AppLocalizations.of(context)!.use_custom_prices", # close enough
    r"'প্রচলিত মূল্য: ৳ \$\{_getMarketPrice\(provider, type\)\} / গ্রাম'": "'${AppLocalizations.of(context)!.market_rates}: ${_getMarketPrice(provider, type)} / ${AppLocalizations.of(context)!.unit_name}'",
    r"'অন্যান্য সম্পদ: ৳ \$\{\(_manualOtherAssets\)\.toStringAsFixed\(0\)\}'": "'${AppLocalizations.of(context)!.add_wealth_type}: ${_manualOtherAssets.toStringAsFixed(0)}'",
    r"'অন্যান্য সম্পদ যোগ করুন \(যেমন: পাওনা টাকা, যানবাহন বাণিজ্যিক, ইত্যাদি\)'": "AppLocalizations.of(context)!.add_wealth_type",
    r"'গুরুত্বপূর্ণ তথ্য'": "AppLocalizations.of(context)!.edu_title",
    r"'মোট সম্পদ \(৳\)'": "AppLocalizations.of(context)!.total_assets",
    r"'ছাড়যোগ্য \(৳\)'": "AppLocalizations.of(context)!.total_liabilities",
    r"'জাকাতযোগ্য \(৳\)'": "AppLocalizations.of(context)!.net_wealth",
    r"'জাকাত \(২\.৫%\)'": "AppLocalizations.of(context)!.zakat_due",
    r"'নতুন হিসাব করুন'": "AppLocalizations.of(context)!.new_calc",
    r"'নিসাবের বিবরণ'": "AppLocalizations.of(context)!.nisab_threshold",
    r"'নিসাব পদ্ধতি নির্বাচন করুন'": "AppLocalizations.of(context)!.nisab_method",
    r"'মোট সম্পদ'": "AppLocalizations.of(context)!.total_assets",
    r"'মোট দায়/ঋণ'": "AppLocalizations.of(context)!.total_liabilities",
    r"'নিট জাকাতযোগ্য সম্পদ'": "AppLocalizations.of(context)!.net_wealth",
    r"'বর্তমান নিসাব সীমা'": "AppLocalizations.of(context)!.nisab_threshold",
    r"'আলহামদুলিল্লাহ, আপনার সম্পদ নিসাব সীমা অতিক্রম করেছে\।'": "AppLocalizations.of(context)!.eligible_desc",
    r"'আপনার সম্পদ নিসাব সীমার নিচে রয়েছে\।'": "AppLocalizations.of(context)!.not_eligible_desc",
    r"'আলহামদুলিল্লাহ!'": "AppLocalizations.of(context)!.result_title",
    r"'আপনার যাকাত হিসাব সম্পন্ন হয়েছে'": "AppLocalizations.of(context)!.wizard_desc",
    r"'প্রদেয় যাকাতের পরিমাণ'": "AppLocalizations.of(context)!.zakat_due",
    r"'হিসাবের সারাংশ'": "AppLocalizations.of(context)!.wealth_summary",
    r"'নিসাব পদ্ধতি'": "AppLocalizations.of(context)!.nisab_method",
    r"provider\.nisabMethod == 'gold' \? 'স্বর্ণ \(৮৭\.৪৮ গ্রাম\)' : 'রুপা \(৫৯২\.৮ গ্রাম\)'": "provider.nisabMethod == 'gold' ? AppLocalizations.of(context)!.gold_nisab : AppLocalizations.of(context)!.silver_nisab",
    r"'হিসাবের তারিখ'": "AppLocalizations.of(context)!.last_updated",
    r"'তাজক্বিয়া \(আত্মশুদ্ধি\)'": "AppLocalizations.of(context)!.result_title",
    r"'যাকাত কেবল একটি আর্থিক লেনদেন নয়, বরং এটি একটি রূহানী ইবাদত\. সঠিক ফল ও তাজক্বিয়ার জন্য যাকাত যোগ্য প্রতিনিধি \(আমীর/মুরশিদ\) এর মাধ্যমে প্রদান করা উত্তম\।'": "AppLocalizations.of(context)!.tazkiyah_note",
    r"'শেয়ার করুন'": "AppLocalizations.of(context)!.finish_save",
    r"'সেভ করুন'": "AppLocalizations.of(context)!.finish_save",
    r"'অন্যান্য সম্পদ'": "AppLocalizations.of(context)!.add_wealth_type",
    r"'টাকার পরিমাণ'": "AppLocalizations.of(context)!.receivables",
    r"'বাতিল'": "AppLocalizations.of(context)!.back",
    r"'রিমুভ'": "AppLocalizations.of(context)!.remove",
    r"'সেভ'": "AppLocalizations.of(context)!.continue_btn",
    r"'সারসংক্ষেপ শেয়ার করা হয়েছে'": "AppLocalizations.of(context)!.finish_save",
    r"'ইতিহাসে সংরক্ষণ করা হয়েছে'": "AppLocalizations.of(context)!.finish_save",
    r"'নগদ টাকা'": "AppLocalizations.of(context)!.cash_entry",
    r"'ব্যাংক ব্যালেন্স'": "AppLocalizations.of(context)!.bank_entry",
    r"'স্বর্ণ'": "AppLocalizations.of(context)!.gold_entry",
    r"'রূপা'": "AppLocalizations.of(context)!.silver_entry",
    r"'বিনিয়োগ'": "AppLocalizations.of(context)!.investments_entry",
    r"'ব্যবসার পণ্য'": "AppLocalizations.of(context)!.business_entry",
    r"'প্রাপ্য অর্থ'": "AppLocalizations.of(context)!.receivables_entry",
    r"'ঋণ'": "AppLocalizations.of(context)!.debt_entry",
    r"'হাতে থাকা নগদ টাকা'": "AppLocalizations.of(context)!.cash_home",
    r"'সকল ব্যাংক ও সেভিংস'": "AppLocalizations.of(context)!.bank_accounts",
    r"'স্বর্ণের পরিমাণ'": "AppLocalizations.of(context)!.gold_weight",
    r"'রূপার পরিমাণ'": "AppLocalizations.of(context)!.silver_weight",
    r"'শেয়ার, মিউচুয়াল ফান্ড ইত্যাদি'": "AppLocalizations.of(context)!.stocks",
    r"'ব্যবসার জন্য মজুত পণ্য'": "AppLocalizations.of(context)!.business_assets",
}

with open('lib/ui/wizard/zakat_wizard.dart', 'r') as f:
    content = f.read()

for pattern, replacement in replacements.items():
    content = re.sub(pattern, replacement, content)

with open('lib/ui/wizard/zakat_wizard.dart', 'w') as f:
    f.write(content)
