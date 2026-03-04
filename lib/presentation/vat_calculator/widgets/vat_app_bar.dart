import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';

// ──────────────────────────────────────────
// 부가세 계산기 AppBar
// ──────────────────────────────────────────
class VatAppBar extends StatelessWidget {
  final String title;
  final IconData icon;

  const VatAppBar({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.paddingAppBarH,
          vertical: AppTokens.paddingAppBarV),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  width: AppTokens.sizeAppBarIcon,
                  height: AppTokens.sizeAppBarIcon,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusAppBarIcon),
                  ),
                  child: Icon(icon,
                      color: Colors.white,
                      size: AppTokens.sizeAppBarIconInner),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTokens.fontSizeAppBarTitle,
                    fontWeight: AppTokens.weightAppBarTitle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
