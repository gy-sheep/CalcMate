/**
 * CalcMate — 간이세액표 Firestore 시딩 스크립트
 *
 * 국세청 근로소득 간이세액표 Excel을 파싱하여
 * Firestore tax_rates/latest 문서에 업로드한다.
 *
 * 실행: cd functions && npx ts-node scripts/seed_tax_rates.ts <Excel 파일 경로>
 * 예시: npx ts-node scripts/seed_tax_rates.ts ~/Downloads/근로소득\ 간이세액표.xlsx
 */

import {initializeApp, cert} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import * as XLSX from "xlsx";
import * as path from "path";

// ── Firebase 초기화 ─────────────────────────────────────────────────────────
// 프로젝트 루트의 serviceAccountKey.json 사용.

const serviceAccountPath = path.resolve(__dirname, "../../serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccountPath),
});

const db = getFirestore();

// ── 4대보험 요율 (2026년 현행) ──────────────────────────────────────────────

const INSURANCE_RATES = {
  nationalPensionRate: 0.0475,
  nationalPensionMin: 390000,
  nationalPensionMax: 6170000,
  healthInsuranceRate: 0.03595,
  longTermCareRate: 0.1314,
  employmentInsuranceRate: 0.009,
  basedYear: 2026,
};

// ── 자녀세액공제 (소득령 별표2) ──────────────────────────────────────────────

const CHILD_TAX_CREDIT = {
  one: 20830,      // 8~20세 자녀 1명
  two: 45830,      // 8~20세 자녀 2명
  perExtra: 33330, // 3명 이상 시 추가 1명당
};

// ── 1,000만원 초과 산식 (Excel 행 652~662) ──────────────────────────────────
// 공통: (10,000천원인 경우의 해당 세액) + baseAdd + (excessFrom 초과금액 × applyRatio × rate)

const OVER_TEN_MILLION_BRACKETS = [
  {min: 10000, max: 14000, baseAdd: 25000, rate: 0.35, applyRatio: 0.98, excessFrom: 10000},
  {min: 14000, max: 28000, baseAdd: 1397000, rate: 0.38, applyRatio: 0.98, excessFrom: 14000},
  {min: 28000, max: 30000, baseAdd: 6610600, rate: 0.40, applyRatio: 0.98, excessFrom: 28000},
  {min: 30000, max: 45000, baseAdd: 7394600, rate: 0.40, applyRatio: 1.0, excessFrom: 30000},
  {min: 45000, max: 87000, baseAdd: 13394600, rate: 0.42, applyRatio: 1.0, excessFrom: 45000},
  {min: 87000, max: 999999, baseAdd: 31034600, rate: 0.45, applyRatio: 1.0, excessFrom: 87000},
];

// ── Excel 파싱 ──────────────────────────────────────────────────────────────

function parseExcel(filePath: string) {
  const wb = XLSX.readFile(filePath);
  const ws = wb.Sheets["근로소득간이세액표"];

  if (!ws) {
    throw new Error("시트 '근로소득간이세액표'를 찾을 수 없습니다.");
  }

  const rows: Array<{min: number; max: number; taxes: number[]}> = [];

  // 데이터는 행 5부터 시작 (1-indexed → XLSX는 0-indexed 아님, 셀 주소 사용)
  // A열: 이상 (천원), B열: 미만 (천원), C~M열: 부양가족 1~11명 세액
  const range = XLSX.utils.decode_range(ws["!ref"] || "A1");

  for (let r = 4; r <= range.e.r; r++) { // 0-indexed, 행5 = index 4
    const cellA = ws[XLSX.utils.encode_cell({r, c: 0})];
    const cellB = ws[XLSX.utils.encode_cell({r, c: 1})];

    // 숫자가 아닌 행이면 테이블 끝 (1,000만원 초과 산식 텍스트 행)
    if (!cellA || typeof cellA.v !== "number") break;
    if (!cellB || typeof cellB.v !== "number") break;

    const min = cellA.v as number;
    const max = cellB.v as number;

    const taxes: number[] = [];
    for (let c = 2; c <= 12; c++) { // C~M열 (0-indexed: 2~12)
      const cell = ws[XLSX.utils.encode_cell({r, c})];
      if (!cell || cell.v === "-" || cell.v === null || cell.v === undefined) {
        taxes.push(0);
      } else {
        taxes.push(Number(cell.v));
      }
    }

    rows.push({min, max, taxes});
  }

  return rows;
}

// ── 메인 ────────────────────────────────────────────────────────────────────

