import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'theme/ride_link_theme.dart';

void main() {
  runApp(const RideLinkApp());
}

class RideLinkApp extends StatelessWidget {
  const RideLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// Try changing this and hot reloading the application.
    ///
    /// To create a custom theme:
    /// ```shell
    /// dart forui theme create [theme template].
    /// ```
    final lightTheme = RideLinkTheme.light;
    final darkTheme = RideLinkTheme.dark;

    return MaterialApp(
      // TODO: replace with your application's supported locales.
      supportedLocales: FLocalizations.supportedLocales,
      // TODO: add your application's localizations delegates.
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      // MaterialApp's theme is also animated by default with the same duration and curve.
      // See https://api.flutter.dev/flutter/material/MaterialApp/themeAnimationStyle.html for how to configure this.
      //
      // There is a known issue with implicitly animated widgets where their transition occurs AFTER the theme's.
      // See https://github.com/duobaseio/forui/issues/670.
      theme: lightTheme.toApproximateMaterialTheme(),
      darkTheme: darkTheme.toApproximateMaterialTheme(),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        final fTheme = Theme.of(context).brightness == Brightness.dark
            ? darkTheme
            : lightTheme;
        return FTheme(
          data: fTheme,
          child: FToaster(child: FTooltipGroup(child: child!)),
        );
      },
      // You can also replace FScaffold with Material Scaffold.
      home: const FScaffold(child: Example()),
    );
  }
}

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: .min,
      spacing: 20,
      children: [
        FAvatar(
          size: 40.0,
          image: const NetworkImage('https://example.com/avatar.png'),
        ),
        Text('Count: $_count'),
        FButton(
          onPress: () => setState(() => _count++),
          suffix: const Icon(FIcons.chevronsUp),
          child: const Text('Increase'),
        ),
        FCard(
          image: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const NetworkImage('https://example.com/avatar.png'),
                fit: .cover,
              ),
            ),
            height: 200,
          ),
          title: const Text('Gratitude'),
          subtitle: const Text(
            'The quality of being thankful; readiness to show appreciation for and to return kindness.',
          ),
        ),
        FLineCalendar(
          control: .managed(initial: .now().subtract(const Duration(days: 1))),
        ),
        FButton(
          suffix: const Icon(FIcons.triangleAlert),
          onPress: () => showFToast(
            context: context,
            duration: Duration(seconds: 2),
            icon: const Icon(FIcons.triangleAlert),
            title: const Text('Event start time cannot be earlier than 8am'),
          ),
          child: const Text('Show Toast'),
        ),
      ],
    ),
  );
}
