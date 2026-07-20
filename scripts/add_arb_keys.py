import json

files = {
    'en': 'lib/l10n/app_en.arb',
    'bn': 'lib/l10n/app_bn.arb',
    'tr': 'lib/l10n/app_tr.arb'
}

keys = {
    'greeting_morning': {'en': 'Good Morning', 'bn': 'শুভ সকাল', 'tr': 'Günaydın'},
    'greeting_afternoon': {'en': 'Good Afternoon', 'bn': 'শুভ দুপুর', 'tr': 'Tünaydın'},
    'greeting_evening': {'en': 'Good Evening', 'bn': 'শুভ সন্ধ্যা', 'tr': 'İyi Akşamlar'},
    'compared_to_yesterday': {'en': 'Compared to yesterday', 'bn': 'গত দিনের তুলনায়', 'tr': 'Düne göre'},
    'yes_text': {'en': 'Yes', 'bn': 'হ্যাঁ', 'tr': 'Evet'},
    'no_text': {'en': 'No', 'bn': 'না', 'tr': 'Hayır'},
    'guide_step_1': {'en': 'Step 1: Enter assets and liabilities', 'bn': 'ধাপ ১: সম্পদ ও দায়ের পরিমাণ দিন', 'tr': 'Adım 1: Varlıkları ve borçları girin'},
    'guide_step_2': {'en': 'Step 2: Choose Nisab method and review', 'bn': 'ধাপ ২: নিসাব পদ্ধতি বাছাই করে হিসাব দেখুন', 'tr': 'Adım 2: Nisab yöntemini seçin ve inceleyin'},
    'guide_step_3': {'en': 'Step 3: Save or share the results', 'bn': 'ধাপ ৩: ফলাফল থেকে শেয়ার/সেভ করুন', 'tr': 'Adım 3: Sonuçları kaydedin veya paylaşın'},
    'guide_instruction_1': {'en': '1) Enter the amount of your assets, receivables, and debts in the first step.', 'bn': '১) প্রথম ধাপে আপনার সম্পদ, পাওনা, এবং ঋণের পরিমাণ লিখুন।', 'tr': '1) İlk adımda varlıklarınızın, alacaklarınızın ve borçlarınızın miktarını girin.'},
    'guide_instruction_2': {'en': '2) Select the Nisab (Silver/Gold) in the second step.', 'bn': '২) দ্বিতীয় ধাপে নিসাব (রুপা/স্বর্ণ) নির্বাচন করুন।', 'tr': '2) İkinci adımda Nisabı (Gümüş/Altın) seçin.'},
    'guide_instruction_3': {'en': '3) If Hawl is complete, Zakat will be calculated at 2.5%.', 'bn': '৩) হাওল পূর্ণ হলে ২.৫% হারে যাকাত গণনা হবে।', 'tr': '3) Havl tamamlandıysa Zekat %2.5 üzerinden hesaplanacaktır.'},
    'step_1_title_detailed': {'en': '1. Asset & Liability Details', 'bn': '১. সম্পদ ও দায়ের বিবরণ', 'tr': '1. Varlık ve Borç Detayları'},
    'silver_nisab_weight': {'en': '592.8 grams', 'bn': '৫৯২.৮ গ্রাম', 'tr': '592.8 gram'},
    'gold_nisab_weight': {'en': '87.48 grams', 'bn': '৮৭.৪৮ গ্রাম', 'tr': '87.48 gram'},
    'zakat_rate_label': {'en': 'at 2.5% rate', 'bn': '২.৫% হারে', 'tr': '%2.5 oranında'}
}

for lang, filepath in files.items():
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, values in keys.items():
        data[key] = values[lang]
        
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

