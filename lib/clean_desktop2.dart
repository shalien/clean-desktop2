import 'dart:io';

void cleanDesktop() async {
  var pathList = <String>[];

  pathList.addAll(await _getDesktopShortcut());
  pathList.addAll(await _getPublicShortcut());

  pathList.forEach(_moveShortcut);
}

Future<List<String>> _getDesktopShortcut() async {
  final userHomePath = userHome;

  final userDesktopPath = _getDesktopPath(userHomePath);

  return await Directory(userDesktopPath)
      .list()
      .where(_isShortcut)
      .map((x) => x.path.toString())
      .toList();
}

Future<List<String>> _getPublicShortcut() async {
  final publicPath = Platform.isWindows ? Platform.environment['PUBLIC'] : null;

  final publicDesktopPath = _getDesktopPath(publicPath);

  return await Directory(publicDesktopPath)
      .list()
      .where(_isShortcut)
      .map((x) => x.path.toString())
      .toList();
}

bool _isShortcut(FileSystemEntity fileSystemEntity) {
  return fileSystemEntity.path.endsWith('.url') ||
      fileSystemEntity.path.endsWith('.lnk') ||
      fileSystemEntity.path.endsWith('.appref-ms');
}

void _moveShortcut(String origin) async {
  final originFile = File(origin);
  final originFileName = originFile.path.split(Platform.pathSeparator).last;
  final firstChar = originFileName.substring(0, 1).toUpperCase();

  final userHomeDesktopFolder = _getDesktopPath(userHome);

  final userHomeDesktopAppsFolderPath =
      '$userHomeDesktopFolder${Platform.pathSeparator}Apps';

  final userHomeDesktopAppsFolder = Directory(userHomeDesktopAppsFolderPath);

  if (!await userHomeDesktopAppsFolder.exists()) {
    await userHomeDesktopAppsFolder.create();
  }

  final userHomeDesktopAppFirstPath = num.tryParse(firstChar) != null
      ? '$userHomeDesktopAppsFolderPath${Platform.pathSeparator}#'
      : '$userHomeDesktopAppsFolderPath${Platform.pathSeparator}$firstChar';

  final userHomeDesktopAppsFirstFolder = Directory(userHomeDesktopAppFirstPath);

  if (!await userHomeDesktopAppsFirstFolder.exists()) {
    await userHomeDesktopAppsFirstFolder.create();
  }

  await originFile
      .rename(
          '$userHomeDesktopAppFirstPath${Platform.pathSeparator}${_sanitizeName(originFileName)}')
      .then((file) => print('$originFileName moved to ${file.path}'));
}

String _sanitizeName(String name) => name.replaceAll(' - Raccourci', '');

String get userHome => Platform.isWindows
    ? Platform.environment['USERPROFILE']
    : Platform.environment['USERHOME'];

String _getDesktopPath(String base) => '$base${Platform.pathSeparator}Desktop';
