import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      icon: Icons.eco_outlined,
    ),
    _OnboardingSlide(
      title: 'Simple & Fast Booking',
      subtitle: 'Book a seat in seconds, no hassle.',
      badge: 'Instant Booking',
      icon: Icons.map_outlined,
    ),
    _OnboardingSlide(
      title: 'Good for the Planet',
      subtitle: 'Fewer cars, less traffic, less CO2.',
      badge: 'Renewable',
      icon: Icons.public,
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.surface, colors.surfaceContainerHighest],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: _skip, child: const Text('Skip')),
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
                      _OnboardingSlideView(slide: slide),
                    _WelcomeSlide(
                      onSignUp: () {
                        context.go('/signup');
                      },
                      onLogin: () {
                        context.go('/login');
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                child: Column(
                  children: [
                    _Indicator(index: _index, total: _slides.length + 1),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _goNext,
                      child: Text(
                        _index < _slides.length ? 'Get Started' : 'Continue',
                      ),
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Card(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [colors.surfaceContainerHighest, colors.surface],
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
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(slide.icon, size: 60, color: colors.primary),
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
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  const _WelcomeSlide({required this.onSignUp, required this.onLogin});

  final VoidCallback onSignUp;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Icon(
                Icons.directions_car_filled,
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
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.verified_user_outlined,
                      label: 'Verified Drivers',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoPill(
                      icon: Icons.eco_outlined,
                      label: 'Sustainable Travel',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: onSignUp, child: const Text('Sign Up')),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onLogin, child: const Text('Login')),
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;

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
            color: isActive ? colors.primary : colors.onSurfaceVariant,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
