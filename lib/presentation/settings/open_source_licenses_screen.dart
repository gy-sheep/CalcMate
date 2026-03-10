import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_design_tokens.dart';
import '../widgets/blur_status_bar_overlay.dart';

// ── 라이선스 목록 화면 ──

class OpenSourceLicensesScreen extends StatefulWidget {
  const OpenSourceLicensesScreen({super.key});

  @override
  State<OpenSourceLicensesScreen> createState() =>
      _OpenSourceLicensesScreenState();
}

class _OpenSourceLicensesScreenState extends State<OpenSourceLicensesScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;
  final Map<String, List<LicenseEntry>> _packages = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadLicenses();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 0;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  Future<void> _loadLicenses() async {
    final Map<String, List<LicenseEntry>> packages = {};
    await for (final entry in LicenseRegistry.licenses) {
      for (final package in entry.packages) {
        packages.putIfAbsent(package, () => []).add(entry);
      }
    }
    if (mounted) {
      setState(() {
        _packages.addAll(packages);
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final sortedKeys = _packages.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('오픈소스 라이선스'),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          _loaded
              ? ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    top: statusBarHeight + kToolbarHeight,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: sortedKeys.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final package = sortedKeys[index];
                    final count = _packages[package]!.length;
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        package,
                        style: inputFieldInnerLabel
                            .copyWith(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        '$count개의 라이선스',
                        style: textStyleCaption
                            .copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => _LicenseDetailScreen(
                            packageName: package,
                            entries: _packages[package]!,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator.adaptive()),
          BlurStatusBarOverlay(
            isVisible: _isScrolled,
            backgroundColor: isDark ? Colors.black : Colors.white,
          ),
        ],
      ),
    );
  }
}

// ── 라이선스 상세 화면 ──

class _LicenseDetailScreen extends StatefulWidget {
  final String packageName;
  final List<LicenseEntry> entries;

  const _LicenseDetailScreen({
    required this.packageName,
    required this.entries,
  });

  @override
  State<_LicenseDetailScreen> createState() => _LicenseDetailScreenState();
}

class _LicenseDetailScreenState extends State<_LicenseDetailScreen> {
  final _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 0;
    if (scrolled != _isScrolled) setState(() => _isScrolled = scrolled);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.packageName),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Stack(
        children: [
          ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              16,
              statusBarHeight + kToolbarHeight + 16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: widget.entries.length,
            separatorBuilder: (_, _) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final paragraphs = widget.entries[index].paragraphs.toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final paragraph in paragraphs)
                    Padding(
                      padding: EdgeInsets.only(
                        left: paragraph.indent.clamp(0, 10) * 16.0,
                        bottom: 8,
                      ),
                      child: Text(
                        paragraph.text,
                        style: textStyleCaption.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          BlurStatusBarOverlay(
            isVisible: _isScrolled,
            backgroundColor: isDark ? Colors.black : Colors.white,
          ),
        ],
      ),
    );
  }
}
