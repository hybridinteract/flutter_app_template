// Enforces the import boundaries described in .claude/rules/layering.md and
// the code rules in .claude/rules/performance.md that a linter cannot see.
//
// Usage: dart run tool/check_architecture.dart
// Exits with code 1 and lists every violation when a rule is broken.
import 'dart:io';

/// `package:<name>/`, read from pubspec.yaml so a renamed app needs no edit.
final _package = 'package:${_packageName()}/';
const _authPublicApi = 'features/auth/auth.dart';

/// Above this a file is doing more than one job; split it.
const _maxFileLines = 400;

/// The only file allowed to load images from the network directly.
const _networkImageWidget = 'core/widgets/app_network_image.dart';

final _directive = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');
final _rawNetworkImage = RegExp(r'\b(?:Image\.network|NetworkImage)\s*\(');
final _lineComment = RegExp(r'^\s*//');

String _packageName() {
  final pubspec = File('pubspec.yaml');
  final name = pubspec.existsSync()
      ? RegExp(
          r'^name:\s*(\S+)',
          multiLine: true,
        ).firstMatch(pubspec.readAsStringSync())?.group(1)
      : null;
  if (name == null) {
    stderr.writeln('Run from the project root (pubspec.yaml name not found).');
    exit(2);
  }
  return name;
}

void main() {
  final lib = Directory('lib');
  if (!lib.existsSync()) {
    stderr.writeln('Run from the project root (lib/ not found).');
    exit(2);
  }

  final violations = <String>[];

  final files =
      lib
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => !f.path.endsWith('.g.dart'))
          .where((f) => !_isGenerated(_relativeToLib(f.path)))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    final source = _relativeToLib(file.path);
    final lines = file.readAsLinesSync();

    if (lines.length > _maxFileLines) {
      violations.add(
        'lib/$source  has ${lines.length} lines (max $_maxFileLines); '
        'split it into smaller widgets or classes',
      );
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final location = 'lib/$source:${i + 1}';

      if (source != _networkImageWidget &&
          !_lineComment.hasMatch(line) &&
          _rawNetworkImage.hasMatch(line)) {
        violations.add(
          '$location  load network images with AppNetworkImage '
          '(cached, decoded at display size), not Image.network/NetworkImage',
        );
      }

      final match = _directive.firstMatch(line);
      if (match == null) continue;
      final uri = match.group(1)!;
      final target = _resolve(source, uri);

      for (final message in _check(source, uri, target)) {
        violations.add('$location  $message  ($uri)');
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln(
      'Architecture check passed (${files.length} files, 0 violations).',
    );
    return;
  }

  stderr.writeln(
    'Architecture check failed: ${violations.length} violation(s)',
  );
  for (final v in violations) {
    stderr.writeln('  $v');
  }
  exit(1);
}

/// Returns rule violations for one import of [source] (paths relative to lib/).
/// [target] is null for package/dart imports outside this app.
Iterable<String> _check(String source, String uri, String? target) sync* {
  final sourceFeature = _featureOf(source);
  final isController = source.contains('/controllers/');
  final isView = source.contains('/views/');

  if (target != null) {
    // 1. core/ is feature-agnostic.
    if (source.startsWith('core/') &&
        (target.startsWith('features/') || target.startsWith('app/'))) {
      yield 'core/ must not import features/ or app/';
    }

    // 2. Features only reach other features through auth's public API.
    final targetFeature = _featureOf(target);
    if (sourceFeature != null &&
        targetFeature != null &&
        sourceFeature != targetFeature &&
        target != _authPublicApi) {
      yield 'feature "$sourceFeature" must not import feature '
          '"$targetFeature" (only $_authPublicApi is shared)';
    }

    // 3. Features never depend on the composition root.
    if (sourceFeature != null && target.startsWith('app/')) {
      yield 'features must not import lib/app/';
    }

    // 4. Views talk to BLoCs only.
    if (isView &&
        (target.contains('/services/') || target.contains('/repositories/'))) {
      yield 'views must not import services or repositories';
    }

    // 5. BLoCs depend on repositories only and never resolve from GetIt.
    if (isController &&
        (target.contains('/services/') || target.startsWith('core/di/'))) {
      yield 'controllers must not import services or the service locator';
    }

    // 6. GetIt is resolved only in composition code.
    if (target.startsWith('core/di/') && !_isCompositionCode(source)) {
      yield 'getIt may only be used in main.dart, lib/app/ and *_routes.dart';
    }
  }

  if (isView && uri.startsWith('package:dio/')) {
    yield 'views must not import Dio';
  }

  if (isController &&
      (uri.startsWith('package:flutter/material') ||
          uri.startsWith('package:flutter/widgets') ||
          uri.startsWith('package:flutter/cupertino') ||
          uri.startsWith('package:material_ui/') ||
          uri.startsWith('package:cupertino_ui/') ||
          uri.startsWith('package:go_router/') ||
          uri.startsWith('package:dio/') ||
          uri.startsWith('package:get_it/'))) {
    yield 'controllers must not import Flutter UI, go_router, Dio or get_it';
  }
}

/// Output of `flutter gen-l10n`; its size is not ours to control.
bool _isGenerated(String source) => source.startsWith('core/l10n/generated/');

bool _isCompositionCode(String source) =>
    source == 'main.dart' ||
    source.startsWith('app/') ||
    source.startsWith('core/di/') ||
    source.endsWith('_routes.dart');

String? _featureOf(String path) {
  if (!path.startsWith('features/')) return null;
  final parts = path.split('/');
  return parts.length > 2 ? parts[1] : null;
}

String _relativeToLib(String path) {
  final normalized = path.replaceAll(r'\', '/');
  return normalized.substring(normalized.indexOf('lib/') + 'lib/'.length);
}

/// Resolves an import URI to a path relative to lib/, or null if external.
String? _resolve(String source, String uri) {
  if (uri.startsWith(_package)) return uri.substring(_package.length);
  if (uri.startsWith('package:') || uri.startsWith('dart:')) return null;

  final segments = source.split('/')..removeLast();
  for (final part in uri.split('/')) {
    if (part == '..') {
      if (segments.isNotEmpty) segments.removeLast();
    } else if (part != '.') {
      segments.add(part);
    }
  }
  return segments.join('/');
}
