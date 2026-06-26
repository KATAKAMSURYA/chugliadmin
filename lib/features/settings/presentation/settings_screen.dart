import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../../../core/providers/firebase_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _maintenanceMode;
  double? _reportThreshold;
  double? _maxParticipants;
  bool _isSaving = false;
  bool _saveSuccess = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final db = ref.watch(firestoreProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Configure global app behaviour. Changes are saved to Firestore instantly.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            settingsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(64),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(
                child: Text('Error loading settings: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
              data: (settings) {
                // Init local state from Firestore once
                _maintenanceMode ??= settings.maintenanceMode;
                _reportThreshold ??= settings.reportThreshold.toDouble();
                _maxParticipants ??= settings.maxParticipants.toDouble();

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F1F),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF353534)),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Global Configuration',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 32),

                      // ── Maintenance Mode ──
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _maintenanceMode!
                              ? Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: 0.05)
                              : const Color(0xFF131313),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _maintenanceMode!
                                ? Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withValues(alpha: 0.3)
                                : const Color(0xFF353534),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _maintenanceMode!
                                    ? Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withValues(alpha: 0.1)
                                    : const Color(0xFF353534),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.build_outlined,
                                  color: _maintenanceMode!
                                      ? Theme.of(context).colorScheme.error
                                      : const Color(0xFF8F909E)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Maintenance Mode',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                    _maintenanceMode!
                                        ? '⚠ App is currently in maintenance mode — users cannot access it.'
                                        : 'App is live and accessible to all users.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: _maintenanceMode!
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .error
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _maintenanceMode!,
                              activeThumbColor: Theme.of(context).colorScheme.error,
                              onChanged: (v) =>
                                  setState(() => _maintenanceMode = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Report Threshold ──
                      _SettingSlider(
                        icon: Icons.report_problem_outlined,
                        title: 'Auto-ban Report Threshold',
                        subtitle:
                            'Users are auto-banned from a room if reported by more than ${_reportThreshold!.toInt()} unique users.',
                        value: _reportThreshold!,
                        min: 1,
                        max: 20,
                        divisions: 19,
                        accentColor:
                            Theme.of(context).colorScheme.primary,
                        onChanged: (v) =>
                            setState(() => _reportThreshold = v),
                      ),
                      const SizedBox(height: 24),

                      // ── Max Participants ──
                      _SettingSlider(
                        icon: Icons.people_outline,
                        title: 'Max Participants per Room',
                        subtitle:
                            'Limit the maximum number of users per room to ${_maxParticipants!.toInt()}.',
                        value: _maxParticipants!,
                        min: 10,
                        max: 500,
                        divisions: 49,
                        accentColor:
                            Theme.of(context).colorScheme.secondary,
                        onChanged: (v) =>
                            setState(() => _maxParticipants = v),
                      ),
                      const SizedBox(height: 40),

                      // ── Save Button ──
                      if (_saveSuccess)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary),
                              const SizedBox(width: 8),
                              Text(
                                'Settings saved successfully to Firestore!',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _maintenanceMode = settings.maintenanceMode;
                                _reportThreshold =
                                    settings.reportThreshold.toDouble();
                                _maxParticipants =
                                    settings.maxParticipants.toDouble();
                                _saveSuccess = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Color(0xFF353534)),
                            ),
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: _isSaving
                                ? null
                                : () async {
                                    setState(() {
                                      _isSaving = true;
                                      _saveSuccess = false;
                                    });
                                    await saveSettings(
                                      db,
                                      AppSettings(
                                        maintenanceMode: _maintenanceMode!,
                                        reportThreshold:
                                            _reportThreshold!.toInt(),
                                        maxParticipants:
                                            _maxParticipants!.toInt(),
                                      ),
                                    );
                                    if (mounted) {
                                      setState(() {
                                        _isSaving = false;
                                        _saveSuccess = true;
                                      });
                                    }
                                  },
                            child: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text('Save Settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSlider extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color accentColor;
  final ValueChanged<double> onChanged;

  const _SettingSlider({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.accentColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF353534)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toInt().toString(),
                  style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: accentColor,
            inactiveColor: const Color(0xFF353534),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
