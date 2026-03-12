import 'dart:ui';

/// 데이터성 문자열의 로케일별 번역을 제공하는 유틸.
///
/// arb에 넣기엔 수량이 많고(120+), 코드 기반 조회가 필요한 항목들을 관리한다.
/// - 단위 라벨 73개, 카테고리 이름 10개, 통화 이름 24개, 계산기 타이틀/설명 20개
abstract final class DataStrings {
  /// 단위 라벨 조회. 예: `unitLabel('km', Locale('en'))` → `'Kilometer'`
  static String unitLabel(String code, Locale locale) =>
      _pick(_unitLabels, code, locale);

  /// 단위 카테고리 이름 조회.
  static String categoryName(String code, Locale locale) =>
      _pick(_categoryNames, code, locale);

  /// 통화 이름 조회. 예: `currencyName('USD', Locale('en'))` → `'US Dollar'`
  static String currencyName(String code, Locale locale) =>
      _pick(_currencyNames, code, locale);

  /// 계산기 타이틀 조회. 예: `calcTitle('basic_calculator', Locale('en'))` → `'Calculator'`
  static String calcTitle(String id, Locale locale) =>
      _pick(_calcTitles, id, locale);

  /// 계산기 설명 조회.
  static String calcDescription(String id, Locale locale) =>
      _pick(_calcDescriptions, id, locale);

  /// 부가세 세율표 조회.
  static List<(String, String, String, String)> vatTaxRates(Locale locale) =>
      locale.languageCode == 'ko' ? _vatTaxRatesKo : _vatTaxRatesEn;

  // ── 내부 헬퍼 ──

  static String _pick(
    Map<String, Map<String, String>> table,
    String code,
    Locale locale,
  ) {
    final lang = locale.languageCode;
    return table[lang]?[code] ?? table['ko']![code] ?? code;
  }

  // ──────────────────────────────────────────
  // 부가세 세율표 (18개)
  // ──────────────────────────────────────────
  static const _vatTaxRatesKo = [
    ('KR', '대한민국', '부가가치세', '10%'),
    ('JP', '일본', '소비세 (일반)', '10%'),
    ('JP', '일본', '소비세 (경감세율)', '8%'),
    ('GB', '영국', 'VAT (표준)', '20%'),
    ('GB', '영국', 'VAT (경감)', '5%'),
    ('DE', '독일', 'VAT (표준)', '19%'),
    ('DE', '독일', 'VAT (경감)', '7%'),
    ('FR', '프랑스', 'VAT (표준)', '20%'),
    ('IT', '이탈리아', 'VAT (표준)', '22%'),
    ('ES', '스페인', 'VAT (표준)', '21%'),
    ('AU', '호주', 'GST', '10%'),
    ('CA', '캐나다', 'GST', '5%'),
    ('NZ', '뉴질랜드', 'GST', '15%'),
    ('SG', '싱가포르', 'GST', '9%'),
    ('IN', '인도', 'GST (표준)', '18%'),
    ('CN', '중국', 'VAT (일반)', '13%'),
    ('BR', '브라질', 'ICMS (일반)', '17%'),
    ('US', '미국', 'Sales Tax', '주마다 상이'),
  ];

  static const _vatTaxRatesEn = [
    ('KR', 'South Korea', 'VAT', '10%'),
    ('JP', 'Japan', 'Consumption Tax (Standard)', '10%'),
    ('JP', 'Japan', 'Consumption Tax (Reduced)', '8%'),
    ('GB', 'United Kingdom', 'VAT (Standard)', '20%'),
    ('GB', 'United Kingdom', 'VAT (Reduced)', '5%'),
    ('DE', 'Germany', 'VAT (Standard)', '19%'),
    ('DE', 'Germany', 'VAT (Reduced)', '7%'),
    ('FR', 'France', 'VAT (Standard)', '20%'),
    ('IT', 'Italy', 'VAT (Standard)', '22%'),
    ('ES', 'Spain', 'VAT (Standard)', '21%'),
    ('AU', 'Australia', 'GST', '10%'),
    ('CA', 'Canada', 'GST', '5%'),
    ('NZ', 'New Zealand', 'GST', '15%'),
    ('SG', 'Singapore', 'GST', '9%'),
    ('IN', 'India', 'GST (Standard)', '18%'),
    ('CN', 'China', 'VAT (General)', '13%'),
    ('BR', 'Brazil', 'ICMS (General)', '17%'),
    ('US', 'United States', 'Sales Tax', 'Varies by state'),
  ];

