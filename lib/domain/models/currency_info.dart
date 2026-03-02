/// 통화 정보 (코드, 이름, 국기)
class CurrencyInfo {
  final String code;
  final String name;
  final String flag;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.flag,
  });
}

/// 앱에서 지원하는 통화 목록 (24개)
const kSupportedCurrencies = [
  CurrencyInfo(code: 'KRW', name: '대한민국 원', flag: '\u{1F1F0}\u{1F1F7}'),
  CurrencyInfo(code: 'USD', name: '미국 달러', flag: '\u{1F1FA}\u{1F1F8}'),
  CurrencyInfo(code: 'JPY', name: '일본 엔', flag: '\u{1F1EF}\u{1F1F5}'),
  CurrencyInfo(code: 'EUR', name: '유로', flag: '\u{1F1EA}\u{1F1FA}'),
  CurrencyInfo(code: 'CNY', name: '중국 위안', flag: '\u{1F1E8}\u{1F1F3}'),
  CurrencyInfo(code: 'GBP', name: '영국 파운드', flag: '\u{1F1EC}\u{1F1E7}'),
  CurrencyInfo(code: 'AUD', name: '호주 달러', flag: '\u{1F1E6}\u{1F1FA}'),
  CurrencyInfo(code: 'CAD', name: '캐나다 달러', flag: '\u{1F1E8}\u{1F1E6}'),
  CurrencyInfo(code: 'CHF', name: '스위스 프랑', flag: '\u{1F1E8}\u{1F1ED}'),
  CurrencyInfo(code: 'HKD', name: '홍콩 달러', flag: '\u{1F1ED}\u{1F1F0}'),
  CurrencyInfo(code: 'SGD', name: '싱가포르 달러', flag: '\u{1F1F8}\u{1F1EC}'),
  CurrencyInfo(code: 'TWD', name: '대만 달러', flag: '\u{1F1F9}\u{1F1FC}'),
  CurrencyInfo(code: 'THB', name: '태국 바트', flag: '\u{1F1F9}\u{1F1ED}'),
  CurrencyInfo(code: 'VND', name: '베트남 동', flag: '\u{1F1FB}\u{1F1F3}'),
  CurrencyInfo(code: 'PHP', name: '필리핀 페소', flag: '\u{1F1F5}\u{1F1ED}'),
  CurrencyInfo(code: 'INR', name: '인도 루피', flag: '\u{1F1EE}\u{1F1F3}'),
  CurrencyInfo(code: 'MXN', name: '멕시코 페소', flag: '\u{1F1F2}\u{1F1FD}'),
  CurrencyInfo(code: 'BRL', name: '브라질 레알', flag: '\u{1F1E7}\u{1F1F7}'),
  CurrencyInfo(code: 'SEK', name: '스웨덴 크로나', flag: '\u{1F1F8}\u{1F1EA}'),
  CurrencyInfo(code: 'NOK', name: '노르웨이 크로네', flag: '\u{1F1F3}\u{1F1F4}'),
  CurrencyInfo(code: 'NZD', name: '뉴질랜드 달러', flag: '\u{1F1F3}\u{1F1FF}'),
  CurrencyInfo(code: 'TRY', name: '터키 리라', flag: '\u{1F1F9}\u{1F1F7}'),
  CurrencyInfo(code: 'RUB', name: '러시아 루블', flag: '\u{1F1F7}\u{1F1FA}'),
  CurrencyInfo(code: 'ZAR', name: '남아공 랜드', flag: '\u{1F1FF}\u{1F1E6}'),
];
