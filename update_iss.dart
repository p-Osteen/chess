// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:developer';
import 'dart:io';
import 'package:yaml/yaml.dart';

void main() {
  final pubspecFile = File('pubspec.yaml');
  final issFile = File('exe.iss');
  final outputDir = Directory('Output');

  if (outputDir.existsSync()) {
    log('Clearing Output folder...');
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync();
  log('Output folder cleared and recreated.');

  if (!pubspecFile.existsSync()) {
    log('Error: pubspec.yaml not found!');
    exit(1);
  }

  if (!issFile.existsSync()) {
    log('Error: exe.iss not found!');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final pubspec = loadYaml(pubspecContent);

  final appVersion = pubspec['version'] ?? '1.0.0';

  var issContent = issFile.readAsStringSync();
  issContent = issContent.replaceAll(
    RegExp(r'AppVersion=.*'),
    'AppVersion=$appVersion',
  );

  issFile.writeAsStringSync(issContent);

  log('Updated exe.iss with AppVersion=$appVersion');
}
