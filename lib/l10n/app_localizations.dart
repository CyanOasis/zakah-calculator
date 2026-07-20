import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Zakat & Tazkiyah'**
  String get app_title;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum'**
  String get welcome;

  /// No description provided for @market_rates.
  ///
  /// In en, this message translates to:
  /// **'Live Market Rates (2026)'**
  String get market_rates;

  /// No description provided for @gold_24k.
  ///
  /// In en, this message translates to:
  /// **'Gold (24K)'**
  String get gold_24k;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver (Pure)'**
  String get silver;

  /// No description provided for @per_unit.
  ///
  /// In en, this message translates to:
  /// **'per gram'**
  String get per_unit;

  /// No description provided for @market_source_bajus.
  ///
  /// In en, this message translates to:
  /// **'by BAJUS'**
  String get market_source_bajus;

  /// No description provided for @market_source_gold_api.
  ///
  /// In en, this message translates to:
  /// **'by Gold API'**
  String get market_source_gold_api;

  /// No description provided for @market_source_ibja.
  ///
  /// In en, this message translates to:
  /// **'by IBJA'**
  String get market_source_ibja;

  /// No description provided for @market_source_harem.
  ///
  /// In en, this message translates to:
  /// **'by Harem'**
  String get market_source_harem;

  /// No description provided for @market_source_altin_in.
  ///
  /// In en, this message translates to:
  /// **'by Altin.in'**
  String get market_source_altin_in;

  /// No description provided for @last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get last_updated;

  /// No description provided for @cached_label.
  ///
  /// In en, this message translates to:
  /// **'Cached'**
  String get cached_label;

  /// No description provided for @fetch_failed_message.
  ///
  /// In en, this message translates to:
  /// **'Live update failed, showing cached rates'**
  String get fetch_failed_message;

  /// No description provided for @manual_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh rates'**
  String get manual_refresh;

  /// No description provided for @unit_name.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unit_name;

  /// No description provided for @nisab_threshold.
  ///
  /// In en, this message translates to:
  /// **'Nisab Thresholds (2026)'**
  String get nisab_threshold;

  /// No description provided for @nisab_desc.
  ///
  /// In en, this message translates to:
  /// **'Minimum debt-free wealth required for Zakat eligibility.'**
  String get nisab_desc;

  /// No description provided for @silver_nisab.
  ///
  /// In en, this message translates to:
  /// **'Silver Nisab (Pure)'**
  String get silver_nisab;

  /// No description provided for @gold_nisab.
  ///
  /// In en, this message translates to:
  /// **'Gold Nisab'**
  String get gold_nisab;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @start_wizard.
  ///
  /// In en, this message translates to:
  /// **'Start Calculation'**
  String get start_wizard;

  /// No description provided for @wizard_desc.
  ///
  /// In en, this message translates to:
  /// **'Ensure accurate calculation and spiritual purification (Tazkiyah).'**
  String get wizard_desc;

  /// No description provided for @new_calc.
  ///
  /// In en, this message translates to:
  /// **'New Calculation'**
  String get new_calc;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get step;

  /// No description provided for @step_of.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get step_of;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @calculate_now.
  ///
  /// In en, this message translates to:
  /// **'Calculate Now'**
  String get calculate_now;

  /// No description provided for @nisab_method.
  ///
  /// In en, this message translates to:
  /// **'Nisab method'**
  String get nisab_method;

  /// No description provided for @silver_nisab_option.
  ///
  /// In en, this message translates to:
  /// **'Silver nisab (recommended)'**
  String get silver_nisab_option;

  /// No description provided for @gold_nisab_option.
  ///
  /// In en, this message translates to:
  /// **'Gold nisab'**
  String get gold_nisab_option;

  /// No description provided for @hawl_completed.
  ///
  /// In en, this message translates to:
  /// **'One lunar year completed'**
  String get hawl_completed;

  /// No description provided for @hawl_pending_desc.
  ///
  /// In en, this message translates to:
  /// **'Zakat is not obligatory on general assets (money, gold, silver, etc.) until one lunar (Hijri) year has passed.'**
  String get hawl_pending_desc;

  /// No description provided for @liquidity_title.
  ///
  /// In en, this message translates to:
  /// **'Liquidity & Cash'**
  String get liquidity_title;

  /// No description provided for @liquidity_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter all your debt-free cash and bank balances.'**
  String get liquidity_desc;

  /// No description provided for @cash_home.
  ///
  /// In en, this message translates to:
  /// **'Cash at Home'**
  String get cash_home;

  /// No description provided for @bank_accounts.
  ///
  /// In en, this message translates to:
  /// **'Bank Accounts'**
  String get bank_accounts;

  /// No description provided for @metals_title.
  ///
  /// In en, this message translates to:
  /// **'Precious Metals'**
  String get metals_title;

  /// No description provided for @metals_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter weight of gold and silver in grams.'**
  String get metals_desc;

  /// No description provided for @gold_weight.
  ///
  /// In en, this message translates to:
  /// **'Gold Weight'**
  String get gold_weight;

  /// No description provided for @silver_weight.
  ///
  /// In en, this message translates to:
  /// **'Silver Weight'**
  String get silver_weight;

  /// No description provided for @gold_carat.
  ///
  /// In en, this message translates to:
  /// **'Gold Carat'**
  String get gold_carat;

  /// No description provided for @carat_24.
  ///
  /// In en, this message translates to:
  /// **'24 Carat (Pure)'**
  String get carat_24;

  /// No description provided for @carat_22.
  ///
  /// In en, this message translates to:
  /// **'22 Carat'**
  String get carat_22;

  /// No description provided for @carat_21.
  ///
  /// In en, this message translates to:
  /// **'21 Carat'**
  String get carat_21;

  /// No description provided for @carat_18.
  ///
  /// In en, this message translates to:
  /// **'18 Carat'**
  String get carat_18;

  /// No description provided for @carat_trad.
  ///
  /// In en, this message translates to:
  /// **'Traditional'**
  String get carat_trad;

  /// No description provided for @investments_title.
  ///
  /// In en, this message translates to:
  /// **'Investments & Business'**
  String get investments_title;

  /// No description provided for @investments_desc.
  ///
  /// In en, this message translates to:
  /// **'Current market value of shares and resale goods.'**
  String get investments_desc;

  /// No description provided for @stocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks & Shares'**
  String get stocks;

  /// No description provided for @business_assets.
  ///
  /// In en, this message translates to:
  /// **'Business Assets'**
  String get business_assets;

  /// No description provided for @receivables_title.
  ///
  /// In en, this message translates to:
  /// **'Receivables'**
  String get receivables_title;

  /// No description provided for @receivables_desc.
  ///
  /// In en, this message translates to:
  /// **'Money owed to you that is expected to be repaid.'**
  String get receivables_desc;

  /// No description provided for @receivables.
  ///
  /// In en, this message translates to:
  /// **'Owed to you'**
  String get receivables;

  /// No description provided for @liabilities_title.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get liabilities_title;

  /// No description provided for @liabilities_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter your immediate debts and unpaid bills.'**
  String get liabilities_desc;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Personal Debts'**
  String get debts;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Bills'**
  String get bills;

  /// No description provided for @result_title.
  ///
  /// In en, this message translates to:
  /// **'Zakat & Tazkiyah Report'**
  String get result_title;

  /// No description provided for @zakat_due.
  ///
  /// In en, this message translates to:
  /// **'Current Zakat Due'**
  String get zakat_due;

  /// No description provided for @no_zakat.
  ///
  /// In en, this message translates to:
  /// **'No Zakat currently due'**
  String get no_zakat;

  /// No description provided for @eligible_desc.
  ///
  /// In en, this message translates to:
  /// **'2.5% of net zakatable wealth is due.'**
  String get eligible_desc;

  /// No description provided for @not_eligible_desc.
  ///
  /// In en, this message translates to:
  /// **'Wealth is below the selected nisab threshold.'**
  String get not_eligible_desc;

  /// No description provided for @wealth_summary.
  ///
  /// In en, this message translates to:
  /// **'Wealth Summary'**
  String get wealth_summary;

  /// No description provided for @total_assets.
  ///
  /// In en, this message translates to:
  /// **'Total Assets'**
  String get total_assets;

  /// No description provided for @total_liabilities.
  ///
  /// In en, this message translates to:
  /// **'Total Liabilities'**
  String get total_liabilities;

  /// No description provided for @net_wealth.
  ///
  /// In en, this message translates to:
  /// **'Net Wealth'**
  String get net_wealth;

  /// No description provided for @tazkiyah_note.
  ///
  /// In en, this message translates to:
  /// **'Note: Zakat is a spiritual act. For true Tazkiyah, distribution through a qualified representative (Amir/Murshid) is highly recommended.'**
  String get tazkiyah_note;

  /// No description provided for @finish_save.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish_save;

  /// No description provided for @edit_inputs.
  ///
  /// In en, this message translates to:
  /// **'Edit Inputs'**
  String get edit_inputs;

  /// No description provided for @category_securities.
  ///
  /// In en, this message translates to:
  /// **'Wealth Zakat'**
  String get category_securities;

  /// No description provided for @category_animals.
  ///
  /// In en, this message translates to:
  /// **'Livestock Zakat'**
  String get category_animals;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get nav_history;

  /// No description provided for @nav_calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get nav_calculator;

  /// No description provided for @nav_faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get nav_faq;

  /// No description provided for @calculator_intro.
  ///
  /// In en, this message translates to:
  /// **'Choose the zakat calculator you need.'**
  String get calculator_intro;

  /// No description provided for @add_wealth_type.
  ///
  /// In en, this message translates to:
  /// **'Add asset'**
  String get add_wealth_type;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @use_custom_prices.
  ///
  /// In en, this message translates to:
  /// **'Use app\'\'s prices'**
  String get use_custom_prices;

  /// No description provided for @custom_price_desc.
  ///
  /// In en, this message translates to:
  /// **'Use live market prices instead of entering your own.'**
  String get custom_price_desc;

  /// No description provided for @custom_gold_price.
  ///
  /// In en, this message translates to:
  /// **'Pure gold price (24K)'**
  String get custom_gold_price;

  /// No description provided for @custom_silver_price.
  ///
  /// In en, this message translates to:
  /// **'Pure silver price'**
  String get custom_silver_price;

  /// No description provided for @custom_price_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter price per unit. Leave empty to use live market prices.'**
  String get custom_price_hint;

  /// No description provided for @cash_entry.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash_entry;

  /// No description provided for @bank_entry.
  ///
  /// In en, this message translates to:
  /// **'Bank balance'**
  String get bank_entry;

  /// No description provided for @gold_entry.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold_entry;

  /// No description provided for @silver_entry.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver_entry;

  /// No description provided for @investments_entry.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get investments_entry;

  /// No description provided for @business_entry.
  ///
  /// In en, this message translates to:
  /// **'Business asset'**
  String get business_entry;

  /// No description provided for @receivables_entry.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get receivables_entry;

  /// No description provided for @debt_entry.
  ///
  /// In en, this message translates to:
  /// **'Debt'**
  String get debt_entry;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon...'**
  String get coming_soon;

  /// No description provided for @animal_title.
  ///
  /// In en, this message translates to:
  /// **'Livestock Zakat'**
  String get animal_title;

  /// No description provided for @animal_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of livestock currently owned.'**
  String get animal_desc;

  /// No description provided for @sheep_count.
  ///
  /// In en, this message translates to:
  /// **'Sheep/Goat Count'**
  String get sheep_count;

  /// No description provided for @cow_count.
  ///
  /// In en, this message translates to:
  /// **'Cow/Buffalo Count'**
  String get cow_count;

  /// No description provided for @camel_count.
  ///
  /// In en, this message translates to:
  /// **'Camel Count'**
  String get camel_count;

  /// No description provided for @ushur_title.
  ///
  /// In en, this message translates to:
  /// **'Ushur (Agriculture)'**
  String get ushur_title;

  /// No description provided for @ushur_desc.
  ///
  /// In en, this message translates to:
  /// **'Select irrigation method and enter yield.'**
  String get ushur_desc;

  /// No description provided for @yield_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Yield (kg)'**
  String get yield_amount;

  /// No description provided for @irrigation_natural.
  ///
  /// In en, this message translates to:
  /// **'Natural Irrigation (Rain)'**
  String get irrigation_natural;

  /// No description provided for @irrigation_artificial.
  ///
  /// In en, this message translates to:
  /// **'Artificial Irrigation (Tools)'**
  String get irrigation_artificial;

  /// No description provided for @ushur_due.
  ///
  /// In en, this message translates to:
  /// **'Ushur Due'**
  String get ushur_due;

  /// No description provided for @edu_title.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get edu_title;

  /// No description provided for @edu_q1.
  ///
  /// In en, this message translates to:
  /// **'What is Zakat?'**
  String get edu_q1;

  /// No description provided for @edu_a1.
  ///
  /// In en, this message translates to:
  /// **'Zakat is one of the five pillars of Islam, mandatory for those who meet the Nisab threshold.'**
  String get edu_a1;

  /// No description provided for @edu_q2.
  ///
  /// In en, this message translates to:
  /// **'What is Nisab?'**
  String get edu_q2;

  /// No description provided for @edu_a2.
  ///
  /// In en, this message translates to:
  /// **'Nisab is the minimum threshold of wealth for Zakat to become obligatory.'**
  String get edu_a2;

  /// No description provided for @history_empty.
  ///
  /// In en, this message translates to:
  /// **'No saved calculations yet'**
  String get history_empty;

  /// No description provided for @history_details.
  ///
  /// In en, this message translates to:
  /// **'Calculation Details'**
  String get history_details;

  /// No description provided for @history_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get history_category;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @wizard_desc_short.
  ///
  /// In en, this message translates to:
  /// **'Calculate your Zakat easily'**
  String get wizard_desc_short;

  /// No description provided for @step_1_label.
  ///
  /// In en, this message translates to:
  /// **'Select Assets'**
  String get step_1_label;

  /// No description provided for @step_2_label.
  ///
  /// In en, this message translates to:
  /// **'Enter Amounts'**
  String get step_2_label;

  /// No description provided for @step_3_label.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get step_3_label;

  /// No description provided for @step_4_label.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get step_4_label;

  /// No description provided for @step_1_title.
  ///
  /// In en, this message translates to:
  /// **'Select Assets'**
  String get step_1_title;

  /// No description provided for @step_1_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Assets you own that are subject to Zakat'**
  String get step_1_subtitle;

  /// No description provided for @step_2_title.
  ///
  /// In en, this message translates to:
  /// **'Enter Amounts (Debts & Liabilities)'**
  String get step_2_title;

  /// No description provided for @step_2_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your current debts and unpaid bills'**
  String get step_2_subtitle;

  /// No description provided for @step_3_title.
  ///
  /// In en, this message translates to:
  /// **'Review Calculation'**
  String get step_3_title;

  /// No description provided for @guide_view.
  ///
  /// In en, this message translates to:
  /// **'View Guide'**
  String get guide_view;

  /// No description provided for @wizard_info_text.
  ///
  /// In en, this message translates to:
  /// **'To complete the Zakat calculation, select at least one asset and enter the amount. You can change all prices, otherwise the app\'\'s current prices will be used.'**
  String get wizard_info_text;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @next_step.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get next_step;

  /// No description provided for @greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greeting_morning;

  /// No description provided for @greeting_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greeting_afternoon;

  /// No description provided for @greeting_evening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greeting_evening;

  /// No description provided for @compared_to_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Compared to yesterday'**
  String get compared_to_yesterday;

  /// No description provided for @yes_text.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes_text;

  /// No description provided for @no_text.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no_text;

  /// No description provided for @guide_step_1.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Enter assets and liabilities'**
  String get guide_step_1;

  /// No description provided for @guide_step_2.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Choose Nisab method and review'**
  String get guide_step_2;

  /// No description provided for @guide_step_3.
  ///
  /// In en, this message translates to:
  /// **'Step 3: Save or share the results'**
  String get guide_step_3;

  /// No description provided for @guide_instruction_1.
  ///
  /// In en, this message translates to:
  /// **'1) Enter the amount of your assets, receivables, and debts in the first step.'**
  String get guide_instruction_1;

  /// No description provided for @guide_instruction_2.
  ///
  /// In en, this message translates to:
  /// **'2) Select the Nisab (Silver/Gold) in the second step.'**
  String get guide_instruction_2;

  /// No description provided for @guide_instruction_3.
  ///
  /// In en, this message translates to:
  /// **'3) If Hawl is complete, Zakat will be calculated at 2.5%.'**
  String get guide_instruction_3;

  /// No description provided for @step_1_title_detailed.
  ///
  /// In en, this message translates to:
  /// **'1. Asset & Liability Details'**
  String get step_1_title_detailed;

  /// No description provided for @silver_nisab_weight.
  ///
  /// In en, this message translates to:
  /// **'592.8 grams'**
  String get silver_nisab_weight;

  /// No description provided for @gold_nisab_weight.
  ///
  /// In en, this message translates to:
  /// **'87.48 grams'**
  String get gold_nisab_weight;

  /// No description provided for @zakat_rate_label.
  ///
  /// In en, this message translates to:
  /// **'at 2.5% rate'**
  String get zakat_rate_label;

  /// No description provided for @gold_details.
  ///
  /// In en, this message translates to:
  /// **'Gold Details'**
  String get gold_details;

  /// No description provided for @silver_details.
  ///
  /// In en, this message translates to:
  /// **'Silver Details'**
  String get silver_details;

  /// No description provided for @add_new_gold.
  ///
  /// In en, this message translates to:
  /// **'Add new gold'**
  String get add_new_gold;

  /// No description provided for @add_new_silver.
  ///
  /// In en, this message translates to:
  /// **'Add new silver'**
  String get add_new_silver;

  /// No description provided for @no_gold_added.
  ///
  /// In en, this message translates to:
  /// **'No gold added'**
  String get no_gold_added;

  /// No description provided for @no_silver_added.
  ///
  /// In en, this message translates to:
  /// **'No silver added'**
  String get no_silver_added;

  /// No description provided for @empty_gold_desc.
  ///
  /// In en, this message translates to:
  /// **'Add multiple gold items to calculate total value'**
  String get empty_gold_desc;

  /// No description provided for @empty_silver_desc.
  ///
  /// In en, this message translates to:
  /// **'Add multiple silver items to calculate total value'**
  String get empty_silver_desc;

  /// No description provided for @carat_label.
  ///
  /// In en, this message translates to:
  /// **'Carat'**
  String get carat_label;

  /// No description provided for @weight_label.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight_label;

  /// No description provided for @add_item.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get add_item;

  /// No description provided for @unit_bhori.
  ///
  /// In en, this message translates to:
  /// **'Bhori'**
  String get unit_bhori;

  /// No description provided for @unit_ana.
  ///
  /// In en, this message translates to:
  /// **'Ana'**
  String get unit_ana;

  /// No description provided for @unit_gram.
  ///
  /// In en, this message translates to:
  /// **'Gram'**
  String get unit_gram;

  /// No description provided for @unit_ounce.
  ///
  /// In en, this message translates to:
  /// **'Ounce'**
  String get unit_ounce;

  /// No description provided for @current_price.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get current_price;

  /// No description provided for @price_trend.
  ///
  /// In en, this message translates to:
  /// **'Price Trend'**
  String get price_trend;

  /// No description provided for @karat_breakdown.
  ///
  /// In en, this message translates to:
  /// **'Karat Breakdown'**
  String get karat_breakdown;

  /// No description provided for @silver_purity_breakdown.
  ///
  /// In en, this message translates to:
  /// **'Silver Purity Breakdown'**
  String get silver_purity_breakdown;

  /// No description provided for @silver_24k.
  ///
  /// In en, this message translates to:
  /// **'24K (Fine Silver)'**
  String get silver_24k;

  /// No description provided for @silver_22k.
  ///
  /// In en, this message translates to:
  /// **'22K (Sterling Silver)'**
  String get silver_22k;

  /// No description provided for @silver_21k.
  ///
  /// In en, this message translates to:
  /// **'21K (Coin Silver)'**
  String get silver_21k;

  /// No description provided for @silver_19k.
  ///
  /// In en, this message translates to:
  /// **'19K (Traditional Silver)'**
  String get silver_19k;

  /// No description provided for @unit_label_gram.
  ///
  /// In en, this message translates to:
  /// **'Gram (g)'**
  String get unit_label_gram;

  /// No description provided for @unit_label_bhori.
  ///
  /// In en, this message translates to:
  /// **'Bhori (vori)'**
  String get unit_label_bhori;

  /// No description provided for @unit_label_ounce.
  ///
  /// In en, this message translates to:
  /// **'Ounce (oz)'**
  String get unit_label_ounce;

  /// No description provided for @history_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All Records'**
  String get history_filter_all;

  /// No description provided for @history_filter_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get history_filter_completed;

  /// No description provided for @history_filter_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get history_filter_draft;

  /// No description provided for @history_details_summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get history_details_summary;

  /// No description provided for @history_details_zakat_rate.
  ///
  /// In en, this message translates to:
  /// **'Zakat Rate'**
  String get history_details_zakat_rate;

  /// No description provided for @history_details_total_zakat.
  ///
  /// In en, this message translates to:
  /// **'Total Zakat'**
  String get history_details_total_zakat;

  /// No description provided for @history_details_asset_breakdown.
  ///
  /// In en, this message translates to:
  /// **'Asset Breakdown'**
  String get history_details_asset_breakdown;

  /// No description provided for @history_details_cash_assets.
  ///
  /// In en, this message translates to:
  /// **'Cash Assets'**
  String get history_details_cash_assets;

  /// No description provided for @history_details_cash_home.
  ///
  /// In en, this message translates to:
  /// **'Cash at Home'**
  String get history_details_cash_home;

  /// No description provided for @history_details_bank_deposits.
  ///
  /// In en, this message translates to:
  /// **'Bank Deposits'**
  String get history_details_bank_deposits;

  /// No description provided for @history_details_bank_accounts.
  ///
  /// In en, this message translates to:
  /// **'Bank Accounts'**
  String get history_details_bank_accounts;

  /// No description provided for @history_details_gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get history_details_gold;

  /// No description provided for @history_details_silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get history_details_silver;

  /// No description provided for @history_details_business_goods.
  ///
  /// In en, this message translates to:
  /// **'Business Goods'**
  String get history_details_business_goods;

  /// No description provided for @history_details_stock_items.
  ///
  /// In en, this message translates to:
  /// **'Stock and Items'**
  String get history_details_stock_items;

  /// No description provided for @history_details_other_assets.
  ///
  /// In en, this message translates to:
  /// **'Other Assets'**
  String get history_details_other_assets;

  /// No description provided for @history_details_furniture_etc.
  ///
  /// In en, this message translates to:
  /// **'Furniture, Electronics, etc.'**
  String get history_details_furniture_etc;

  /// No description provided for @history_details_zakat_breakdown.
  ///
  /// In en, this message translates to:
  /// **'Zakat Breakdown'**
  String get history_details_zakat_breakdown;

  /// No description provided for @history_details_zakat_on_assets.
  ///
  /// In en, this message translates to:
  /// **'Zakat on Total Assets (2.5%)'**
  String get history_details_zakat_on_assets;

  /// No description provided for @history_details_liabilities_expenses.
  ///
  /// In en, this message translates to:
  /// **'Liabilities & Expenses (if any)'**
  String get history_details_liabilities_expenses;

  /// No description provided for @history_details_payable_zakat.
  ///
  /// In en, this message translates to:
  /// **'Payable Zakat'**
  String get history_details_payable_zakat;

  /// No description provided for @history_details_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get history_details_share;

  /// No description provided for @history_no_completed.
  ///
  /// In en, this message translates to:
  /// **'No completed calculations found'**
  String get history_no_completed;

  /// No description provided for @history_no_drafts.
  ///
  /// In en, this message translates to:
  /// **'No drafts found'**
  String get history_no_drafts;

  /// No description provided for @date_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get date_filter_title;

  /// No description provided for @date_filter_all_time.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get date_filter_all_time;

  /// No description provided for @date_filter_this_year.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get date_filter_this_year;

  /// No description provided for @date_filter_last_year.
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get date_filter_last_year;

  /// No description provided for @date_filter_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get date_filter_custom;

  /// No description provided for @date_filter_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get date_filter_reset;

  /// No description provided for @date_filter_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get date_filter_apply;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
