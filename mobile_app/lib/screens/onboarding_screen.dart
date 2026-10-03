import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingSlide(this.icon, this.title, this.description);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      Icons.camera_alt_rounded,
      'Capture a Leaf',
      'Take a photo of any crop leaf, or upload one from your gallery — '
          'right from the field.',
    ),
    _OnboardingSlide(
      Icons.eco_rounded,
      'Instant Diagnosis',
      'Get the disease name and severity stage (G0–G3) in seconds, '
          'grounded in real plant pathology.',
    ),
    _OnboardingSlide(
      Icons.medical_services_rounded,
      'Treatment Guidance',
      'Receive specific treatment and prevention steps, plus an AI '
          'assistant for follow-up questions.',
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: Logo  |  Theme Toggle  |  Skip ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  // ── App Logo (theme-aware) ────────────────────────────────
                  Image.asset(
                    isDark
                        ? 'assets/images/logo_dark.png'
                        : 'assets/images/logo_light.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                    semanticLabel: 'CropVision Logo',
                  ),
                  const Spacer(),
                  // ── Premium Theme Toggle ────────────────────────────────
                  _ThemeToggle(
                    isDark: isDark,
                    onToggle: () => themeProvider.toggleTheme(),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: _finishOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),


            // ── Slides ────────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon container with soft gradient glow
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.14),
                                colorScheme.primary.withValues(alpha: 0.0),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: isDark ? 0.30 : 0.20),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 68,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          slide.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.55,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Dot indicators ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 24),
                  width: i == _currentPage ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // ── CTA Button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isLastPage
                      ? _finishOnboarding
                      : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                          ),
                  child: Text(isLastPage ? 'Get Started' : 'Next'),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium animated theme toggle widget
// ─────────────────────────────────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    // Design tokens
    final trackColorDark = const Color(0xFF1C2A2C);
    final trackColorLight = const Color(0xFFE8F5E9);
    final thumbColorDark = const Color(0xFF8CFF3B);
    final thumbColorLight = const Color(0xFF237A3B);
    final borderColorDark = const Color(0xFF8CFF3B).withValues(alpha: 0.35);
    final borderColorLight = const Color(0xFF237A3B).withValues(alpha: 0.30);

    const toggleW = 68.0;
    const toggleH = 32.0;
    const thumbSize = 24.0;
    const thumbPad = 4.0;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        width: toggleW,
        height: toggleH,
        padding: const EdgeInsets.all(thumbPad),
        decoration: BoxDecoration(
          color: isDark ? trackColorDark : trackColorLight,
          borderRadius: BorderRadius.circular(toggleH / 2),
          border: Border.all(
            color: isDark ? borderColorDark : borderColorLight,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0xFF8CFF3B).withValues(alpha: 0.12)
                  : const Color(0xFF237A3B).withValues(alpha: 0.10),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Sun icon (left side, visible in dark mode → switch to light)
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isDark ? 1.0 : 0.0,
                child: const SizedBox(
                  width: thumbSize,
                  height: thumbSize,
                  child: Icon(
                    Icons.wb_sunny_rounded,
                    size: 14,
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ),
            ),
            // Moon icon (right side, visible in light mode → switch to dark)
            Positioned(
              right: 0,
              top: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isDark ? 0.0 : 1.0,
                child: SizedBox(
                  width: thumbSize,
                  height: thumbSize,
                  child: Icon(
                    Icons.nights_stay_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF8CFF3B) : const Color(0xFF237A3B),
                  ),
                ),
              ),
            ),
            // Animated thumb pill
            AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOutCubic,
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  color: isDark ? thumbColorDark : thumbColorLight,
                  borderRadius: BorderRadius.circular(thumbSize / 2),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0xFF8CFF3B).withValues(alpha: 0.45)
                          : const Color(0xFF237A3B).withValues(alpha: 0.30),
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
                  size: 14,
                  color: isDark ? const Color(0xFF10181A) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

