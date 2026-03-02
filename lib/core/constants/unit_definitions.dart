import 'package:flutter/material.dart';

import '../../domain/models/unit_definition.dart';

/// 10개 카테고리의 단위 정의 상수.
const unitCategories = <UnitCategory>[
  // ── 길이 ──
  UnitCategory(
    name: '길이',
    icon: Icons.straighten,
    defaultCode: 'cm',
    units: [
      UnitDef(code: 'mm', label: '밀리미터', ratio: 0.001),
      UnitDef(code: 'cm', label: '센티미터', ratio: 0.01),
      UnitDef(code: 'm', label: '미터', ratio: 1),
      UnitDef(code: 'km', label: '킬로미터', ratio: 1000),
      UnitDef(code: 'in', label: '인치', ratio: 0.0254),
      UnitDef(code: 'ft', label: '피트', ratio: 0.3048),
      UnitDef(code: 'yd', label: '야드', ratio: 0.9144),
      UnitDef(code: 'mi', label: '마일', ratio: 1609.344),
    ],
  ),

  // ── 질량 ──
  UnitCategory(
    name: '질량',
    icon: Icons.fitness_center,
    defaultCode: 'kg',
    units: [
      UnitDef(code: 'mg', label: '밀리그램', ratio: 0.001),
      UnitDef(code: 'g', label: '그램', ratio: 1),
      UnitDef(code: 'kg', label: '킬로그램', ratio: 1000),
      UnitDef(code: 't', label: '톤', ratio: 1000000),
      UnitDef(code: 'oz', label: '온스', ratio: 28.3495),
      UnitDef(code: 'lb', label: '파운드', ratio: 453.592),
    ],
  ),

  // ── 온도 (특수 공식 — ratio null) ──
  UnitCategory(
    name: '온도',
    icon: Icons.thermostat,
    defaultCode: '°C',
    units: [
      UnitDef(code: '°C', label: '섭씨'),
      UnitDef(code: '°F', label: '화씨'),
      UnitDef(code: 'K', label: '켈빈'),
    ],
  ),

  // ── 넓이 ──
  UnitCategory(
    name: '넓이',
    icon: Icons.crop_square,
    defaultCode: 'm²',
    units: [
      UnitDef(code: 'mm²', label: '제곱밀리미터', ratio: 0.000001),
      UnitDef(code: 'cm²', label: '제곱센티미터', ratio: 0.0001),
      UnitDef(code: 'm²', label: '제곱미터', ratio: 1),
      UnitDef(code: 'km²', label: '제곱킬로미터', ratio: 1000000),
      UnitDef(code: 'ha', label: '헥타르', ratio: 10000),
      UnitDef(code: 'ac', label: '에이커', ratio: 4046.8564224),
      UnitDef(code: 'ft²', label: '제곱피트', ratio: 0.09290304),
      UnitDef(code: '평', label: '평', ratio: 3.305785),
    ],
  ),

  // ── 시간 ──
  UnitCategory(
    name: '시간',
    icon: Icons.access_time,
    defaultCode: 'h',
    units: [
      UnitDef(code: 'ms', label: '밀리초', ratio: 0.001),
      UnitDef(code: 's', label: '초', ratio: 1),
      UnitDef(code: 'min', label: '분', ratio: 60),
      UnitDef(code: 'h', label: '시간', ratio: 3600),
      UnitDef(code: 'day', label: '일', ratio: 86400),
      UnitDef(code: 'week', label: '주', ratio: 604800),
      UnitDef(code: 'month', label: '개월', ratio: 2592000),
      UnitDef(code: 'year', label: '년', ratio: 31536000),
    ],
  ),

  // ── 부피 ──
  UnitCategory(
    name: '부피',
    icon: Icons.local_drink,
    defaultCode: 'L',
    units: [
      UnitDef(code: 'mL', label: '밀리리터', ratio: 1),
      UnitDef(code: 'L', label: '리터', ratio: 1000),
      UnitDef(code: 'm³', label: '세제곱미터', ratio: 1000000),
      UnitDef(code: 'gal', label: '갤런(US)', ratio: 3785.41),
      UnitDef(code: 'qt', label: '쿼트(US)', ratio: 946.353),
      UnitDef(code: 'pt', label: '파인트(US)', ratio: 473.176),
      UnitDef(code: 'fl oz', label: '액량온스(US)', ratio: 29.5735),
      UnitDef(code: 'cup', label: '컵(US)', ratio: 236.588),
    ],
  ),

  // ── 속도 ──
  UnitCategory(
    name: '속도',
    icon: Icons.directions_car,
    defaultCode: 'km/h',
    units: [
      UnitDef(code: 'm/s', label: '미터/초', ratio: 1),
      UnitDef(code: 'km/h', label: '킬로미터/시', ratio: 0.277778),
      UnitDef(code: 'mph', label: '마일/시', ratio: 0.44704),
      UnitDef(code: 'kn', label: '노트', ratio: 0.514444),
      UnitDef(code: 'ft/s', label: '피트/초', ratio: 0.3048),
    ],
  ),

  // ── 연비 (특수 공식 — ratio null) ──
  UnitCategory(
    name: '연비',
    icon: Icons.local_gas_station,
    defaultCode: 'km/L',
    units: [
      UnitDef(code: 'km/L', label: '킬로미터/리터'),
      UnitDef(code: 'L/100km', label: '리터/100킬로미터'),
      UnitDef(code: 'mpg(US)', label: '마일/갤런(US)'),
      UnitDef(code: 'mpg(UK)', label: '마일/갤런(UK)'),
    ],
  ),

  // ── 데이터 ──
  UnitCategory(
    name: '데이터',
    icon: Icons.storage,
    defaultCode: 'GB',
    units: [
      UnitDef(code: 'bit', label: '비트', ratio: 0.125),
      UnitDef(code: 'B', label: '바이트', ratio: 1),
      UnitDef(code: 'KB', label: '킬로바이트', ratio: 1024),
      UnitDef(code: 'MB', label: '메가바이트', ratio: 1048576),
      UnitDef(code: 'GB', label: '기가바이트', ratio: 1073741824),
      UnitDef(code: 'TB', label: '테라바이트', ratio: 1099511627776),
      UnitDef(code: 'PB', label: '페타바이트', ratio: 1125899906842624),
    ],
  ),

  // ── 압력 ──
  UnitCategory(
    name: '압력',
    icon: Icons.speed,
    defaultCode: 'atm',
    units: [
      UnitDef(code: 'Pa', label: '파스칼', ratio: 1),
      UnitDef(code: 'kPa', label: '킬로파스칼', ratio: 1000),
      UnitDef(code: 'MPa', label: '메가파스칼', ratio: 1000000),
      UnitDef(code: 'bar', label: '바', ratio: 100000),
      UnitDef(code: 'atm', label: '기압', ratio: 101325),
      UnitDef(code: 'mmHg', label: '수은주밀리미터', ratio: 133.322),
      UnitDef(code: 'psi', label: '제곱인치당파운드', ratio: 6894.757),
    ],
  ),
];
