/**
 * CalcMate — 환율 캐싱 Firebase Functions
 *
 * - scheduledExchangeRateRefresh: Cloud Scheduler로 매 1시간마다 자동 갱신
 * - refreshExchangeRates: 수동 갱신 / 테스트용 HTTP 트리거
 */

import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {onRequest} from "firebase-functions/v2/https";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {defineString} from "firebase-functions/params";

initializeApp();

const OXR_APP_ID = defineString("OXR_APP_ID");

const REGION = "asia-northeast3";
const DOC_PATH = "exchange_rates/latest";
const OXR_URL = "https://openexchangerates.org/api/latest.json";

/**
 * OXR API에서 최신 환율을 가져와 Firestore에 저장한다.
 * refreshing 플래그로 동시 호출 시 중복 API 호출을 방지한다.
 */
async function fetchAndStoreRates(): Promise<void> {
  const db = getFirestore();
  const docRef = db.doc(DOC_PATH);

  // refreshing 플래그 확인 후 설정 (Double Check Locking)
  const shouldRefresh = await db.runTransaction(async (tx) => {
    const doc = await tx.get(docRef);
    if (doc.data()?.refreshing === true) return false;
    tx.set(docRef, {...(doc.data() ?? {}), refreshing: true}, {merge: true});
    return true;
  });

  if (!shouldRefresh) return;

  try {
    const apiRes = await fetch(`${OXR_URL}?app_id=${OXR_APP_ID.value()}`);
    if (!apiRes.ok) throw new Error(`OXR API error: ${apiRes.status}`);

    const apiData = await apiRes.json();

    await docRef.set({
      base: apiData.base,
      rates: apiData.rates,
      timestamp: Date.now(),
      source: "open_exchange_rates",
      refreshing: false,
    });
  } catch (error) {
    try {
      await docRef.update({refreshing: false});
    } catch {
      // 문서 자체가 없는 경우 무시
    }
    throw error;
  }
}

// ── Cloud Scheduler: 매 1시간 자동 갱신 ──────────────────────────────────────

export const scheduledExchangeRateRefresh = onSchedule(
  {
    schedule: "0 * * * *",
    timeZone: "Asia/Seoul",
    region: REGION,
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async () => {
    await fetchAndStoreRates();
  }
);

// ── HTTP 트리거: 수동 갱신 / 테스트용 ────────────────────────────────────────

export const refreshExchangeRates = onRequest(
  {
    region: REGION,
    memory: "256MiB",
    timeoutSeconds: 30,
    cors: true,
  },
  async (req, res) => {
    try {
      await fetchAndStoreRates();
      const doc = await getFirestore().doc(DOC_PATH).get();
      res.json({...doc.data(), cached: false});
    } catch (error) {
      console.error("Exchange rate refresh failed:", error);
      res.status(500).json({
        error: "Failed to fetch exchange rates",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  }
);
