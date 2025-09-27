import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_preferences_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<UserPreferencesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        provider.loadUserPreferences('default_user'),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final preferences = provider.preferences;
          if (preferences == null) {
            return const Center(child: Text('No preferences loaded'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(context, 'Appearance', [
                _buildThemeSelector(context, provider, preferences),
                _buildLanguageSelector(context, provider, preferences),
              ]),
              const SizedBox(height: 24),
              _buildSection(context, '3D Model Settings', [
                _buildModelScaleSlider(context, provider, preferences),
                _buildAutoRotateSwitch(context, provider, preferences),
                _buildBackgroundColorSelector(context, provider, preferences),
              ]),
              const SizedBox(height: 24),
              _buildSection(context, 'About', [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Debug Info'),
                  subtitle: Text('First Launch: ${preferences.isFirstLaunch}'),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    UserPreferencesProvider provider,
    preferences,
  ) {
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Theme'),
      subtitle: Text(preferences.themeMode),
      trailing: DropdownButton<String>(
        value: preferences.themeMode,
        items: const [
          DropdownMenuItem(value: 'light', child: Text('Light')),
          DropdownMenuItem(value: 'dark', child: Text('Dark')),
          DropdownMenuItem(value: 'system', child: Text('System')),
        ],
        onChanged: (value) {
          if (value != null) {
            provider.updateThemeMode(value);
          }
        },
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    UserPreferencesProvider provider,
    preferences,
  ) {
    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: const Text('Language'),
      subtitle: Text(preferences.language),
      trailing: DropdownButton<String>(
        value: preferences.language,
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'es', child: Text('Español')),
          DropdownMenuItem(value: 'fr', child: Text('Français')),
        ],
        onChanged: (value) {
          if (value != null) {
            provider.updateLanguage(value);
          }
        },
      ),
    );
  }

  Widget _buildModelScaleSlider(
    BuildContext context,
    UserPreferencesProvider provider,
    preferences,
  ) {
    return ListTile(
      leading: const Icon(Icons.zoom_in_outlined),
      title: const Text('Default Model Scale'),
      subtitle: Slider(
        value: preferences.modelScale,
        min: 0.1,
        max: 3.0,
        divisions: 29,
        onChanged: (value) => provider.updateModelScale(value),
      ),
      trailing: Text('${preferences.modelScale.toStringAsFixed(1)}x'),
    );
  }

  Widget _buildAutoRotateSwitch(
    BuildContext context,
    UserPreferencesProvider provider,
    preferences,
  ) {
    return SwitchListTile(
      secondary: const Icon(Icons.rotate_right_outlined),
      title: const Text('Auto Rotate Models'),
      subtitle: const Text('Automatically rotate 3D models'),
      value: preferences.autoRotate,
      onChanged: (value) => provider.updateAutoRotate(value),
    );
  }

  Widget _buildBackgroundColorSelector(
    BuildContext context,
    UserPreferencesProvider provider,
    preferences,
  ) {
    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: const Text('Default Background'),
      subtitle: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Color(
                int.parse(
                  preferences.backgroundColor.replaceFirst('#', '0xFF'),
                ),
              ),
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(preferences.backgroundColor),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () =>
          _showColorPicker(context, provider, preferences.backgroundColor),
    );
  }

  void _showColorPicker(
    BuildContext context,
    UserPreferencesProvider provider,
    String currentColor,
  ) {
    final colors = [
      '#FFFFFF',
      '#000000',
      '#F5F5F5',
      '#E0E0E0',
      '#FFEBEE',
      '#E8F5E8',
      '#E3F2FD',
      '#FFF3E0',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Background Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            final isSelected = currentColor == color;
            return GestureDetector(
              onTap: () {
                provider.updateBackgroundColor(color);
                Navigator.of(context).pop();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