  // ──────────────────────────────────────────
  // 카테고리 이름 (10개)
  // ──────────────────────────────────────────
  static const _categoryNames = {
    'ko': {
      'length': '길이',
      'mass': '질량',
      'temperature': '온도',
      'area': '넓이',
      'time': '시간',
      'volume': '부피',
      'speed': '속도',
      'fuelEfficiency': '연비',
      'data': '데이터',
      'pressure': '압력',
    },
    'en': {
      'length': 'Length',
      'mass': 'Mass',
      'temperature': 'Temperature',
      'area': 'Area',
      'time': 'Time',
      'volume': 'Volume',
      'speed': 'Speed',
      'fuelEfficiency': 'Fuel Efficiency',
      'data': 'Data',
      'pressure': 'Pressure',
    },
  };

  // ──────────────────────────────────────────
  // 단위 라벨 (73개)
  // ──────────────────────────────────────────
  static const _unitLabels = {
    'ko': {
      // 길이
      'mm': '밀리미터', 'cm': '센티미터', 'm': '미터', 'km': '킬로미터',
      'in': '인치', 'ft': '피트', 'yd': '야드', 'mi': '마일',
      // 질량
      'mg': '밀리그램', 'g': '그램', 'kg': '킬로그램', 't': '톤',
      'oz': '온스', 'lb': '파운드',
      // 온도
      '°C': '섭씨', '°F': '화씨', 'K': '켈빈',
      // 넓이
      'mm²': '제곱밀리미터', 'cm²': '제곱센티미터', 'm²': '제곱미터',
      'km²': '제곱킬로미터', 'ha': '헥타르', 'ac': '에이커',
      'ft²': '제곱피트', '평': '평',
      // 시간
      'ms': '밀리초', 's': '초', 'min': '분', 'h': '시간',
      'day': '일', 'week': '주', 'month': '개월', 'year': '년',
      // 부피
      'mL': '밀리리터', 'L': '리터', 'm³': '세제곱미터',
      'gal': '갤런(US)', 'qt': '쿼트(US)', 'pt': '파인트(US)',
      'fl oz': '액량온스(US)', 'cup': '컵(US)',
      // 속도
      'm/s': '미터/초', 'km/h': '킬로미터/시', 'mph': '마일/시',
      'kn': '노트', 'ft/s': '피트/초',
      // 연비
      'km/L': '킬로미터/리터', 'L/100km': '리터/100킬로미터',
      'mpg(US)': '마일/갤런(US)', 'mpg(UK)': '마일/갤런(UK)',
      // 데이터
      'bit': '비트', 'B': '바이트', 'KB': '킬로바이트',
      'MB': '메가바이트', 'GB': '기가바이트', 'TB': '테라바이트',
      'PB': '페타바이트',
      // 압력
      'Pa': '파스칼', 'kPa': '킬로파스칼', 'MPa': '메가파스칼',
      'bar': '바', 'atm': '기압', 'mmHg': '수은주밀리미터',
      'psi': '제곱인치당파운드',
    },
    'en': {
      // 길이
      'mm': 'Millimeter', 'cm': 'Centimeter', 'm': 'Meter', 'km': 'Kilometer',
      'in': 'Inch', 'ft': 'Foot', 'yd': 'Yard', 'mi': 'Mile',
      // 질량
      'mg': 'Milligram', 'g': 'Gram', 'kg': 'Kilogram', 't': 'Ton',
      'oz': 'Ounce', 'lb': 'Pound',
      // 온도
      '°C': 'Celsius', '°F': 'Fahrenheit', 'K': 'Kelvin',
      // 넓이
      'mm²': 'Square Millimeter', 'cm²': 'Square Centimeter',
      'm²': 'Square Meter', 'km²': 'Square Kilometer',
      'ha': 'Hectare', 'ac': 'Acre', 'ft²': 'Square Foot', '평': 'Pyeong',
      // 시간
      'ms': 'Millisecond', 's': 'Second', 'min': 'Minute', 'h': 'Hour',
      'day': 'Day', 'week': 'Week', 'month': 'Month', 'year': 'Year',
      // 부피
      'mL': 'Milliliter', 'L': 'Liter', 'm³': 'Cubic Meter',
      'gal': 'Gallon (US)', 'qt': 'Quart (US)', 'pt': 'Pint (US)',
      'fl oz': 'Fluid Ounce (US)', 'cup': 'Cup (US)',
      // 속도
      'm/s': 'Meter/sec', 'km/h': 'Kilometer/hr', 'mph': 'Mile/hr',
      'kn': 'Knot', 'ft/s': 'Foot/sec',
      // 연비
      'km/L': 'Kilometer/Liter', 'L/100km': 'Liter/100km',
      'mpg(US)': 'MPG (US)', 'mpg(UK)': 'MPG (UK)',
      // 데이터
      'bit': 'Bit', 'B': 'Byte', 'KB': 'Kilobyte',
      'MB': 'Megabyte', 'GB': 'Gigabyte', 'TB': 'Terabyte',
      'PB': 'Petabyte',
      // 압력
      'Pa': 'Pascal', 'kPa': 'Kilopascal', 'MPa': 'Megapascal',
      'bar': 'Bar', 'atm': 'Atmosphere', 'mmHg': 'mmHg',
      'psi': 'PSI',
    },
  };