async function main() {
  const filePath = process.argv[2];
  if (!filePath) {
    console.error("사용법: npx ts-node scripts/seed_tax_rates.ts <Excel 파일 경로>");
    console.error("예시:   npx ts-node scripts/seed_tax_rates.ts ~/Downloads/근로소득\\ 간이세액표.xlsx");
    process.exit(1);
  }

  const resolvedPath = path.resolve(filePath);
  console.log(`Excel 파일 읽기: ${resolvedPath}`);

  const incomeTaxTable = parseExcel(resolvedPath);
  console.log(`파싱 완료: ${incomeTaxTable.length}행`);

  // 데이터 검증
  if (incomeTaxTable.length < 600) {
    console.error(`데이터 행이 너무 적습니다 (${incomeTaxTable.length}행). Excel 파일을 확인하세요.`);
    process.exit(1);
  }

  const firstRow = incomeTaxTable[0];
  const lastRow = incomeTaxTable[incomeTaxTable.length - 1];
  console.log(`범위: ${firstRow.min}천원 ~ ${lastRow.max}천원`);
  console.log(`첫 행: min=${firstRow.min}, max=${firstRow.max}, taxes=${firstRow.taxes}`);
  console.log(`끝 행: min=${lastRow.min}, max=${lastRow.max}, taxes=${lastRow.taxes}`);

  // basedHalf 자동 판단:
  // - 현재 월 7월 이상 + 기존 Firestore 데이터 대비 요율 변경 있음 → 2 (하반기)
  // - 그 외 (새해 시딩 / 변경 없음) → null
  const currentMonth = new Date().getMonth() + 1; // 1~12
  let basedHalf: number | null = null;

  if (currentMonth >= 7) {
    try {
      const existing = await db.doc("tax_rates/latest").get();
      if (existing.exists) {
        const prev = existing.data()!;
        const rateFields = [
          "nationalPensionRate", "nationalPensionMin", "nationalPensionMax",
          "healthInsuranceRate", "longTermCareRate", "employmentInsuranceRate",
        ] as const;
        const hasRateChange = rateFields.some(
          (f) => prev[f] !== (INSURANCE_RATES as Record<string, unknown>)[f]
        );
        if (hasRateChange && prev.basedYear === INSURANCE_RATES.basedYear) {
          basedHalf = 2;
        }
      }
    } catch (e) {
      console.warn("기존 데이터 비교 실패 (무시하고 진행):", e);
    }
  }

  // Firestore 업로드
  const docData: Record<string, unknown> = {
    ...INSURANCE_RATES,
    ...(basedHalf != null ? {basedHalf} : {}),
    incomeTaxTable,
    overTenMillionBrackets: OVER_TEN_MILLION_BRACKETS,
    childTaxCredit: CHILD_TAX_CREDIT,
    updatedAt: Date.now(),
  };

  const jsonSize = JSON.stringify(docData).length;
  console.log(`\n문서 크기: ${(jsonSize / 1024).toFixed(1)} KB`);

  if (jsonSize > 1_000_000) {
    console.error("Firestore 문서 크기 제한(1MB) 초과! 데이터를 확인하세요.");
    process.exit(1);
  }

  console.log("\nFirestore tax_rates/latest 문서에 업로드 중...");
  await db.doc("tax_rates/latest").set(docData);
  console.log("업로드 완료!");

  // 요약
  console.log("\n=== 업로드 요약 ===");
  const periodLabel = basedHalf === 2 ? ` 하반기` : "";
  console.log(`기준: ${INSURANCE_RATES.basedYear}년${periodLabel}`);
  console.log(`국민연금: ${INSURANCE_RATES.nationalPensionRate * 100}%`);
  console.log(`  하한: ${INSURANCE_RATES.nationalPensionMin.toLocaleString()}원`);
  console.log(`  상한: ${INSURANCE_RATES.nationalPensionMax.toLocaleString()}원`);
  console.log(`건강보험: ${INSURANCE_RATES.healthInsuranceRate * 100}%`);
  console.log(`장기요양: ${INSURANCE_RATES.longTermCareRate * 100}%`);
  console.log(`고용보험: ${INSURANCE_RATES.employmentInsuranceRate * 100}%`);
  console.log(`간이세액표: ${incomeTaxTable.length}행`);
  console.log(`초과 산식: ${OVER_TEN_MILLION_BRACKETS.length}구간`);
  console.log(`자녀세액공제: ${CHILD_TAX_CREDIT.one} / ${CHILD_TAX_CREDIT.two} / +${CHILD_TAX_CREDIT.perExtra}`);
  console.log(`문서 크기: ${(jsonSize / 1024).toFixed(1)} KB`);

  process.exit(0);
}

main().catch((err) => {
  console.error("시딩 실패:", err);
  process.exit(1);
});
