import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Travel Together, Save More',
      subtitle:
          'Find affordable rides between cities and connect with neighborly travelers across Morocco.',
      badge: 'Eco-friendly',
      icon: FIcons.leaf,
    ),
    _OnboardingSlide(
      title: 'Simple & Fast Booking',
      subtitle: 'Book a seat in seconds, no hassle.',
      badge: 'Instant Booking',
      icon: FIcons.map,
    ),
    _OnboardingSlide(
      title: 'Good for the Planet',
      subtitle: 'Fewer cars, less traffic, less CO2.',
      badge: 'Renewable',
      icon: FIcons.earth,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_index < _slides.length) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _skip() {
    _controller.animateToPage(
      _slides.length,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return FScaffold(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.background, colors.muted],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FButton(
                      variant: FButtonVariant.ghost,
                      mainAxisSize: MainAxisSize.min,
                      onPress: _skip,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (value) {
                    setState(() {
                      _index = value;
                    });
                  },
                  children: [
                    for (final slide in _slides)
                      _OnboardingSlideView(
                        slide: slide,
                      ),
                    _WelcomeSlide(
                      onSignUp: () {
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      onLogin: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                child: Column(
                  children: [
                    _Indicator(
                      index: _index,
                      total: _slides.length + 1,
                    ),
                    const SizedBox(height: 16),
                    FButton(
                      variant: FButtonVariant.secondary,
                      onPress: _goNext,
                      child: Text(_index < _slides.length
                          ? 'Get Started'
                          : 'Continue'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
}

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          FCard(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [colors.muted, colors.mutedForeground],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _Badge(text: slide.badge),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: colors.muted,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(
                        slide.icon,
                        size: 60,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.foreground,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({
    required this.onSignUp,
    required this.onLogin,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              color: colors.muted,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Icon(
                FIcons.car,
                size: 64,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'RideLink',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Travel together, reduce costs,\nand see Morocco differently.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 20),
          FCard(
            child: Row(
              children: [
                Expanded(
                  child: _InfoPill(
                    icon: FIcons.shieldCheck,
                    label: 'Verified Drivers',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoPill(
                    icon: FIcons.leaf,
                    label: 'Sustainable Travel',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FButton(
            variant: FButtonVariant.secondary,
            onPress: onSignUp,
            child: const Text('Sign Up'),
          ),
          const SizedBox(height: 10),
          FButton(
            variant: FButtonVariant.outline,
            onPress: onLogin,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: 6),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 18 : 8,
          decoration: BoxDecoration(
            color: isActive ? colors.primary : colors.mutedForeground,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
