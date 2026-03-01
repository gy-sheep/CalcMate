/**
 * CalcMate — 환율 캐싱 Firebase Function
 *
 * 역할:
 *   앱에서 TTL 만료 시 호출되어 Open Exchange Rates API로부터
 *   최신 환율을 가져와 Firestore에 캐싱한다.
 *
 * 호출 방식:
 *   GET https://asia-northeast3-calcmate-353ed.cloudfunctions.net/refreshExchangeRates
 *
 * Double Check Locking:
 *   여러 앱이 동시에 호출해도 Firestore Transaction으로
 *   단 한 번만 외부 API를 호출하도록 보장한다.
 */

import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {onRequest} from "firebase-functions/v2/https";
import {defineString} from "firebase-functions/params";

// Firebase Admin 초기화
initializeApp();

// 환경 변수
const OXR_APP_ID = defineString("OXR_APP_ID");

// 상수
const TTL_MS = 3_600_000; // 1시간 (밀리초)
const DOC_PATH = "exchange_rates/latest";
const OXR_URL = "https://openexchangerates.org/api/latest.json";

/**
 * refreshExchangeRates
 *
 * 1. Firestore에서 현재 환율 문서를 읽는다
 * 2. TTL이 유효하면 그대로 반환한다 (API 미호출)
 * 3. TTL이 만료되었으면 Double Check Locking으로 단일 요청만 API를 호출한다
 * 4. 갱신된 환율을 Firestore에 저장하고 반환한다
 */
export const refreshExchangeRates = onRequest(
  {
    region: "asia-northeast3", // 서울 리전
    memory: "256MiB",
    timeoutSeconds: 30,
    cors: true, // Flutter 웹 빌드 대비 CORS 허용
  },
  async (req, res) => {
    const db = getFirestore();
    const docRef = db.doc(DOC_PATH);

    try {
      // ── Phase 1: Transaction으로 TTL + Double Check Lock 확인 ──
      const cachedData = await db.runTransaction(async (tx) => {
        const doc = await tx.get(docRef);
        const data = doc.data();

        // 문서가 존재하고 TTL 유효 → 현재 데이터 반환 (API 미호출)
        if (data && (Date.now() - data.timestamp) < TTL_MS) {
          return data;
        }

        // 다른 요청이 이미 갱신 중 → 현재 데이터 반환 (중복 호출 방지)
        if (data?.refreshing === true) {
          return data;
        }

        // refreshing 플래그 설정 (이 요청이 갱신 담당)
        if (doc.exists) {
          tx.update(docRef, {refreshing: true});
        }

        return null; // null → Transaction 외부에서 API 호출 진행
      });

      // TTL 유효 또는 다른 요청이 갱신 중 → 캐시 데이터 반환
      if (cachedData) {
        res.json({
          base: cachedData.base,
          rates: cachedData.rates,
          timestamp: cachedData.timestamp,
          source: cachedData.source,
          cached: true,
        });
        return;
      }

      // ── Phase 2: Open Exchange Rates API 호출 ──
      const apiRes = await fetch(
        `${OXR_URL}?app_id=${OXR_APP_ID.value()}`
      );

      if (!apiRes.ok) {
        throw new Error(`API responded with status ${apiRes.status}`);
      }

      const apiData = await apiRes.json();

      // ── Phase 3: Firestore 업데이트 ──
      const newData = {
        base: apiData.base, // "USD"
        rates: apiData.rates, // { KRW: 1320.45, JPY: 150.23, ... }
        timestamp: Date.now(), // 갱신 시각 (Unix ms)
        source: "open_exchange_rates",
        refreshing: false, // 갱신 완료
      };

      await docRef.set(newData);

      res.json({
        ...newData,
        cached: false,
      });
    } catch (error) {
      // API 실패 시 refreshing 플래그 해제
      try {
        await docRef.update({refreshing: false});
      } catch {
        // 문서 자체가 없는 경우 무시
      }

      console.error("Exchange rate refresh failed:", error);
      res.status(500).json({
        error: "Failed to fetch exchange rates",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    }
  }
);
