import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:gms_location_settings_dialog/gms_location_settings_dialog.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GMS Location Settings Dialog — Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
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
  final _plugin = GmsLocationSettingsDialog();

  _Status _status = _Status.idle;

  Future<void> _showDialog() async {
    setState(() => _status = _Status.loading);

    final enabled = await _plugin.show();

    setState(() => _status = enabled ? _Status.enabled : _Status.disabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Dialog Example'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusCard(status: _status),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _status == _Status.loading ? null : _showDialog,
              icon: _status == _Status.loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.location_on),
              label: Text(
                _status == _Status.loading
                    ? 'Waiting for response...'
                    : 'Show GPS Settings Dialog',
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => setState(() => _status = _Status.idle),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
            const SizedBox(height: 40),
            _PlatformNote(),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final _Status status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, label, bgColor) = switch (status) {
      _Status.idle => (
          Icons.location_searching,
          'Tap the button to show the dialog',
          theme.colorScheme.surfaceContainerHighest,
        ),
      _Status.loading => (
          Icons.hourglass_top,
          'Dialog is open...',
          theme.colorScheme.surfaceContainerHighest,
        ),
      _Status.enabled => (
          Icons.location_on,
          'Location services ENABLED',
          Colors.green.shade50,
        ),
      _Status.disabled => (
          Icons.location_off,
          'Location services DISABLED',
          Colors.red.shade50,
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: switch (status) {
              _Status.enabled => Colors.green,
              _Status.disabled => Colors.red,
              _ => theme.colorScheme.onSurfaceVariant,
            },
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: theme.colorScheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              Platform.isAndroid
                  ? 'Android: shows the GMS in-app GPS toggle dialog via ResolvableApiException.'
                  : 'iOS: no in-app dialog available. Returns current CLLocationManager.locationServicesEnabled() value only.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Status { idle, loading, enabled, disabled }
