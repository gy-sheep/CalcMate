// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_themeSystem => 'System';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_sectionGeneral => 'General';

  @override
  String get settings_subMain => 'Main List';

  @override
  String get settings_subCurrency => 'Currency Calculator';

  @override
  String get settings_calculatorManagement => 'Calculator Management';

  @override
  String settings_calculatorCount(int count) {
    return '$count';
  }

  @override
  String get settings_baseCurrency => 'Base Currency';

  @override
  String get settings_bmiUnit => 'BMI Unit';

  @override
  String get settings_sectionAppInfo => 'App Info';

  @override
  String get settings_version => 'Version';

  @override
  String get settings_openSourceLicenses => 'Open Source Licenses';

  @override
  String settings_licenseCount(int count) {
    return '$count licenses';
  }

  @override
  String get settings_privacyPolicy => 'Privacy Policy';

  @override
  String get settings_displayCurrency => 'Display Currency';

  @override
  String get settings_displayCurrencyAuto => 'Auto (Device Region)';

  @override
  String get settings_currencyKRW => 'KRW (Won)';

  @override
  String get settings_currencyUSD => 'USD (Dollar)';

  @override
  String get settings_currencyEUR => 'EUR (Euro)';

  @override
  String get settings_currencyJPY => 'JPY (Yen)';

  @override
  String get settings_currencyCNY => 'CNY (Yuan)';

  @override
  String get settings_currencyGBP => 'GBP (Pound)';

  @override
  String get settings_currencyAUD => 'AUD (Australian Dollar)';

  @override
  String get settings_currencyCAD => 'CAD (Canadian Dollar)';

  @override
  String get settings_currencyCHF => 'CHF (Swiss Franc)';

  @override
  String get settings_currencyHKD => 'HKD (Hong Kong Dollar)';

  @override
  String get settings_bmiMetric => 'kg / cm';

  @override
  String get settings_bmiImperial => 'lb / in';

  @override
  String get settings_languageSystem => 'System Default';

  @override
  String get settings_languageKo => '한국어';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_calcManagement_title => 'Calculator Management';

  @override
  String get settings_calcManagement_description =>
      'Select calculators to display on the main screen.';

  @override
  String get settings_calcManagement_selectAll => 'Select All';

  @override
  String get settings_calcManagement_deselectAll => 'Deselect All';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_adLabel => 'Ad';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_next => 'Next';

  @override
  String get common_close => 'Close';

  @override
  String get common_share => 'Share';

  @override
  String get common_done => 'Done';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_add => 'Add';

  @override
  String get main_editOrder => 'Edit Order';

  @override
  String get main_done => 'Done';

  @override
  String get splash_tagline => 'All Calculations in Life';

  @override
  String get dutchPay_title => 'Split Bill';

  @override
  String get dutchPay_tab_equal => 'Equal';

  @override
  String get dutchPay_tab_individual => 'Individual';

  @override
  String get dutchPay_label_totalAmount => 'Total Amount';

  @override
  String get dutchPay_label_people => 'People';

  @override
  String get dutchPay_hint_plusButton => 'Use the + button to adjust';

  @override
  String get dutchPay_label_roundingUnit => 'Rounding';

  @override
  String get dutchPay_label_addTip => 'Add Tip';

  @override
  String get dutchPay_tip_none => 'None';

  @override
  String get dutchPay_tip_custom => 'Custom';

  @override
  String get dutchPay_hint_enterTotal => 'Enter total to see results';

  @override
  String get dutchPay_label_perPerson => 'Per Person';

  @override
  String dutchPay_label_participantCount(int count) {
    return '$count Participants';
  }

  @override
  String get dutchPay_label_organizer => 'Payer';

  @override
  String get dutchPay_button_shareResult => 'Share Result';

  @override
  String get dutchPay_label_members => 'Members';

  @override
  String get dutchPay_toast_maxMembers => 'Up to 10 members allowed';

  @override
  String get dutchPay_toast_minMember => 'At least 1 member required';

  @override
  String dutchPay_dialog_renameTitle(String name) {
    return 'Rename $name';
  }

  @override
  String get dutchPay_dialog_removeTitle => 'Remove Member';

  @override
  String dutchPay_dialog_removeContent(String name) {
    return '$name\'s items will also be removed.';
  }

  @override
  String dutchPay_hint_filterActive(String name) {
    return 'Highlighting $name · Tap to clear';
  }

  @override
  String get dutchPay_hint_tapRename => 'Tap → Rename';

  @override
  String get dutchPay_hint_longPressFilter => 'Long press → Highlight';

  @override
  String get dutchPay_label_result => 'Result';

  @override
  String get dutchPay_label_total => 'Total';

  @override
  String get dutchPay_label_tip => 'Tip';

  @override
  String get dutchPay_label_addItem => 'Add Item';

  @override
  String get dutchPay_label_editItem => 'Edit Item';

  @override
  String get dutchPay_hint_menuName => 'Item name';

  @override
  String get dutchPay_hint_amount => 'Amount';

  @override
  String get dutchPay_button_modify => 'Update';

  @override
  String get dutchPay_share_text => 'CalcMate Split Bill';

  @override
  String get dutchPay_error_share => 'Share error';

  @override
  String dutchPay_peopleCount(int count) {
    return '$count';
  }

  @override
  String get dutchPay_chip_100 => '₩100';

  @override
  String get dutchPay_chip_1000 => '₩1,000';

  @override
  String get vat_label_supplyAmount => 'Supply Amount';

  @override
  String get vat_label_total => 'Total';

  @override
  String get vat_label_vat => 'VAT';

  @override
  String get vat_label_totalAmount => 'Total Amount';

  @override
  String get vat_label_taxRateRef => 'Tax Rate Reference';

  @override
  String get salary_tab_monthly => 'Monthly';

  @override
  String get salary_tab_annual => 'Annual';

  @override
  String get salary_label_netPay => 'Take-home Pay';

  @override
  String get salary_label_annualNet => 'Annual Net';

  @override
  String get salary_label_annualEquiv => 'Annual Equiv.';

  @override
  String salary_sub_monthly(String amount, String unit) {
    return '$amount $unit/mo';
  }

  @override
  String get salary_label_deductionTotal => 'Total Deductions';

  @override
  String get salary_label_nationalPension => 'National Pension';

  @override
  String get salary_label_healthInsurance => 'Health Insurance';

  @override
  String get salary_label_longTermCare => 'Long-term Care';

  @override
  String get salary_label_employmentInsurance => 'Employment Insurance';

  @override
  String get salary_label_incomeTax => 'Income Tax';

  @override
  String get salary_label_localTax => 'Local Income Tax';

  @override
  String get salary_label_dependents => 'Dependents';

  @override
  String get salary_tooltip_dependents =>
      'Including yourself, used for income tax calculation';

  @override
  String get salary_slider_monthlyMin => '1M';

  @override
  String get salary_slider_monthlyMax => '10M';

  @override
  String get salary_slider_annualMin => '20M';

  @override
  String get salary_slider_annualMax => '300M';

  @override
  String salary_taxBasis_year(int year) {
    return 'Deductions are based on $year tax rates';
  }

  @override
  String salary_taxBasis_halfYear(int year) {
    return 'Deductions are based on $year H2 tax rates';
  }

  @override
  String get salary_loading => 'Loading tax rates...';

  @override
  String get discount_label_originalPrice => 'Original Price';

  @override
  String get discount_label_discountRate => 'Discount Rate';

  @override
  String get discount_label_savedAmount => 'Savings';

  @override
  String discount_label_effectiveRate(String rate) {
    return 'Effective Rate ($rate)';
  }

  @override
  String get discount_label_finalPrice => 'Final Price';

  @override
  String get discount_label_addExtra => 'Extra Discount';

  @override
  String get discount_label_removeExtra => 'Remove Extra';

  @override
  String get discount_label_extraRate => 'Extra Discount Rate';

  @override
  String get date_tab_period => 'Period';

  @override
  String get date_tab_dateCalc => 'Date Calc';

  @override
  String get date_tab_dday => 'D-Day';

  @override
  String get date_label_baseDateToday => 'Base Date (Today)';

  @override
  String get date_label_baseDate => 'Base Date';

  @override
  String get date_label_targetDate => 'Target Date';

  @override
  String get date_label_refDateToday => 'Ref. Date (Today)';

  @override
  String get date_label_refDate => 'Ref. Date';

  @override
  String get date_label_startDateToday => 'Start Date (Today)';

  @override
  String get date_label_startDate => 'Start Date';

  @override
  String get date_label_endDateToday => 'End Date (Today)';

  @override
  String get date_label_endDate => 'End Date';

  @override
  String get date_label_includeStartDay => 'Include Start Day';

  @override
  String get date_hint_includeStartDay => '(Recommended ON for anniversaries)';

  @override
  String get date_label_after => 'After';

  @override
  String get date_label_before => 'Before';

  @override
  String get date_label_today => 'Today';

  @override
  String get date_unit_day => 'Day';

  @override
  String get date_unit_week => 'Week';

  @override
  String get date_unit_month => 'Month';

  @override
  String get date_unit_year => 'Year';

  @override
  String get date_suffix_after => 'later';

  @override
  String get date_suffix_before => 'ago';

  @override
  String date_format_ymd(int year, int month, int day) {
    return '$month/$day/$year';
  }

  @override
  String date_format_year(int year) {
    return '$year';
  }

  @override
  String date_format_md(int month, int day) {
    return '$month/$day';
  }

  @override
  String date_desc_calcResult(
    String base,
    int number,
    String unit,
    String direction,
  ) {
    return '$number $unit $direction from $base';
  }

  @override
  String date_result_days(String count) {
    return '$count days';
  }

  @override
  String date_result_weeksAndDays(int weeks, int days) {
    return '${weeks}w ${days}d';
  }

  @override
  String date_result_monthsAndDays(int months, int days) {
    return '${months}mo ${days}d';
  }

  @override
  String date_result_yearsMonthsDays(int years, int months, int days) {
    return '${years}y ${months}mo ${days}d';
  }

  @override
  String date_unitDirection(String unit, String direction) {
    return '$unit $direction';
  }

  @override
  String get age_unit_years => 'yrs';

  @override
  String get age_label_countingAge => 'Counting Age';

  @override
  String get age_label_koreanAge => 'International Age';

  @override
  String get age_label_yearAge => 'Year Age';

  @override
  String get age_label_birthWeekday => 'Day of Birth';

  @override
  String age_value_years(int age) {
    return '$age yrs';
  }

  @override
  String get age_label_zodiac => 'Zodiac';

  @override
  String age_label_zodiacValue(String name) {
    return 'Year of the $name';
  }

  @override
  String get age_label_constellation => 'Constellation';

  @override
  String get age_label_birthdayToday => 'Happy Birthday!';

  @override
  String get age_label_nextBirthday => 'Next Birthday';

  @override
  String age_format_mdWeekday(int month, int day, String weekday) {
    return '$month/$day ($weekday)';
  }

  @override
  String get age_label_daysLived => 'Days Lived';

  @override
  String age_result_days(String count) {
    return '$count days';
  }

  @override
  String age_result_approxYearsMonths(int years, int months) {
    return '≈ ${years}y ${months}mo';
  }

  @override
  String age_result_approxYears(int years) {
    return '≈ ${years}y';
  }

  @override
  String get age_label_birthDate => 'Date of Birth';

  @override
  String get age_label_lunar => 'Lunar';

  @override
  String get age_label_solar => 'Solar';

  @override
  String get age_label_leapMonth => 'Leap Month';

  @override
  String age_label_asOf(String date) {
    return 'As of $date';
  }

  @override
  String get age_label_futureDate => 'Cannot calculate future dates';

  @override
  String age_picker_year(int year) {
    return '$year';
  }

  @override
  String age_picker_month(int month) {
    return '$month';
  }

  @override
  String age_picker_day(int day) {
    return '$day';
  }

  @override
  String get bmi_label_height => 'Height';

  @override
  String get bmi_label_weight => 'Weight';

  @override
  String get bmi_dialog_editHeight => 'Edit Height';

  @override
  String get bmi_dialog_editWeight => 'Edit Weight';

  @override
  String get bmi_standard_asian => 'WHO Asia-Pacific (Korean Obesity Society)';

  @override
  String get bmi_standard_global => 'WHO Global';

  @override
  String get bmi_label_healthyRange => 'Healthy Weight Range';

  @override
  String get bmi_label_inRange => 'Your weight is within the healthy range';

  @override
  String bmi_range_above(String min) {
    return '$min+';
  }

  @override
  String get currency_status_fallback => 'Using cached rates';

  @override
  String get currency_status_noRates => 'No rate data';

  @override
  String currency_label_asOf(String datetime) {
    return 'As of $datetime';
  }

  @override
  String get currency_loading => 'Loading exchange rates...';

  @override
  String get currency_search_hint => 'Search currency (USD, Dollar...)';

  @override
  String get currency_toast_baseCurrency => 'This is the base currency';

  @override
  String get currency_toast_alreadySelected => 'Currency already selected';

  @override
  String get common_am => 'AM';

  @override
  String get common_pm => 'PM';

  @override
  String get common_toast_integerExceeded => 'Up to 12 digits allowed';

  @override
  String get common_toast_fractionalExceeded =>
      'Up to 8 decimal places allowed';

  @override
  String get error_exchangeRateLoadFailed => 'Unable to load exchange rates';

  @override
  String get error_exchangeRateUsingFallback => 'Using cached exchange rates';

  @override
  String get ad_interstitialToast => 'An ad will be shown';

  @override
  String get ad_bannerNotAvailable => 'Ad not available';
}
