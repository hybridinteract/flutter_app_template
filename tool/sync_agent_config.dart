// Keeps the Antigravity agent config in sync with the Claude Code config.
//
// Source of truth: CLAUDE.md, .claude/rules/, .claude/skills/, .claude/settings.json
// Generated:       GEMINI.md, .agent/rules/, .agent/skills/, .agent/settings.json
//
// Usage:
//   dart run tool/sync_agent_config.dart          # regenerate the mirror
//   dart run tool/sync_agent_config.dart --check  # exit 1 if out of sync (/code-quality-check)
import 'dart:io';

const _generatedNotice =
    '<!-- Generated from CLAUDE.md by tool/sync_agent_config.dart. '
    'Do not edit; edit CLAUDE.md and re-run the script. -->';

void main(List<String> args) {
  final check = args.contains('--check');
  if (!File('CLAUDE.md').existsSync()) {
    stderr.writeln('Run from the project root (CLAUDE.md not found).');
    exit(2);
  }

  final expected = <String, String>{};

  // GEMINI.md from CLAUDE.md.
  final claude = File('CLAUDE.md').readAsStringSync().replaceAll('\r\n', '\n');
  final body = claude.replaceFirst(RegExp(r'^# .*\n'), '');
  expected['GEMINI.md'] = _toAgent(
    '# GEMINI.md - Antigravity Agent Guidelines\n$_generatedNotice\n$body',
  );

  // .agent/** from .claude/** (rules, skills, settings).
  for (final entry in ['rules', 'skills']) {
    final dir = Directory('.claude/$entry');
    if (!dir.existsSync()) continue;
    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      final relative = file.path
          .replaceAll(r'\', '/')
          .substring('.claude/'.length);
      expected['.agent/$relative'] = _toAgent(file.readAsStringSync());
    }
  }
  final settings = File('.claude/settings.json');
  if (settings.existsSync()) {
    expected['.agent/settings.json'] = settings.readAsStringSync();
  }

  // Files in .agent/rules|skills that no longer exist in .claude are stale.
  final stale = <String>[];
  for (final entry in ['rules', 'skills']) {
    final dir = Directory('.agent/$entry');
    if (!dir.existsSync()) continue;
    for (final file in dir.listSync(recursive: true).whereType<File>()) {
      final path = file.path.replaceAll(r'\', '/');
      if (!expected.containsKey(path)) stale.add(path);
    }
  }

  final outOfSync = <String>[
    for (final MapEntry(key: path, value: content) in expected.entries)
      if (!File(path).existsSync() ||
          _normalize(File(path).readAsStringSync()) != _normalize(content))
        path,
  ];

  if (check) {
    if (outOfSync.isEmpty && stale.isEmpty) {
      stdout.writeln('Agent config is in sync (${expected.length} files).');
      return;
    }
    stderr.writeln(
      'Agent config is out of sync. Run: dart run tool/sync_agent_config.dart',
    );
    for (final path in [...outOfSync, ...stale]) {
      stderr.writeln('  $path');
    }
    exit(1);
  }

  for (final path in outOfSync) {
    File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(expected[path]!);
    stdout.writeln('updated  $path');
  }
  for (final path in stale) {
    File(path).deleteSync();
    stdout.writeln('removed  $path');
  }
  stdout.writeln('Done: ${outOfSync.length} updated, ${stale.length} removed.');
}

/// Points Claude-specific paths at the Antigravity equivalents.
///
/// Lines that describe the sync itself ("generated from .claude/...") are kept
/// verbatim so the mirror still names the real source of truth.
String _toAgent(String text) => text
    .split('\n')
    .map(
      (line) => line.contains('sync_agent_config') || line.contains('generated')
          ? line
          : line
                .replaceAll('.claude/', '.agent/')
                .replaceAll('CLAUDE.md', 'GEMINI.md'),
    )
    .join('\n');

String _normalize(String text) => text.replaceAll('\r\n', '\n');
