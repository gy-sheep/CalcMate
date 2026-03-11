import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_design_tokens.dart';
import 'rent_calculator_colors.dart';

/// 전월세 계산기 프리뷰 — A안: 고정 상단 + 스와이프 하단
class RentPreviewSwipeScreen extends StatefulWidget {
  const RentPreviewSwipeScreen({super.key});

  @override
  State<RentPreviewSwipeScreen> createState() => _RentPreviewSwipeScreenState();
}

class _RentPreviewSwipeScreenState extends State<RentPreviewSwipeScreen> {
  late final PageController _pageController;
  double _pageOffset = 0.0;

  // ── 더미 데이터 ──
  static const _jeonse = '3억 0000';
  static const _deposit = '5,000';
  static const _rate = '5.00';
  static const _wolse = '104';
  static const _wolseInput = '150';
  static const _reverseRate = '7.20';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (mounted) setState(() => _pageOffset = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: kRentTextPrimary, size: CmAppBar.backIconSize),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '전월세 계산기',
          style: CmAppBar.titleText.copyWith(color: kRentTextPrimary),
        ),
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kRentBgTop, kRentBgBottom],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ════════════════════════════════════════════
              //  고정 영역: 전세금 카드 + 보증금 행
              // ════════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    screenPaddingH, 8, screenPaddingH, 0),
                child: Column(
                  children: [
                    _buildJeonseCard(),
                    const SizedBox(height: 12),
                    _buildDepositRow(),
                    const SizedBox(height: 6),
                    // 구분선
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: List.generate(
                          40,
                          (_) => Expanded(
                            child: Container(
                              height: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              color: kRentDivider.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ════════════════════════════════════════════
              //  스와이프 영역
              // ════════════════════════════════════════════
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    _buildPage1Conversion(),
                    _buildPage2Verification(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 고정 영역: 전세금 카드 ────────────────────────────────────

  Widget _buildJeonseCard() {
    return Container(
      width: double.infinity,
      padding: CmInputCard.padding,
      decoration: BoxDecoration(
        color: kRentCardBg,
        borderRadius: BorderRadius.circular(CmInputCard.radius),
        border: Border.all(color: kRentAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kRentAccent.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '전세금',
            style: CmInputCard.titleText.copyWith(color: kRentAccent),
          ),
          const SizedBox(height: CmInputCard.titleSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  _jeonse,
                  style: CmInputCard.inputText.copyWith(
                    color: kRentTextPrimary,
                  ),
                ),
              ),
              Text(
                '만원',
                style: CmInputCard.unitText.copyWith(
                  color: kRentTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 고정 영역: 보증금 행 ─────────────────────────────────────

  Widget _buildDepositRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            '보증금',
            style: rowLabel.copyWith(color: kRentTextSecondary),
          ),
          const Spacer(),
          Text(
            '$_deposit 만원',
            style: textStyle18.copyWith(color: kRentTextPrimary),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: kRentTextTertiary, size: 20),
        ],
      ),
    );
  }

  // ── 페이지 1: 전월세 전환 ────────────────────────────────────

  Widget _buildPage1Conversion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: screenPaddingH),
      child: Column(
        children: [
          const SizedBox(height: 4),
          // 페이지 인디케이터 + 타이틀
          _buildPageHeader('전월세 전환', 0),
          const SizedBox(height: 12),

          // 전환율 행
          _buildRateRow(),
          const SizedBox(height: 12),

          // ⇅ 스왑 버튼
          _buildSwapButton(),
          const SizedBox(height: 12),

          // 월세 결과 카드
          _buildWolseResultCard(),

          const Spacer(),

          // 비용 비교 미니 요약
          _buildCostSummary(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── 페이지 2: 전환율 확인 ────────────────────────────────────

  Widget _buildPage2Verification() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: screenPaddingH),
      child: Column(
        children: [
          const SizedBox(height: 4),
          // 페이지 인디케이터 + 타이틀
          _buildPageHeader('전환율 확인', 1),
          const SizedBox(height: 16),

          // 월세 입력 카드
          _buildWolseInputCard(),
          const SizedBox(height: 20),

          // 전환율 결과 영역
          _buildRateResult(),
        ],
      ),
    );
  }

  // ── 공통 위젯 ───────────────────────────────────────────────

  Widget _buildPageHeader(String title, int pageIndex) {
    return Row(
      children: [
        Text(
          title,
          style: sectionLabel.copyWith(
            color: kRentAccent,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        // 도트 인디케이터
        Row(
          children: List.generate(2, (i) {
            final isActive = (_pageOffset - i).abs() < 0.5;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? kRentAccent : kRentDivider,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text('전환율', style: rowLabel.copyWith(color: kRentTextSecondary)),
          const SizedBox(width: 8),
          Text(
            '법정 상한 7.0%',
            style: textStyleCaption.copyWith(color: kRentTextTertiary),
          ),
          const Spacer(),
          Text(
            '$_rate %',
            style: textStyle18.copyWith(color: kRentTextPrimary),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: kRentTextTertiary, size: 20),
        ],
      ),
    );
  }

  Widget _buildSwapButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: kRentSwapBg,
        shape: BoxShape.circle,
        border: Border.all(color: kRentAccentBorder),
      ),
      child: Icon(Icons.swap_vert, color: kRentAccent, size: 22),
    );
  }

  Widget _buildWolseResultCard() {
    return Container(
      width: double.infinity,
      padding: CmResultCard.padding,
      decoration: BoxDecoration(
        color: kRentResultBg,
        borderRadius: BorderRadius.circular(CmResultCard.radius),
        border: Border.all(color: kRentResultBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월 세',
            style: CmResultCard.titleText.copyWith(color: kRentAccent),
          ),
          const SizedBox(height: CmResultCard.titleSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '= ',
                style: CmResultCard.resultText.copyWith(
                  color: kRentAccent.withValues(alpha: 0.5),
                  fontSize: 28,
                ),
              ),
              Expanded(
                child: Text(
                  _wolse,
                  style: CmResultCard.resultText.copyWith(
                    color: kRentAccent,
                  ),
                ),
              ),
              Text(
                '만원',
                style: CmResultCard.unitText.copyWith(
                  color: kRentTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 1,
            color: kRentDivider.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: kRentSuccess),
              const SizedBox(width: 6),
              Text(
                '전세 대비 월 17만원 유리',
                style: textStyleCaption.copyWith(
                  color: kRentSuccess,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, size: 16, color: kRentTextTertiary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWolseInputCard() {
    return Container(
      width: double.infinity,
      padding: CmInputCard.padding,
      decoration: BoxDecoration(
        color: kRentCardBg,
        borderRadius: BorderRadius.circular(CmInputCard.radius),
        border: Border.all(color: kRentAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kRentAccent.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월 세',
            style: CmInputCard.titleText.copyWith(color: kRentAccent),
          ),
          const SizedBox(height: CmInputCard.titleSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  _wolseInput,
                  style: CmInputCard.inputText.copyWith(
                    color: kRentTextPrimary,
                  ),
                ),
              ),
              Text(
                '만원',
                style: CmInputCard.unitText.copyWith(
                  color: kRentTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRateResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kRentResultBg,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: kRentResultBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 적용 전환율
          Row(
            children: [
              Text(
                '적용 전환율',
                style: rowLabel.copyWith(color: kRentTextSecondary),
              ),
              const Spacer(),
              Text(
                '= $_reverseRate %',
                style: textMediumResult.copyWith(
                  color: kRentAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: kRentDivider.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          // 법정 상한
          Row(
            children: [
              Text(
                '법정 상한',
                style: rowLabel.copyWith(color: kRentTextSecondary),
              ),
              const Spacer(),
              Text(
                '7.00 %',
                style: textStyle18.copyWith(color: kRentTextSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 경고
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kRentWarning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kRentWarning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18, color: kRentWarning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '법정 상한을 0.20%p 초과합니다',
                    style: textStyleCaption.copyWith(
                      color: kRentWarning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kRentCardBg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kRentDivider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '실질 비용 비교',
                style: sectionLabel.copyWith(
                    color: kRentTextSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '예금금리 3.50%',
                style:
                    textStyleCaption.copyWith(color: kRentTextTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 비교 바
          Row(
            children: [
              Expanded(
                flex: 87,
                child: _buildCostBar('전세 기회비용', '87만/월', kRentAccent),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 119,
                child: _buildCostBar('월세 실질비용', '119만/월', kRentTextSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostBar(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textStyleCaption.copyWith(color: color, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Container(
          height: 20,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
