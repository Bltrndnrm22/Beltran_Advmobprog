import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

class ThemeModel extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggleTheme(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeModel>().isDark;
    return MaterialApp(
      title: 'Ephemeral vs. App State',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  void _resetCounter() {
    setState(() => _counter = 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management'),
        actions: const [ThemeSwitch(), SizedBox(width: 12)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ephemeral vs. App State',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('One local counter. One shared theme.'),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.touch_app_outlined, size: 32),
                          const SizedBox(height: 12),
                          const Text('You have pressed the button this many times:'),
                          const SizedBox(height: 12),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              '$_counter',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(color: colors.primary),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              FilledButton.icon(
                                onPressed: _incrementCounter,
                                icon: const Icon(Icons.add),
                                label: const Text('Increment'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _counter == 0 ? null : _resetCounter,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Local state: setState updates the counter on this page.\n\n'
                    'App state: Provider shares the light/dark theme across '
                    'the application. Changing themes preserves the counter.',
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DetailsPage(),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('See the shared theme on another page'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeModel>().isDark;
    return Tooltip(
      message: 'Dark mode',
      child: Switch(
        value: isDark,
        onChanged: (value) => context.read<ThemeModel>().toggleTheme(value),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared App State'),
        actions: const [ThemeSwitch(), SizedBox(width: 12)],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Text(
            'This page uses the same ThemeModel as the counter page. '
            'Toggle the switch, then go back: both pages share the theme, '
            'and the counter retains its value while its State object exists.',
          ),
        ),
      ),
    );
  }
}
