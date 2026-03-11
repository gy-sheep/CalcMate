import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_design_tokens.dart';
import '../dutch_pay_colors.dart';

// ── 공유 데이터 sealed class ────────────────────────────────

sealed class ShareData {
  const ShareData();
}

class EqualShareData extends ShareData {
  final int totalAmount;
  final int people;
  final int rounded;
  final int organizer;
  final bool isEven;
  final bool isKorea;
  final double tipRate;
  final double perPersonWithTip;

  const EqualShareData({
    required this.totalAmount,
    required this.people,
    required this.rounded,
    required this.organizer,
    required this.isEven,
    required this.isKorea,
    required this.tipRate,
    required this.perPersonWithTip,
  });
}

class IndividualShareData extends ShareData {
  final int totalAmount;
  final List<String> participants;
  final List<int> personAmounts;
  final List<List<String>> personMenus;

  const IndividualShareData({
    required this.totalAmount,
    required this.participants,
    required this.personAmounts,
    required this.personMenus,
  });
}

// ── 공유 바텀시트 ────────────────────────────────────────────

class ShareSheet extends StatefulWidget {
  const ShareSheet({super.key, required this.shareData});
  final ShareData shareData;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  final _receiptKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 영수증 미리보기
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: RepaintBoundary(
              key: _receiptKey,
              child: _ReceiptWidget(data: widget.shareData),
            ),
          ),
          const SizedBox(height: 24),
          // 공유 버튼
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 0, 24, MediaQuery.of(context).padding.bottom + 24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _sharing ? null : _share,
                  child: AnimatedContainer(
                    duration: durationAnimDefault,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _sharing
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFFF48FB1), kDutchAccent]),
                      color: _sharing ? kDutchDivider : null,
                      borderRadius:
                          BorderRadius.circular(radiusCard),
                    ),
                    child: Center(
                      child: _sharing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: kDutchAccent),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share_outlined,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('공유하기',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text('닫기',
                      style: modalButtonLabel.copyWith(
                          color: kDutchTextTertiary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    try {
      final boundary = _receiptKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/dutch_pay_receipt.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'CalcMate 더치페이 결과',
        sharePositionOrigin: origin,
      );
    } catch (e, st) {
      debugPrint('Share error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공유 오류: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

// ── 영수증 위젯 ──────────────────────────────────────────────

class _ReceiptWidget extends StatelessWidget {
  const _ReceiptWidget({required this.data});
  final ShareData data;

  String _fmt(int n) {
    if (n == 0) return '0';
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String get _today {
    final now = DateTime.now();
    return '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ReceiptClipper(),
      child: Container(
        color: kDutchReceiptBg,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        child: Column(
          children: [
            // 헤더
            Text('CalcMate',
                style: TextStyle(
                    color: kDutchAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5)),
            const SizedBox(height: 16),
            _DashedDivider(),
            const SizedBox(height: 12),
            // 본문
            ..._buildRows(),
            const SizedBox(height: 12),
            _DashedDivider(),
            const SizedBox(height: 12),
            // 날짜
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_today,
                    style: TextStyle(
                        color: kDutchTextTertiary, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRows() {
    return switch (data) {
      EqualShareData d => _buildEqualRows(d),
      IndividualShareData d => _buildIndividualRows(d),
    };
  }

  List<Widget> _buildEqualRows(EqualShareData d) {
    return [
      _Row(label: '총 금액', value: '${_fmt(d.totalAmount)}원'),
      _Row(label: '인원', value: '${d.people}명'),
      if (!d.isKorea && d.tipRate > 0)
        _Row(label: '팁', value: '${d.tipRate.toStringAsFixed(0)}%'),
      const SizedBox(height: 12),
      _DashedDivider(),
      const SizedBox(height: 12),
      if (d.isKorea && d.isEven)
        _Row(
            label: '1인당',
            value: '${_fmt(d.rounded)}원',
            highlight: true)
      else if (d.isKorea) ...[
        _Row(
            label: '참여자 ${d.people - 1}명',
            value: '${_fmt(d.rounded)}원'),
        _Row(
            label: '계산한 사람',
            value: '${_fmt(d.organizer)}원',
            highlight: true),
      ] else
        _Row(
            label: '1인당',
            value: '${_fmt(d.perPersonWithTip.round())}원',
            highlight: true),
    ];
  }

  List<Widget> _buildIndividualRows(IndividualShareData d) {
    return [
      _Row(label: '총 금액', value: '${_fmt(d.totalAmount)}원'),
      _Row(label: '인원', value: '${d.participants.length}명'),
      const SizedBox(height: 12),
      _DashedDivider(),
      const SizedBox(height: 12),
      ...d.participants.asMap().entries.map((e) {
        final menus = d.personMenus[e.key];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.value,
                      style: TextStyle(
                          color: kDutchTextSecondary, fontSize: 13)),
                  Text('${_fmt(d.personAmounts[e.key])}원',
                      style: const TextStyle(
                          color: kDutchTextPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              if (menus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    menus.join(', '),
                    style: TextStyle(
                        color: kDutchTextTertiary, fontSize: 11),
                  ),
                ),
            ],
          ),
        );
      }),
    ];
  }
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.label, required this.value, this.highlight = false});
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: kDutchTextSecondary, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: highlight ? kDutchAccent : kDutchTextPrimary,
                  fontSize: 13,
                  fontWeight: highlight
                      ? FontWeight.w700
                      : FontWeight.w500)),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedPainter(),
    );
  }
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kDutchReceiptDash
      ..strokeWidth = 1;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ReceiptClipper extends CustomClipper<Path> {
  static const _radius = 5.0;
  static const _gap = 6.0;

  @override
  Path getClip(Size size) {
    final segmentWidth = _radius * 2 + _gap;
    final count = (size.width / segmentWidth).floor();
    final totalWidth = count * _radius * 2 + (count - 1) * _gap;
    final margin = (size.width - totalWidth) / 2;

    final path = Path();

    // 상단 스캘럽
    path.moveTo(0, _radius);
    path.lineTo(margin, _radius);
    for (int i = 0; i < count; i++) {
      final x = margin + i * segmentWidth;
      path.arcToPoint(
        Offset(x + _radius * 2, _radius),
        radius: const Radius.circular(_radius),
        clockwise: false,
      );
      if (i < count - 1) {
        path.lineTo(x + _radius * 2 + _gap, _radius);
      }
    }
    path.lineTo(size.width, _radius);

    // 오른쪽 변
    path.lineTo(size.width, size.height - _radius);

    // 하단 스캘럽
    path.lineTo(size.width - margin, size.height - _radius);
    for (int i = count - 1; i >= 0; i--) {
      final x = margin + i * segmentWidth;
      path.arcToPoint(
        Offset(x, size.height - _radius),
        radius: const Radius.circular(_radius),
        clockwise: false,
      );
      if (i > 0) {
        path.lineTo(x - _gap, size.height - _radius);
      }
    }
    path.lineTo(0, size.height - _radius);

    // 왼쪽 변
    path.lineTo(0, _radius);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}
