// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get settings_title => '설정';

  @override
  String get settings_language => '언어';

  @override
  String get settings_theme => '화면 테마';

  @override
  String get settings_themeSystem => '시스템 기준';

  @override
  String get settings_themeLight => '라이트';

  @override
  String get settings_themeDark => '다크';

  @override
  String get settings_sectionGeneral => '일반';

  @override
  String get settings_calculatorManagement => '계산기 관리';

  @override
  String settings_calculatorCount(int count) {
    return '$count개';
  }

  @override
  String get settings_baseCurrency => '환율 기준 통화';

  @override
  String get settings_bmiUnit => 'BMI 단위';

  @override
  String get settings_sectionAppInfo => '앱 정보';

  @override
  String get settings_version => '버전 정보';

  @override
  String get settings_openSourceLicenses => '오픈소스 라이선스';

  @override
  String settings_licenseCount(int count) {
    return '$count개의 라이선스';
  }

  @override
  String get settings_privacyPolicy => '개인정보 처리방침';

  @override
  String get settings_displayCurrency => '표시 통화';

  @override
  String get settings_displayCurrencyAuto => '자동 (기기 지역)';

  @override
  String get settings_currencyKRW => 'KRW (원)';

  @override
  String get settings_currencyUSD => 'USD (달러)';

  @override
  String get settings_currencyEUR => 'EUR (유로)';

  @override
  String get settings_currencyJPY => 'JPY (엔)';

  @override
  String get settings_currencyCNY => 'CNY (위안)';

  @override
  String get settings_currencyGBP => 'GBP (파운드)';

  @override
  String get settings_currencyAUD => 'AUD (호주 달러)';

  @override
  String get settings_currencyCAD => 'CAD (캐나다 달러)';

  @override
  String get settings_currencyCHF => 'CHF (스위스 프랑)';

  @override
  String get settings_currencyHKD => 'HKD (홍콩 달러)';

  @override
  String get settings_bmiMetric => 'kg / cm';

  @override
  String get settings_bmiImperial => 'lb / in';

  @override
  String get settings_languageSystem => '시스템 기본';

  @override
  String get settings_languageKo => '한국어';

  @override
  String get settings_languageEn => 'English';

  @override
  String get settings_calcManagement_title => '계산기 관리';

  @override
  String get settings_calcManagement_description => '메인 화면에 표시할 계산기를 선택하세요.';

  @override
  String get settings_calcManagement_selectAll => '전체 선택';

  @override
  String get settings_calcManagement_deselectAll => '전체 해제';

  @override
  String get common_confirm => '확인';

  @override
  String get common_adLabel => '광고';

  @override
  String get common_cancel => '취소';

  @override
  String get common_delete => '삭제';

  @override
  String get common_next => '다음';

  @override
  String get common_close => '닫기';

  @override
  String get common_share => '공유하기';

  @override
  String get common_done => '완료';

  @override
  String get common_edit => '편집';

  @override
  String get common_add => '추가';

  @override
  String get main_editOrder => '순서 편집';

  @override
  String get main_done => '완료';

  @override
  String get splash_tagline => '생활 속 모든 계산';

  @override
  String get dutchPay_title => '더치페이';

  @override
  String get dutchPay_tab_equal => 'N빵';

  @override
  String get dutchPay_tab_individual => '각출';

  @override
  String get dutchPay_label_totalAmount => '총 금액';

  @override
  String get dutchPay_label_people => '인원';

  @override
  String get dutchPay_hint_plusButton => '위 + 버튼으로 조절하세요';

  @override
  String get dutchPay_label_roundingUnit => '정산 단위';

  @override
  String get dutchPay_label_addTip => '팁 추가';

  @override
  String get dutchPay_tip_none => '없음';

  @override
  String get dutchPay_tip_custom => '직접입력';

  @override
  String get dutchPay_hint_enterTotal => '총액을 입력하면 결과가 표시돼요';

  @override
  String get dutchPay_label_perPerson => '1인당';

  @override
  String dutchPay_label_participantCount(int count) {
    return '참여자 $count명';
  }

  @override
  String get dutchPay_label_organizer => '계산한 사람';

  @override
  String get dutchPay_button_shareResult => '결과 공유';

  @override
  String get dutchPay_label_members => '참여인원';

  @override
  String get dutchPay_toast_maxMembers => '최대 10명까지 추가할 수 있어요';

  @override
  String get dutchPay_toast_minMember => '최소 1명은 있어야 해요';

  @override
  String dutchPay_dialog_renameTitle(String name) {
    return '$name 이름 변경';
  }

  @override
  String get dutchPay_dialog_removeTitle => '참여자 삭제';

  @override
  String dutchPay_dialog_removeContent(String name) {
    return '$name의 메뉴가 함께 삭제됩니다.';
  }

  @override
  String dutchPay_hint_filterActive(String name) {
    return '$name 강조 중  ·  탭하면 해제';
  }

  @override
  String get dutchPay_hint_tapRename => '탭 → 이름 변경';

  @override
  String get dutchPay_hint_longPressFilter => '길게 누르기 → 항목 강조';

  @override
  String get dutchPay_label_result => '결과';

  @override
  String get dutchPay_label_total => '합계';

  @override
  String get dutchPay_label_tip => '팁';

  @override
  String get dutchPay_label_addItem => '메뉴 추가';

  @override
  String get dutchPay_label_editItem => '메뉴 수정';

  @override
  String get dutchPay_hint_menuName => '메뉴명';

  @override
  String get dutchPay_hint_amount => '금액';

  @override
  String get dutchPay_button_modify => '수정';

  @override
  String get dutchPay_share_text => 'CalcMate 더치페이 결과';

  @override
  String get dutchPay_error_share => '공유 오류';

  @override
  String dutchPay_peopleCount(int count) {
    return '$count명';
  }

  @override
  String get dutchPay_chip_100 => '100원';

  @override
  String get dutchPay_chip_1000 => '1,000원';

  @override
  String get vat_label_supplyAmount => '공급가액';

  @override
  String get vat_label_total => '합계';

  @override
  String get vat_label_vat => '부가세';

  @override
  String get vat_label_totalAmount => '합계금액';

  @override
  String get vat_label_taxRateRef => '세율 참고';

  @override
  String get salary_tab_monthly => '월급';

  @override
  String get salary_tab_annual => '연봉';

  @override
  String get salary_label_netPay => '실수령액';

  @override
  String get salary_label_annualNet => '연 실수령';

  @override
  String get salary_label_annualEquiv => '연 환산';

  @override
  String salary_sub_monthly(String amount, String unit) {
    return '월 $amount $unit';
  }

  @override
  String get salary_label_deductionTotal => '공제 합계';

  @override
  String get salary_label_nationalPension => '국민연금';

  @override
  String get salary_label_healthInsurance => '건강보험';

  @override
  String get salary_label_longTermCare => '장기요양';

  @override
  String get salary_label_employmentInsurance => '고용보험';

  @override
  String get salary_label_incomeTax => '소득세';

  @override
  String get salary_label_localTax => '지방소득세';

  @override
  String get salary_label_dependents => '부양가족 수';

  @override
  String get salary_tooltip_dependents => '본인 포함 기준, 소득세 계산에 반영됩니다';

  @override
  String get salary_slider_monthlyMin => '100만';

  @override
  String get salary_slider_monthlyMax => '1,000만';

  @override
  String get salary_slider_annualMin => '2,000만';

  @override
  String get salary_slider_annualMax => '3억';

  @override
  String get discount_label_originalPrice => '원가';

  @override
  String get discount_label_discountRate => '할인율';

  @override
  String get discount_label_savedAmount => '할인 금액';

  @override
  String discount_label_effectiveRate(String rate) {
    return '실질 할인율 ($rate)';
  }

  @override
  String get discount_label_finalPrice => '최종가';

  @override
  String get discount_label_addExtra => '추가 할인';

  @override
  String get discount_label_removeExtra => '추가 할인 제거';

  @override
  String get discount_label_extraRate => '추가 할인율';

  @override
  String get date_tab_period => '기간 계산';

  @override
  String get date_tab_dateCalc => '날짜 계산';

  @override
  String get date_tab_dday => 'D-Day';

  @override
  String get date_label_baseDateToday => '기준 날짜 (오늘)';

  @override
  String get date_label_baseDate => '기준 날짜';

  @override
  String get date_label_targetDate => '목표 날짜';

  @override
  String get date_label_refDateToday => '기준일 (오늘)';

  @override
  String get date_label_refDate => '기준일';

  @override
  String get date_label_startDateToday => '시작 날짜 (오늘)';

  @override
  String get date_label_startDate => '시작 날짜';

  @override
  String get date_label_endDateToday => '종료 날짜 (오늘)';

  @override
  String get date_label_endDate => '종료 날짜';

  @override
  String get date_label_includeStartDay => '시작일 포함';

  @override
  String get date_hint_includeStartDay => '(기념일 계산 시 ON 권장)';

  @override
  String get date_label_after => '이후';

  @override
  String get date_label_before => '이전';

  @override
  String get date_label_today => '오늘';

  @override
  String get date_unit_day => '일';

  @override
  String get date_unit_week => '주';

  @override
  String get date_unit_month => '개월';

  @override
  String get date_unit_year => '년';

  @override
  String get date_suffix_after => '후';

  @override
  String get date_suffix_before => '전';

  @override
  String date_format_ymd(int year, int month, int day) {
    return '$year년 $month월 $day일';
  }

  @override
  String date_format_year(int year) {
    return '$year년';
  }

  @override
  String date_format_md(int month, int day) {
    return '$month월 $day일';
  }

  @override
  String date_desc_calcResult(
    String base,
    int number,
    String unit,
    String direction,
  ) {
    return '$base부터  $number$unit $direction';
  }

  @override
  String date_result_days(String count) {
    return '$count일';
  }

  @override
  String date_result_weeksAndDays(int weeks, int days) {
    return '$weeks주 $days일';
  }

  @override
  String date_result_monthsAndDays(int months, int days) {
    return '$months개월 $days일';
  }

  @override
  String date_result_yearsMonthsDays(int years, int months, int days) {
    return '$years년 $months개월 $days일';
  }

  @override
  String date_unitDirection(String unit, String direction) {
    return '$unit $direction';
  }

  @override
  String get age_unit_years => '세';

  @override
  String get age_label_countingAge => '세는 나이';

  @override
  String get age_label_koreanAge => '만 나이';

  @override
  String get age_label_yearAge => '연 나이';

  @override
  String get age_label_birthWeekday => '태어난 요일';

  @override
  String age_value_years(int age) {
    return '$age세';
  }

  @override
  String get age_label_zodiac => '띠';

  @override
  String age_label_zodiacValue(String name) {
    return '$name띠';
  }

  @override
  String get age_label_constellation => '별자리';

  @override
  String get age_label_birthdayToday => '오늘이 생일이에요!';

  @override
  String get age_label_nextBirthday => '다음 생일';

  @override
  String age_format_mdWeekday(int month, int day, String weekday) {
    return '$month월 $day일 ($weekday)';
  }

  @override
  String get age_label_daysLived => '살아온 날';

  @override
  String age_result_days(String count) {
    return '$count일';
  }

  @override
  String age_result_approxYearsMonths(int years, int months) {
    return '약 $years년 $months개월';
  }

  @override
  String age_result_approxYears(int years) {
    return '약 $years년';
  }

  @override
  String get age_label_birthDate => '생년월일';

  @override
  String get age_label_lunar => '음력';

  @override
  String get age_label_solar => '양력';

  @override
  String get age_label_leapMonth => '윤달';

  @override
  String age_label_asOf(String date) {
    return '$date 기준';
  }

  @override
  String get age_label_futureDate => '미래 날짜는 계산할 수 없어요';

  @override
  String age_picker_year(int year) {
    return '$year년';
  }

  @override
  String age_picker_month(int month) {
    return '$month월';
  }

  @override
  String age_picker_day(int day) {
    return '$day일';
  }

  @override
  String get bmi_label_height => '키';

  @override
  String get bmi_label_weight => '몸무게';

  @override
  String get bmi_dialog_editHeight => '키 입력';

  @override
  String get bmi_dialog_editWeight => '몸무게 입력';

  @override
  String get bmi_standard_asian => 'WHO 아시아태평양 기준 (대한비만학회 준용)';

  @override
  String get bmi_standard_global => 'WHO 글로벌 기준';

  @override
  String get bmi_label_healthyRange => '건강 체중 범위';

  @override
  String get bmi_label_inRange => '현재 체중이 건강 범위 안에 있습니다';

  @override
  String bmi_range_above(String min) {
    return '$min 이상';
  }

  @override
  String get currency_status_fallback => '임시 환율 사용 중';

  @override
  String get currency_status_noRates => '환율 정보 없음';

  @override
  String currency_label_asOf(String datetime) {
    return '$datetime 기준';
  }

  @override
  String get currency_loading => '환율 정보를 가져오는 중...';

  @override
  String get currency_search_hint => '통화 검색 (USD, 달러...)';

  @override
  String get currency_toast_baseCurrency => '기준 통화로 사용 중입니다';

  @override
  String get currency_toast_alreadySelected => '이미 선택된 통화입니다';

  @override
  String get common_am => '오전';

  @override
  String get common_pm => '오후';

  @override
  String get common_toast_integerExceeded => '최대 12자리까지 입력 가능합니다';

  @override
  String get common_toast_fractionalExceeded => '소수점 이하 8자리까지 입력 가능합니다';

  @override
  String get error_exchangeRateLoadFailed => '환율 정보를 불러올 수 없습니다';

  @override
  String get error_exchangeRateUsingFallback => '임시 환율을 사용 중입니다';
}
