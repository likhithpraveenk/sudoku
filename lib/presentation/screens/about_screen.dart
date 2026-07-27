import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/providers/info_provider.dart';
import 'package:url_launcher/url_launcher.dart';

const githubLink = 'https://github.com/likhithpraveenk/sudoku';
const githubIssueLink = '$githubLink/issues/new';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final packageInfo = ref.watch(packageInfoProvider).value;
    final deviceInfo = ref.watch(deviceInfoStringProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Image.asset(
                'assets/icons/icon.png',
                width: 120,
                height: 120,
                color: scheme.onSurface,
              ),
              ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Version'),
                subtitle: Text(
                  '${packageInfo?.version} (${packageInfo?.buildNumber})',
                ),
              ),
              ListTile(
                title: const Text('Licenses'),
                leading: const Icon(Icons.gavel_outlined),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Sudoku',
                  applicationLegalese:
                      'Licensed under the GNU General Public License v3.0 or later',
                  applicationVersion: '${packageInfo?.version}',
                ),
              ),
              ListTile(
                title: const Text('Source Code'),
                leading: const Icon(Icons.open_in_new),
                onTap: () => launchUrlHelper(context, githubLink),
              ),

              ListTile(
                title: const Text('Found a bug?'),
                subtitle: const Text(
                  'Open a GitHub issue for any bug you encountered',
                ),
                leading: const Icon(Icons.feedback_outlined),
                onTap: () async {
                  await launchUrlHelper(context, githubIssueLink);
                },
              ),
              const Spacer(),
              Container(
                alignment: .bottomCenter,
                padding: const .all(24),
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    if (deviceInfo != null)
                      SelectableText(
                        deviceInfo,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: .min,
                      children: [
                        const Text('Built with '),
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: scheme.errorContainer,
                        ),
                        const Text(' in Flutter'),
                      ],
                    ),
                    SizedBox(height: MediaQuery.paddingOf(context).bottom),
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

Future<void> launchUrlHelper(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: .externalApplication) && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
  }
}
