import re

with open('lib/ui/wizard/zakat_wizard.dart', 'r') as f:
    content = f.read()

method = """
  Future<void> _showAddMetalItemSheet(ZakatProvider provider, bool isGold) async {
    double weight = 0;
    String unit = provider.usesBhoriUnit ? 'bhori' : 'gram';
    int purity = 22; // default
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20, right: 20, top: 20
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGold ? AppLocalizations.of(context)!.add_new_gold : AppLocalizations.of(context)!.add_new_silver,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.weight_label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: '0',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (val) => weight = double.tryParse(val) ?? 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Unit', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: unit,
                              underline: const SizedBox(),
                              items: (provider.selectedLanguageCode == 'tr' ? ['gram', 'ounce'] : ['gram', 'bhori', 'ana']).map((u) {
                                String label = u;
                                if (u == 'bhori') label = AppLocalizations.of(context)!.unit_bhori;
                                if (u == 'ana') label = AppLocalizations.of(context)!.unit_ana;
                                if (u == 'gram') label = AppLocalizations.of(context)!.unit_gram;
                                if (u == 'ounce') label = AppLocalizations.of(context)!.unit_ounce;
                                return DropdownMenuItem(value: u, child: Text(label, style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => unit = v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isGold) ...[
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.carat_label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: purity,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: 24, child: Text('24 ${AppLocalizations.of(context)!.carat_label}')),
                        DropdownMenuItem(value: 22, child: Text('22 ${AppLocalizations.of(context)!.carat_label}')),
                        DropdownMenuItem(value: 21, child: Text('21 ${AppLocalizations.of(context)!.carat_label}')),
                        DropdownMenuItem(value: 18, child: Text('18 ${AppLocalizations.of(context)!.carat_label}')),
                        DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.carat_trad)),
                      ],
                      onChanged: (v) {
                        if (v != null) setModalState(() => purity = v);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (weight <= 0) return;
                      final item = MetalItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        weight: weight,
                        unit: unit,
                        purity: isGold ? purity : null,
                      );
                      if (isGold) {
                        provider.addGoldItem(item);
                      } else {
                        provider.addSilverItem(item);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004D40),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(AppLocalizations.of(context)!.add_item),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
"""

content = content.replace("    _syncProvider(provider);\n  }", "    _syncProvider(provider);\n  }\n" + method)

with open('lib/ui/wizard/zakat_wizard.dart', 'w') as f:
    f.write(content)
