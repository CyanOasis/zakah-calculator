import json

files = {
    'en': 'lib/l10n/app_en.arb',
    'bn': 'lib/l10n/app_bn.arb',
    'tr': 'lib/l10n/app_tr.arb'
}

keys = {
    'gold_details': {'en': 'Gold Details', 'bn': 'স্বর্ণের বিবরণ', 'tr': 'Altın Detayları'},
    'silver_details': {'en': 'Silver Details', 'bn': 'রূপার বিবরণ', 'tr': 'Gümüş Detayları'},
    'add_new_gold': {'en': '+ Add new gold', 'bn': '+ নতুন স্বর্ণ যোগ করুন', 'tr': '+ Yeni altın ekle'},
    'add_new_silver': {'en': '+ Add new silver', 'bn': '+ নতুন রূপা যোগ করুন', 'tr': '+ Yeni gümüş ekle'},
    'no_gold_added': {'en': 'No gold added', 'bn': 'কোন স্বর্ণ যোগ করা হয়নি', 'tr': 'Altın eklenmedi'},
    'no_silver_added': {'en': 'No silver added', 'bn': 'কোন রূপা যোগ করা হয়নি', 'tr': 'Gümüş eklenmedi'},
    'empty_gold_desc': {'en': 'Add multiple gold items to calculate total value', 'bn': 'একাধিক ক্যারেটের স্বর্ণ যোগ করে মোট মূল্য হিসাব করুন', 'tr': 'Toplam değeri hesaplamak için birden fazla altın öğesi ekleyin'},
    'empty_silver_desc': {'en': 'Add multiple silver items to calculate total value', 'bn': 'একাধিক রূপার আইটেম যোগ করে মোট মূল্য হিসাব করুন', 'tr': 'Toplam değeri hesaplamak için birden fazla gümüş öğesi ekleyin'},
    'carat_label': {'en': 'Carat', 'bn': 'ক্যারেট', 'tr': 'Ayar'},
    'weight_label': {'en': 'Weight', 'bn': 'ওজন', 'tr': 'Ağırlık'},
    'add_item': {'en': 'Add Item', 'bn': 'যোগ করুন', 'tr': 'Öğe Ekle'},
    'unit_bhori': {'en': 'Bhori', 'bn': 'ভরি', 'tr': 'Bhori'},
    'unit_ana': {'en': 'Ana', 'bn': 'আনা', 'tr': 'Ana'},
    'unit_gram': {'en': 'Gram', 'bn': 'গ্রাম', 'tr': 'Gram'},
    'unit_ounce': {'en': 'Ounce', 'bn': 'আউন্স', 'tr': 'Ons'}
}

for lang, filepath in files.items():
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, values in keys.items():
        data[key] = values[lang]
        
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