  // ──────────────────────────────────────────
  // 통화 이름 (24개)
  // ──────────────────────────────────────────
  static const _currencyNames = {
    'ko': {
      'KRW': '대한민국 원', 'USD': '미국 달러', 'JPY': '일본 엔',
      'EUR': '유로', 'CNY': '중국 위안', 'GBP': '영국 파운드',
      'AUD': '호주 달러', 'CAD': '캐나다 달러', 'CHF': '스위스 프랑',
      'HKD': '홍콩 달러', 'SGD': '싱가포르 달러', 'TWD': '대만 달러',
      'THB': '태국 바트', 'VND': '베트남 동', 'PHP': '필리핀 페소',
      'INR': '인도 루피', 'MXN': '멕시코 페소', 'BRL': '브라질 레알',
      'SEK': '스웨덴 크로나', 'NOK': '노르웨이 크로네',
      'NZD': '뉴질랜드 달러', 'TRY': '터키 리라',
      'RUB': '러시아 루블', 'ZAR': '남아공 랜드',
    },
    'en': {
      'KRW': 'South Korean Won', 'USD': 'US Dollar', 'JPY': 'Japanese Yen',
      'EUR': 'Euro', 'CNY': 'Chinese Yuan', 'GBP': 'British Pound',
      'AUD': 'Australian Dollar', 'CAD': 'Canadian Dollar',
      'CHF': 'Swiss Franc', 'HKD': 'Hong Kong Dollar',
      'SGD': 'Singapore Dollar', 'TWD': 'New Taiwan Dollar',
      'THB': 'Thai Baht', 'VND': 'Vietnamese Dong',
      'PHP': 'Philippine Peso', 'INR': 'Indian Rupee',
      'MXN': 'Mexican Peso', 'BRL': 'Brazilian Real',
      'SEK': 'Swedish Krona', 'NOK': 'Norwegian Krone',
      'NZD': 'New Zealand Dollar', 'TRY': 'Turkish Lira',
      'RUB': 'Russian Ruble', 'ZAR': 'South African Rand',
    },
  };

  // ──────────────────────────────────────────
  // 계산기 타이틀 (10개)
  // ──────────────────────────────────────────
  static const _calcTitles = {
    'ko': {
      'basic_calculator': '기본 계산기',
      'exchange_rate': '환율 계산기',
      'unit_converter': '단위 변환기',
      'vat_calculator': '부가세 계산기',
      'age_calculator': '나이 계산기',
      'date_calculator': '날짜 계산기',
      'salary_calculator': '실수령액 계산기',
      'discount_calculator': '할인 계산기',
      'dutch_pay': '더치페이 계산기',
      'bmi_calculator': 'BMI 계산기',
    },
    'en': {
      'basic_calculator': 'Calculator',
      'exchange_rate': 'Exchange Rate',
      'unit_converter': 'Unit Converter',
      'vat_calculator': 'VAT Calculator',
      'age_calculator': 'Age Calculator',
      'date_calculator': 'Date Calculator',
      'salary_calculator': 'Salary Calculator',
      'discount_calculator': 'Discount Calculator',
      'dutch_pay': 'Split Bill',
      'bmi_calculator': 'BMI Calculator',
    },
  };

  // ──────────────────────────────────────────
  // 요일 이름 — 풀 (7개)
  // ──────────────────────────────────────────

  /// 요일 이름 (풀). weekday: 1=월~7=일 (DateTime.weekday 기준)
  static String weekdayFull(int weekday, Locale locale) =>
      _pick(_weekdayFullNames, weekday.toString(), locale);

  static const _weekdayFullNames = {
    'ko': {
      '1': '월요일', '2': '화요일', '3': '수요일', '4': '목요일',
      '5': '금요일', '6': '토요일', '7': '일요일',
    },
    'en': {
      '1': 'Monday', '2': 'Tuesday', '3': 'Wednesday', '4': 'Thursday',
      '5': 'Friday', '6': 'Saturday', '7': 'Sunday',
    },
  };

  // ──────────────────────────────────────────
  // 요일 이름 — 약어 (7개)
  // ──────────────────────────────────────────

