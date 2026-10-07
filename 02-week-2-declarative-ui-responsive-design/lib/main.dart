import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Lebar layar (dalam piksel logis) mulai dari mana tampilan jadi 2 kolom.
const double kWideBreakpoint = 700;
const double kPagePadding = 16;
const double kCardSpacing = 16;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    const cards = [
      InfoCard(title: 'Assignments', value: '8', icon: Icons.assignment),
      InfoCard(title: 'Attendance', value: '92%', icon: Icons.event_available),
      InfoCard(title: 'Portfolio', value: 'Ready', icon: Icons.folder_special),
      InfoCard(title: 'Current week', value: '02', icon: Icons.calendar_month),
      InfoCard(title: 'Courses', value: '7', icon: Icons.menu_book),
      InfoCard(title: 'Semester', value: '3', icon: Icons.school),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Overview'),
        actions: [
          Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          const SizedBox(width: 4),
          Semantics(
            label: 'Mode gelap',
            child: CupertinoSwitch(value: isDark, onChanged: onDarkChanged),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;
          final cardWidth = (constraints.maxWidth -
                  kPagePadding * 2 -
                  kCardSpacing * (columns - 1)) /
              columns;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(kPagePadding),
            child: Column(
              children: [
                const ProfileHeader(),
                const SizedBox(height: kCardSpacing),
                Wrap(
                  spacing: kCardSpacing,
                  runSpacing: kCardSpacing,
                  children: [
                    for (final card in cards)
                      SizedBox(width: cardWidth, child: card),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      container: true,
      label: 'Profil mahasiswa. Nama Radita, NIM 244107020099, kelas TI-2G',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primary,
                child: Icon(Icons.person, size: 32, color: scheme.onPrimary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Radita',
                      style: textTheme.titleLarge?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'NIM 244107020099',
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                    Text(
                      'Kelas TI-2G',
                      style: TextStyle(color: scheme.onPrimaryContainer),
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

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
  });
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      label: '$title: $value',
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(title)),
                Text(value, style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}