import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) async => PackageInfo.fromPlatform(),
);
final deviceInfoProvider = FutureProvider<BaseDeviceInfo>(
  (ref) async => DeviceInfoPlugin().deviceInfo,
);

final deviceInfoStringProvider = FutureProvider<String>((ref) async {
  final package = await ref.watch(packageInfoProvider.future);
  final device = await ref.watch(deviceInfoProvider.future);

  final osDetails = switch (device) {
    final AndroidDeviceInfo d =>
      'Android ${d.version.release} (SDK ${d.version.sdkInt}) | '
          '${d.manufacturer} ${d.model}',

    final IosDeviceInfo d => 'iOS ${d.systemVersion} | ${d.modelName}',

    final MacOsDeviceInfo d =>
      'macOS ${d.osRelease} | ${d.computerName} | ${d.model}',

    final WindowsDeviceInfo d =>
      'Windows ${d.majorVersion}.${d.minorVersion} (build ${d.buildNumber}) '
          '| ${d.productName} | ${d.computerName}',

    final WebBrowserInfo d => '${d.browserName}',

    final LinuxDeviceInfo d =>
      'Linux ${d.version} | ${d.name} | ${d.prettyName}',

    _ => 'Unknown platform',
  };

  return '''
    App ID: ${package.packageName}
    App version: ${package.version} (${package.buildNumber})
    $osDetails'''
      .split('\n')
      .map((line) => line.trim())
      .join('\n')
      .trim();
});
