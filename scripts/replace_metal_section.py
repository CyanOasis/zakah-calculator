import re

with open('lib/ui/wizard/zakat_wizard.dart', 'r') as f:
    content = f.read()

start_marker = "  Widget _buildExpandedMetalSection(ZakatProvider provider, _WealthEntryType type) {"
end_marker = "  String _getMarketPrice(ZakatProvider provider, _WealthEntryType type) {"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    old_section = content[start_idx:end_idx]
    
    new_section = """  Widget _buildExpandedMetalSection(ZakatProvider provider, _WealthEntryType type) {
    final bool isGold = type == _WealthEntryType.gold;
    final List<MetalItem> items = isGold ? provider.goldItems : provider.silverItems;

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isGold ? AppLocalizations.of(context)!.gold_details : AppLocalizations.of(context)!.silver_details,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF263238)),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.info_outline, size: 14, color: Colors.grey),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showAddMetalItemSheet(provider, isGold),
                icon: const Icon(Icons.add, size: 14),
                label: Text(isGold ? AppLocalizations.of(context)!.add_new_gold : AppLocalizations.of(context)!.add_new_silver),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1B5E20),
                  side: const BorderSide(color: Color(0xFF81C784)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F9F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8F5E9)),
              ),
              child: Column(
                children: [
                  Text(
                    isGold ? AppLocalizations.of(context)!.no_gold_added : AppLocalizations.of(context)!.no_silver_added,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGold ? AppLocalizations.of(context)!.empty_gold_desc : AppLocalizations.of(context)!.empty_silver_desc,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4C6A58)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                String unitLocal = item.unit == 'bhori' ? AppLocalizations.of(context)!.unit_bhori : 
                                  item.unit == 'ana' ? AppLocalizations.of(context)!.unit_ana :
                                  item.unit == 'ounce' ? AppLocalizations.of(context)!.unit_ounce :
                                  AppLocalizations.of(context)!.unit_gram;
                String title = '${item.weight} $unitLocal';
                if (isGold) {
                  title = '${item.purity == 0 ? AppLocalizations.of(context)!.carat_trad : '${item.purity} ${AppLocalizations.of(context)!.carat_label}'}, $title';
                }
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () {
                          if (isGold) {
                            provider.removeGoldItem(item.id);
                          } else {
                            provider.removeSilverItem(item.id);
                          }
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                );
              },
            ),
            
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _useAppPrices[type] ?? true,
                  onChanged: (v) => setState(() => _useAppPrices[type] = v ?? true),
                  activeColor: const Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.use_custom_prices, 
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        '${AppLocalizations.of(context)!.market_rates}: ${_getMarketPrice(provider, type)} / ${provider.unitNameLabel}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.info_outline, size: 12, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

"""
    
    content = content[:start_idx] + new_section + content[end_idx:]
    with open('lib/ui/wizard/zakat_wizard.dart', 'w') as f:
        f.write(content)
    print("Replaced section.")
else:
    print("Could not find section.")

