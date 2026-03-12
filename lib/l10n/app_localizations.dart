import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @settings_title.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings_title;

  /// No description provided for @settings_language.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settings_language;

  /// No description provided for @settings_theme.
  ///
  /// In ko, this message translates to:
  /// **'화면 테마'**
  String get settings_theme;

  /// No description provided for @settings_themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 기준'**
  String get settings_themeSystem;

  /// No description provided for @settings_themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get settings_themeLight;

  /// No description provided for @settings_themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get settings_themeDark;

  /// No description provided for @settings_sectionGeneral.
  ///
  /// In ko, this message translates to:
  /// **'일반'**
  String get settings_sectionGeneral;

  /// No description provided for @settings_calculatorManagement.
  ///
  /// In ko, this message translates to:
  /// **'계산기 관리'**
  String get settings_calculatorManagement;

  /// No description provided for @settings_calculatorCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개'**
  String settings_calculatorCount(int count);

  /// No description provided for @settings_baseCurrency.
  ///
  /// In ko, this message translates to:
  /// **'환율 기준 통화'**
  String get settings_baseCurrency;

  /// No description provided for @settings_bmiUnit.
  ///
  /// In ko, this message translates to:
  /// **'BMI 단위'**
  String get settings_bmiUnit;

  /// No description provided for @settings_sectionAppInfo.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보'**
  String get settings_sectionAppInfo;

  /// No description provided for @settings_version.
  ///
  /// In ko, this message translates to:
  /// **'버전 정보'**
  String get settings_version;

  /// No description provided for @settings_openSourceLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get settings_openSourceLicenses;

  /// No description provided for @settings_licenseCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개의 라이선스'**
  String settings_licenseCount(int count);

  /// No description provided for @settings_privacyPolicy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 처리방침'**
  String get settings_privacyPolicy;

  /// No description provided for @settings_displayCurrency.
  ///
  /// In ko, this message translates to:
  /// **'표시 통화'**
  String get settings_displayCurrency;

  /// No description provided for @settings_displayCurrencyAuto.
  ///
  /// In ko, this message translates to:
  /// **'자동 (기기 지역)'**
  String get settings_displayCurrencyAuto;

  /// No description provided for @settings_currencyKRW.
  ///
  /// In ko, this message translates to:
  /// **'KRW (원)'**
  String get settings_currencyKRW;

  /// No description provided for @settings_currencyUSD.
  ///
  /// In ko, this message translates to:
  /// **'USD (달러)'**
  String get settings_currencyUSD;

  /// No description provided for @settings_currencyEUR.
  ///
  /// In ko, this message translates to:
  /// **'EUR (유로)'**
  String get settings_currencyEUR;

  /// No description provided for @settings_currencyJPY.
  ///
  /// In ko, this message translates to:
  /// **'JPY (엔)'**
  String get settings_currencyJPY;

  /// No description provided for @settings_currencyCNY.
  ///
  /// In ko, this message translates to:
  /// **'CNY (위안)'**
  String get settings_currencyCNY;

  /// No description provided for @settings_currencyGBP.
  ///
  /// In ko, this message translates to:
  /// **'GBP (파운드)'**
  String get settings_currencyGBP;

  /// No description provided for @settings_currencyAUD.
  ///
  /// In ko, this message translates to:
  /// **'AUD (호주 달러)'**
  String get settings_currencyAUD;

  /// No description provided for @settings_currencyCAD.
  ///
  /// In ko, this message translates to:
  /// **'CAD (캐나다 달러)'**
  String get settings_currencyCAD;

  /// No description provided for @settings_currencyCHF.
  ///
  /// In ko, this message translates to:
  /// **'CHF (스위스 프랑)'**
  String get settings_currencyCHF;

  /// No description provided for @settings_currencyHKD.
  ///
  /// In ko, this message translates to:
  /// **'HKD (홍콩 달러)'**
  String get settings_currencyHKD;

  /// No description provided for @settings_bmiMetric.
  ///
  /// In ko, this message translates to:
  /// **'kg / cm'**
  String get settings_bmiMetric;

  /// No description provided for @settings_bmiImperial.
  ///
  /// In ko, this message translates to:
  /// **'lb / in'**
  String get settings_bmiImperial;

  /// No description provided for @settings_languageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 기본'**
  String get settings_languageSystem;

  /// No description provided for @settings_languageKo.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get settings_languageKo;

  /// No description provided for @settings_languageEn.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get settings_languageEn;

  /// No description provided for @settings_calcManagement_title.
  ///
  /// In ko, this message translates to:
  /// **'계산기 관리'**
  String get settings_calcManagement_title;

  /// No description provided for @settings_calcManagement_description.
  ///
  /// In ko, this message translates to:
  /// **'메인 화면에 표시할 계산기를 선택하세요.'**
  String get settings_calcManagement_description;

  /// No description provided for @settings_calcManagement_selectAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 선택'**
  String get settings_calcManagement_selectAll;

  /// No description provided for @settings_calcManagement_deselectAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 해제'**
  String get settings_calcManagement_deselectAll;

  /// No description provided for @common_confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get common_confirm;

  /// No description provided for @common_adLabel.
  ///
  /// In ko, this message translates to:
  /// **'광고'**
  String get common_adLabel;

  /// No description provided for @common_cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get common_delete;

  /// No description provided for @common_next.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get common_next;

  /// No description provided for @common_close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get common_close;

  /// No description provided for @common_share.
  ///
  /// In ko, this message translates to:
  /// **'공유하기'**
  String get common_share;

  /// No description provided for @common_done.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get common_done;

  /// No description provided for @common_edit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get common_edit;

  /// No description provided for @common_add.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get common_add;

  /// No description provided for @main_editOrder.
  ///
  /// In ko, this message translates to:
  /// **'순서 편집'**
  String get main_editOrder;

  /// No description provided for @main_done.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get main_done;

  /// No description provided for @splash_tagline.
  ///
  /// In ko, this message translates to:
  /// **'생활 속 모든 계산'**
  String get splash_tagline;

  /// No description provided for @dutchPay_title.
  ///
  /// In ko, this message translates to:
  /// **'더치페이'**
  String get dutchPay_title;

  /// No description provided for @dutchPay_tab_equal.
  ///
  /// In ko, this message translates to:
  /// **'N빵'**
  String get dutchPay_tab_equal;

  /// No description provided for @dutchPay_tab_individual.
  ///
  /// In ko, this message translates to:
  /// **'각출'**
  String get dutchPay_tab_individual;

  /// No description provided for @dutchPay_label_totalAmount.
  ///
  /// In ko, this message translates to:
  /// **'총 금액'**
  String get dutchPay_label_totalAmount;

  /// No description provided for @dutchPay_label_people.
  ///
  /// In ko, this message translates to:
  /// **'인원'**
  String get dutchPay_label_people;

  /// No description provided for @dutchPay_hint_plusButton.
  ///
  /// In ko, this message translates to:
  /// **'위 + 버튼으로 조절하세요'**
  String get dutchPay_hint_plusButton;

  /// No description provided for @dutchPay_label_roundingUnit.
  ///
  /// In ko, this message translates to:
  /// **'정산 단위'**
  String get dutchPay_label_roundingUnit;

  /// No description provided for @dutchPay_label_addTip.
  ///
  /// In ko, this message translates to:
  /// **'팁 추가'**
  String get dutchPay_label_addTip;

  /// No description provided for @dutchPay_tip_none.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get dutchPay_tip_none;

  /// No description provided for @dutchPay_tip_custom.
  ///
  /// In ko, this message translates to:
  /// **'직접입력'**
  String get dutchPay_tip_custom;

  /// No description provided for @dutchPay_hint_enterTotal.
  ///
  /// In ko, this message translates to:
  /// **'총액을 입력하면 결과가 표시돼요'**
  String get dutchPay_hint_enterTotal;

  /// No description provided for @dutchPay_label_perPerson.
  ///
  /// In ko, this message translates to:
  /// **'1인당'**
  String get dutchPay_label_perPerson;

  /// No description provided for @dutchPay_label_participantCount.
  ///
  /// In ko, this message translates to:
  /// **'참여자 {count}명'**
  String dutchPay_label_participantCount(int count);

  /// No description provided for @dutchPay_label_organizer.
  ///
  /// In ko, this message translates to:
  /// **'계산한 사람'**
  String get dutchPay_label_organizer;

  /// No description provided for @dutchPay_button_shareResult.
  ///
  /// In ko, this message translates to:
  /// **'결과 공유'**
  String get dutchPay_button_shareResult;

  /// No description provided for @dutchPay_label_members.
  ///
  /// In ko, this message translates to:
  /// **'참여인원'**
  String get dutchPay_label_members;

  /// No description provided for @dutchPay_toast_maxMembers.
  ///
  /// In ko, this message translates to:
  /// **'최대 10명까지 추가할 수 있어요'**
  String get dutchPay_toast_maxMembers;

  /// No description provided for @dutchPay_toast_minMember.
  ///
  /// In ko, this message translates to:
  /// **'최소 1명은 있어야 해요'**
  String get dutchPay_toast_minMember;

  /// No description provided for @dutchPay_dialog_renameTitle.
  ///
  /// In ko, this message translates to:
  /// **'{name} 이름 변경'**
  String dutchPay_dialog_renameTitle(String name);

  /// No description provided for @dutchPay_dialog_removeTitle.
  ///
  /// In ko, this message translates to:
  /// **'참여자 삭제'**
  String get dutchPay_dialog_removeTitle;

  /// No description provided for @dutchPay_dialog_removeContent.
  ///
  /// In ko, this message translates to:
  /// **'{name}의 메뉴가 함께 삭제됩니다.'**
  String dutchPay_dialog_removeContent(String name);

  /// No description provided for @dutchPay_hint_filterActive.
  ///
  /// In ko, this message translates to:
  /// **'{name} 강조 중  ·  탭하면 해제'**
  String dutchPay_hint_filterActive(String name);

  /// No description provided for @dutchPay_hint_tapRename.
  ///
  /// In ko, this message translates to:
  /// **'탭 → 이름 변경'**
  String get dutchPay_hint_tapRename;

  /// No description provided for @dutchPay_hint_longPressFilter.
  ///
  /// In ko, this message translates to:
  /// **'길게 누르기 → 항목 강조'**
  String get dutchPay_hint_longPressFilter;

  /// No description provided for @dutchPay_label_result.
  ///
  /// In ko, this message translates to:
  /// **'결과'**
  String get dutchPay_label_result;

  /// No description provided for @dutchPay_label_total.
  ///
  /// In ko, this message translates to:
  /// **'합계'**
  String get dutchPay_label_total;

  /// No description provided for @dutchPay_label_tip.
  ///
  /// In ko, this message translates to:
  /// **'팁'**
  String get dutchPay_label_tip;

  /// No description provided for @dutchPay_label_addItem.
  ///
  /// In ko, this message translates to:
  /// **'메뉴 추가'**
  String get dutchPay_label_addItem;

  /// No description provided for @dutchPay_label_editItem.
  ///
  /// In ko, this message translates to:
  /// **'메뉴 수정'**
  String get dutchPay_label_editItem;

  /// No description provided for @dutchPay_hint_menuName.
  ///
  /// In ko, this message translates to:
  /// **'메뉴명'**
  String get dutchPay_hint_menuName;

  /// No description provided for @dutchPay_hint_amount.
  ///
  /// In ko, this message translates to:
  /// **'금액'**
  String get dutchPay_hint_amount;

  /// No description provided for @dutchPay_button_modify.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get dutchPay_button_modify;

  /// No description provided for @dutchPay_share_text.
  ///
  /// In ko, this message translates to:
  /// **'CalcMate 더치페이 결과'**
  String get dutchPay_share_text;

  /// No description provided for @dutchPay_error_share.
  ///
  /// In ko, this message translates to:
  /// **'공유 오류'**
  String get dutchPay_error_share;

  /// No description provided for @dutchPay_peopleCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String dutchPay_peopleCount(int count);

  /// No description provided for @dutchPay_chip_100.
  ///
  /// In ko, this message translates to:
  /// **'100원'**
  String get dutchPay_chip_100;

  /// No description provided for @dutchPay_chip_1000.
  ///
  /// In ko, this message translates to:
  /// **'1,000원'**
  String get dutchPay_chip_1000;

  /// No description provided for @vat_label_supplyAmount.
  ///
  /// In ko, this message translates to:
  /// **'공급가액'**
  String get vat_label_supplyAmount;

  /// No description provided for @vat_label_total.
  ///
  /// In ko, this message translates to:
  /// **'합계'**
  String get vat_label_total;

  /// No description provided for @vat_label_vat.
  ///
  /// In ko, this message translates to:
  /// **'부가세'**
  String get vat_label_vat;

  /// No description provided for @vat_label_totalAmount.
  ///
  /// In ko, this message translates to:
  /// **'합계금액'**
  String get vat_label_totalAmount;

  /// No description provided for @vat_label_taxRateRef.
  ///
  /// In ko, this message translates to:
  /// **'세율 참고'**
  String get vat_label_taxRateRef;

  /// No description provided for @salary_tab_monthly.
  ///
  /// In ko, this message translates to:
  /// **'월급'**
  String get salary_tab_monthly;

  /// No description provided for @salary_tab_annual.
  ///
  /// In ko, this message translates to:
  /// **'연봉'**
  String get salary_tab_annual;

  /// No description provided for @salary_label_netPay.
  ///
  /// In ko, this message translates to:
  /// **'실수령액'**
  String get salary_label_netPay;

  /// No description provided for @salary_label_annualNet.
  ///
  /// In ko, this message translates to:
  /// **'연 실수령'**
  String get salary_label_annualNet;

  /// No description provided for @salary_label_annualEquiv.
  ///
  /// In ko, this message translates to:
  /// **'연 환산'**
  String get salary_label_annualEquiv;

  /// No description provided for @salary_sub_monthly.
  ///
  /// In ko, this message translates to:
  /// **'월 {amount} {unit}'**
  String salary_sub_monthly(String amount, String unit);

  /// No description provided for @salary_label_deductionTotal.
  ///
  /// In ko, this message translates to:
  /// **'공제 합계'**
  String get salary_label_deductionTotal;

  /// No description provided for @salary_label_nationalPension.
  ///
  /// In ko, this message translates to:
  /// **'국민연금'**
  String get salary_label_nationalPension;

  /// No description provided for @salary_label_healthInsurance.
  ///
  /// In ko, this message translates to:
  /// **'건강보험'**
  String get salary_label_healthInsurance;

  /// No description provided for @salary_label_longTermCare.
  ///
  /// In ko, this message translates to:
  /// **'장기요양'**
  String get salary_label_longTermCare;

  /// No description provided for @salary_label_employmentInsurance.
  ///
  /// In ko, this message translates to:
  /// **'고용보험'**
  String get salary_label_employmentInsurance;

  /// No description provided for @salary_label_incomeTax.
  ///
  /// In ko, this message translates to:
  /// **'소득세'**
  String get salary_label_incomeTax;

  /// No description provided for @salary_label_localTax.
  ///
  /// In ko, this message translates to:
  /// **'지방소득세'**
  String get salary_label_localTax;

  /// No description provided for @salary_label_dependents.
  ///
  /// In ko, this message translates to:
  /// **'부양가족 수'**
  String get salary_label_dependents;

  /// No description provided for @salary_tooltip_dependents.
  ///
  /// In ko, this message translates to:
  /// **'본인 포함 기준, 소득세 계산에 반영됩니다'**
  String get salary_tooltip_dependents;

  /// No description provided for @salary_slider_monthlyMin.
  ///
  /// In ko, this message translates to:
  /// **'100만'**
  String get salary_slider_monthlyMin;

  /// No description provided for @salary_slider_monthlyMax.
  ///
  /// In ko, this message translates to:
  /// **'1,000만'**
  String get salary_slider_monthlyMax;

  /// No description provided for @salary_slider_annualMin.
  ///
  /// In ko, this message translates to:
  /// **'2,000만'**
  String get salary_slider_annualMin;

  /// No description provided for @salary_slider_annualMax.
  ///
  /// In ko, this message translates to:
  /// **'3억'**
  String get salary_slider_annualMax;

  /// No description provided for @discount_label_originalPrice.
  ///
  /// In ko, this message translates to:
  /// **'원가'**
  String get discount_label_originalPrice;

  /// No description provided for @discount_label_discountRate.
  ///
  /// In ko, this message translates to:
  /// **'할인율'**
  String get discount_label_discountRate;

  /// No description provided for @discount_label_savedAmount.
  ///
  /// In ko, this message translates to:
  /// **'할인 금액'**
  String get discount_label_savedAmount;

  /// No description provided for @discount_label_effectiveRate.
  ///
  /// In ko, this message translates to:
  /// **'실질 할인율 ({rate})'**
  String discount_label_effectiveRate(String rate);

  /// No description provided for @discount_label_finalPrice.
  ///
  /// In ko, this message translates to:
  /// **'최종가'**
  String get discount_label_finalPrice;

  /// No description provided for @discount_label_addExtra.
  ///
  /// In ko, this message translates to:
  /// **'추가 할인'**
  String get discount_label_addExtra;

  /// No description provided for @discount_label_removeExtra.
  ///
  /// In ko, this message translates to:
  /// **'추가 할인 제거'**
  String get discount_label_removeExtra;

  /// No description provided for @discount_label_extraRate.
  ///
  /// In ko, this message translates to:
  /// **'추가 할인율'**
  String get discount_label_extraRate;

  /// No description provided for @date_tab_period.
  ///
  /// In ko, this message translates to:
  /// **'기간 계산'**
  String get date_tab_period;

  /// No description provided for @date_tab_dateCalc.
  ///
  /// In ko, this message translates to:
  /// **'날짜 계산'**
  String get date_tab_dateCalc;

  /// No description provided for @date_tab_dday.
  ///
  /// In ko, this message translates to:
  /// **'D-Day'**
  String get date_tab_dday;

  /// No description provided for @date_label_baseDateToday.
  ///
  /// In ko, this message translates to:
  /// **'기준 날짜 (오늘)'**
  String get date_label_baseDateToday;

  /// No description provided for @date_label_baseDate.
  ///
  /// In ko, this message translates to:
  /// **'기준 날짜'**
  String get date_label_baseDate;

  /// No description provided for @date_label_targetDate.
  ///
  /// In ko, this message translates to:
  /// **'목표 날짜'**
  String get date_label_targetDate;

  /// No description provided for @date_label_refDateToday.
  ///
  /// In ko, this message translates to:
  /// **'기준일 (오늘)'**
  String get date_label_refDateToday;

  /// No description provided for @date_label_refDate.
  ///
  /// In ko, this message translates to:
  /// **'기준일'**
  String get date_label_refDate;

  /// No description provided for @date_label_startDateToday.
  ///
  /// In ko, this message translates to:
  /// **'시작 날짜 (오늘)'**
  String get date_label_startDateToday;

  /// No description provided for @date_label_startDate.
  ///
  /// In ko, this message translates to:
  /// **'시작 날짜'**
  String get date_label_startDate;

  /// No description provided for @date_label_endDateToday.
  ///
  /// In ko, this message translates to:
  /// **'종료 날짜 (오늘)'**
  String get date_label_endDateToday;

  /// No description provided for @date_label_endDate.
  ///
  /// In ko, this message translates to:
  /// **'종료 날짜'**
  String get date_label_endDate;

  /// No description provided for @date_label_includeStartDay.
  ///
  /// In ko, this message translates to:
  /// **'시작일 포함'**
  String get date_label_includeStartDay;

  /// No description provided for @date_hint_includeStartDay.
  ///
  /// In ko, this message translates to:
  /// **'(기념일 계산 시 ON 권장)'**
  String get date_hint_includeStartDay;

  /// No description provided for @date_label_after.
  ///
  /// In ko, this message translates to:
  /// **'이후'**
  String get date_label_after;

  /// No description provided for @date_label_before.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get date_label_before;

  /// No description provided for @date_label_today.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get date_label_today;

  /// No description provided for @date_unit_day.
  ///
  /// In ko, this message translates to:
  /// **'일'**
  String get date_unit_day;

  /// No description provided for @date_unit_week.
  ///
  /// In ko, this message translates to:
  /// **'주'**
  String get date_unit_week;

  /// No description provided for @date_unit_month.
  ///
  /// In ko, this message translates to:
  /// **'개월'**
  String get date_unit_month;

  /// No description provided for @date_unit_year.
  ///
  /// In ko, this message translates to:
  /// **'년'**
  String get date_unit_year;

  /// No description provided for @date_suffix_after.
  ///
  /// In ko, this message translates to:
  /// **'후'**
  String get date_suffix_after;

  /// No description provided for @date_suffix_before.
  ///
  /// In ko, this message translates to:
  /// **'전'**
  String get date_suffix_before;

  /// No description provided for @date_format_ymd.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일'**
  String date_format_ymd(int year, int month, int day);

  /// No description provided for @date_format_year.
  ///
  /// In ko, this message translates to:
  /// **'{year}년'**
  String date_format_year(int year);

  /// No description provided for @date_format_md.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 {day}일'**
  String date_format_md(int month, int day);

  /// No description provided for @date_desc_calcResult.
  ///
  /// In ko, this message translates to:
  /// **'{base}부터  {number}{unit} {direction}'**
  String date_desc_calcResult(
    String base,
    int number,
    String unit,
    String direction,
  );

  /// No description provided for @date_result_days.
  ///
  /// In ko, this message translates to:
  /// **'{count}일'**
  String date_result_days(String count);

  /// No description provided for @date_result_weeksAndDays.
  ///
  /// In ko, this message translates to:
  /// **'{weeks}주 {days}일'**
  String date_result_weeksAndDays(int weeks, int days);

  /// No description provided for @date_result_monthsAndDays.
  ///
  /// In ko, this message translates to:
  /// **'{months}개월 {days}일'**
  String date_result_monthsAndDays(int months, int days);

  /// No description provided for @date_result_yearsMonthsDays.
  ///
  /// In ko, this message translates to:
  /// **'{years}년 {months}개월 {days}일'**
  String date_result_yearsMonthsDays(int years, int months, int days);

  /// No description provided for @date_unitDirection.
  ///
  /// In ko, this message translates to:
  /// **'{unit} {direction}'**
  String date_unitDirection(String unit, String direction);

  /// No description provided for @age_unit_years.
  ///
  /// In ko, this message translates to:
  /// **'세'**
  String get age_unit_years;

  /// No description provided for @age_label_countingAge.
  ///
  /// In ko, this message translates to:
  /// **'세는 나이'**
  String get age_label_countingAge;

  /// No description provided for @age_label_koreanAge.
  ///
  /// In ko, this message translates to:
  /// **'만 나이'**
  String get age_label_koreanAge;

  /// No description provided for @age_label_yearAge.
  ///
  /// In ko, this message translates to:
  /// **'연 나이'**
  String get age_label_yearAge;

  /// No description provided for @age_label_birthWeekday.
  ///
  /// In ko, this message translates to:
  /// **'태어난 요일'**
  String get age_label_birthWeekday;

  /// No description provided for @age_value_years.
  ///
  /// In ko, this message translates to:
  /// **'{age}세'**
  String age_value_years(int age);

  /// No description provided for @age_label_zodiac.
  ///
  /// In ko, this message translates to:
  /// **'띠'**
  String get age_label_zodiac;

  /// No description provided for @age_label_zodiacValue.
  ///
  /// In ko, this message translates to:
  /// **'{name}띠'**
  String age_label_zodiacValue(String name);

  /// No description provided for @age_label_constellation.
  ///
  /// In ko, this message translates to:
  /// **'별자리'**
  String get age_label_constellation;

  /// No description provided for @age_label_birthdayToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘이 생일이에요!'**
  String get age_label_birthdayToday;

  /// No description provided for @age_label_nextBirthday.
  ///
  /// In ko, this message translates to:
  /// **'다음 생일'**
  String get age_label_nextBirthday;

  /// No description provided for @age_format_mdWeekday.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 {day}일 ({weekday})'**
  String age_format_mdWeekday(int month, int day, String weekday);

  /// No description provided for @age_label_daysLived.
  ///
  /// In ko, this message translates to:
  /// **'살아온 날'**
  String get age_label_daysLived;

  /// No description provided for @age_result_days.
  ///
  /// In ko, this message translates to:
  /// **'{count}일'**
  String age_result_days(String count);

  /// No description provided for @age_result_approxYearsMonths.
  ///
  /// In ko, this message translates to:
  /// **'약 {years}년 {months}개월'**
  String age_result_approxYearsMonths(int years, int months);

  /// No description provided for @age_result_approxYears.
  ///
  /// In ko, this message translates to:
  /// **'약 {years}년'**
  String age_result_approxYears(int years);

  /// No description provided for @age_label_birthDate.
  ///
  /// In ko, this message translates to:
  /// **'생년월일'**
  String get age_label_birthDate;

  /// No description provided for @age_label_lunar.
  ///
  /// In ko, this message translates to:
  /// **'음력'**
  String get age_label_lunar;

  /// No description provided for @age_label_solar.
  ///
  /// In ko, this message translates to:
  /// **'양력'**
  String get age_label_solar;

  /// No description provided for @age_label_leapMonth.
  ///
  /// In ko, this message translates to:
  /// **'윤달'**
  String get age_label_leapMonth;

  /// No description provided for @age_label_asOf.
  ///
  /// In ko, this message translates to:
  /// **'{date} 기준'**
  String age_label_asOf(String date);

  /// No description provided for @age_label_futureDate.
  ///
  /// In ko, this message translates to:
  /// **'미래 날짜는 계산할 수 없어요'**
  String get age_label_futureDate;

  /// No description provided for @age_picker_year.
  ///
  /// In ko, this message translates to:
  /// **'{year}년'**
  String age_picker_year(int year);

  /// No description provided for @age_picker_month.
  ///
  /// In ko, this message translates to:
  /// **'{month}월'**
  String age_picker_month(int month);

  /// No description provided for @age_picker_day.
  ///
  /// In ko, this message translates to:
  /// **'{day}일'**
  String age_picker_day(int day);

  /// No description provided for @bmi_label_height.
  ///
  /// In ko, this message translates to:
  /// **'키'**
  String get bmi_label_height;

  /// No description provided for @bmi_label_weight.
  ///
  /// In ko, this message translates to:
  /// **'몸무게'**
  String get bmi_label_weight;

  /// No description provided for @bmi_dialog_editHeight.
  ///
  /// In ko, this message translates to:
  /// **'키 입력'**
  String get bmi_dialog_editHeight;

  /// No description provided for @bmi_dialog_editWeight.
  ///
  /// In ko, this message translates to:
  /// **'몸무게 입력'**
  String get bmi_dialog_editWeight;

  /// No description provided for @bmi_standard_asian.
  ///
  /// In ko, this message translates to:
  /// **'WHO 아시아태평양 기준 (대한비만학회 준용)'**
  String get bmi_standard_asian;

  /// No description provided for @bmi_standard_global.
  ///
  /// In ko, this message translates to:
  /// **'WHO 글로벌 기준'**
  String get bmi_standard_global;

  /// No description provided for @bmi_label_healthyRange.
  ///
  /// In ko, this message translates to:
  /// **'건강 체중 범위'**
  String get bmi_label_healthyRange;

  /// No description provided for @bmi_label_inRange.
  ///
  /// In ko, this message translates to:
  /// **'현재 체중이 건강 범위 안에 있습니다'**
  String get bmi_label_inRange;

  /// No description provided for @bmi_range_above.
  ///
  /// In ko, this message translates to:
  /// **'{min} 이상'**
  String bmi_range_above(String min);

  /// No description provided for @currency_status_fallback.
  ///
  /// In ko, this message translates to:
  /// **'임시 환율 사용 중'**
  String get currency_status_fallback;

  /// No description provided for @currency_status_noRates.
  ///
  /// In ko, this message translates to:
  /// **'환율 정보 없음'**
  String get currency_status_noRates;

  /// No description provided for @currency_label_asOf.
  ///
  /// In ko, this message translates to:
  /// **'{datetime} 기준'**
  String currency_label_asOf(String datetime);

  /// No description provided for @currency_loading.
  ///
  /// In ko, this message translates to:
  /// **'환율 정보를 가져오는 중...'**
  String get currency_loading;

  /// No description provided for @currency_search_hint.
  ///
  /// In ko, this message translates to:
  /// **'통화 검색 (USD, 달러...)'**
  String get currency_search_hint;

  /// No description provided for @currency_toast_baseCurrency.
  ///
  /// In ko, this message translates to:
  /// **'기준 통화로 사용 중입니다'**
  String get currency_toast_baseCurrency;

  /// No description provided for @currency_toast_alreadySelected.
  ///
  /// In ko, this message translates to:
  /// **'이미 선택된 통화입니다'**
  String get currency_toast_alreadySelected;

  /// No description provided for @common_am.
  ///
  /// In ko, this message translates to:
  /// **'오전'**
  String get common_am;

  /// No description provided for @common_pm.
  ///
  /// In ko, this message translates to:
  /// **'오후'**
  String get common_pm;

  /// No description provided for @common_toast_integerExceeded.
  ///
  /// In ko, this message translates to:
  /// **'최대 12자리까지 입력 가능합니다'**
  String get common_toast_integerExceeded;

  /// No description provided for @common_toast_fractionalExceeded.
  ///
  /// In ko, this message translates to:
  /// **'소수점 이하 8자리까지 입력 가능합니다'**
  String get common_toast_fractionalExceeded;

  /// No description provided for @error_exchangeRateLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'환율 정보를 불러올 수 없습니다'**
  String get error_exchangeRateLoadFailed;

  /// No description provided for @error_exchangeRateUsingFallback.
  ///
  /// In ko, this message translates to:
  /// **'임시 환율을 사용 중입니다'**
  String get error_exchangeRateUsingFallback;

  /// No description provided for @ad_interstitialToast.
  ///
  /// In ko, this message translates to:
  /// **'광고가 표시됩니다'**
  String get ad_interstitialToast;

  /// No description provided for @ad_bannerNotAvailable.
  ///
  /// In ko, this message translates to:
  /// **'광고를 불러올 수 없습니다'**
  String get ad_bannerNotAvailable;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