  /// 요일 이름 (약어). weekday: 1=월~7=일
  static String weekdayShort(int weekday, Locale locale) =>
      _pick(_weekdayShortNames, weekday.toString(), locale);

  static const _weekdayShortNames = {
    'ko': {
      '1': '월', '2': '화', '3': '수', '4': '목',
      '5': '금', '6': '토', '7': '일',
    },
    'en': {
      '1': 'Mon', '2': 'Tue', '3': 'Wed', '4': 'Thu',
      '5': 'Fri', '6': 'Sat', '7': 'Sun',
    },
  };

  // ──────────────────────────────────────────
  // 띠 이름 (12개)
  // ──────────────────────────────────────────

  /// 띠 이름 조회. index: 0=쥐~11=돼지
  static String zodiacName(int index, Locale locale) =>
      _pick(_zodiacNames, index.toString(), locale);

  static const _zodiacNames = {
    'ko': {
      '0': '쥐', '1': '소', '2': '호랑이', '3': '토끼', '4': '용', '5': '뱀',
      '6': '말', '7': '양', '8': '원숭이', '9': '닭', '10': '개', '11': '돼지',
    },
    'en': {
      '0': 'Rat', '1': 'Ox', '2': 'Tiger', '3': 'Rabbit', '4': 'Dragon', '5': 'Snake',
      '6': 'Horse', '7': 'Goat', '8': 'Monkey', '9': 'Rooster', '10': 'Dog', '11': 'Pig',
    },
  };

  // ──────────────────────────────────────────
  // 별자리 이름 (12개)
  // ──────────────────────────────────────────

  /// 별자리 이름 조회. index: 0=염소자리~11=사수자리
  static String constellationName(int index, Locale locale) =>
      _pick(_constellationNames, index.toString(), locale);

  static const _constellationNames = {
    'ko': {
      '0': '염소자리', '1': '물병자리', '2': '물고기자리', '3': '양자리',
      '4': '황소자리', '5': '쌍둥이자리', '6': '게자리', '7': '사자자리',
      '8': '처녀자리', '9': '천칭자리', '10': '전갈자리', '11': '사수자리',
    },
    'en': {
      '0': 'Capricorn', '1': 'Aquarius', '2': 'Pisces', '3': 'Aries',
      '4': 'Taurus', '5': 'Gemini', '6': 'Cancer', '7': 'Leo',
      '8': 'Virgo', '9': 'Libra', '10': 'Scorpio', '11': 'Sagittarius',
    },
  };

  // ──────────────────────────────────────────
  // BMI 카테고리 라벨 (6개)
  // ──────────────────────────────────────────

  /// BMI 카테고리 라벨 조회. code: BmiCategoryCode.name
  static String bmiCategory(String code, Locale locale) =>
      _pick(_bmiCategoryLabels, code, locale);

  static const _bmiCategoryLabels = {
    'ko': {
      'underweight': '저체중', 'normal': '정상', 'overweight': '과체중',
      'obese': '비만', 'obese1': '비만 1단계', 'obese2': '비만 2단계',
    },
    'en': {
      'underweight': 'Underweight', 'normal': 'Normal', 'overweight': 'Overweight',
      'obese': 'Obese', 'obese1': 'Obese I', 'obese2': 'Obese II',
    },
  };

  // ──────────────────────────────────────────
  // 계산기 설명 (10개)
  // ──────────────────────────────────────────
  static const _calcDescriptions = {
    'ko': {
      'basic_calculator': '사칙연산 및 공학 계산',
      'exchange_rate': '실시간 전 세계 환율 변환',
      'unit_converter': '길이, 무게, 넓이 등 변환',
      'vat_calculator': '부가세 포함/별도 계산',
      'age_calculator': '만 나이, 띠, 별자리 확인',
      'date_calculator': '디데이 및 날짜 간격 계산',
      'salary_calculator': '연봉 기준 세후 실수령액 계산',
      'discount_calculator': '할인율 적용 최종금액 계산',
      'dutch_pay': '인원수별 1/N 금액 계산',
      'bmi_calculator': '신장·체중 기준 체질량지수 계산',
    },
    'en': {
      'basic_calculator': 'Arithmetic & scientific calculations',
      'exchange_rate': 'Real-time global currency conversion',
      'unit_converter': 'Length, weight, area & more',
      'vat_calculator': 'VAT inclusive/exclusive calculations',
      'age_calculator': 'Age, zodiac & constellation',
      'date_calculator': 'D-day & date interval calculations',
      'salary_calculator': 'After-tax take-home pay',
      'discount_calculator': 'Final price after discount',
      'dutch_pay': 'Split the bill equally',
      'bmi_calculator': 'Body Mass Index calculator',
    },
  };
}
