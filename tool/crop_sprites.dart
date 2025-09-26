#!/usr/bin/env dart

/// A simple CLI that trims transparent edges off sprite PNGs and copies the
/// cropped versions into the app's asset folder.
///
/// Usage:
///   dart run tool/crop_sprites.dart [--src <raw_dir>] [--out <output_dir>]
///
/// The script preserves the originals. By default it looks for source sprites
/// under `assets/raw_sprites` and writes cropped copies into `assets/your_room`.

import 'dart:io';

import 'package:args/args.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

const _defaultSourceDir = 'tool/raw_sprites';
const _defaultOutputDir = 'assets/your_room';
const _alphaThreshold = 10; // keep pixels with alpha above this value

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage information.',
    )
    ..addOption(
      'src',
      abbr: 's',
      help: 'Directory containing the uncropped sprites.',
      defaultsTo: _defaultSourceDir,
    )
    ..addOption(
      'out',
      abbr: 'o',
      help: 'Directory where cropped sprites should be written.',
      defaultsTo: _defaultOutputDir,
    )
    ..addFlag(
      'dry-run',
      negatable: false,
      help: 'Scan and report changes without writing any files.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      help: 'Print per-file details.',
      defaultsTo: false,
    );

  final results = parser.parse(args);
  if (results['help'] as bool) {
    stdout.writeln(parser.usage);
    return;
  }

  final srcPath = results['src'] as String;
  final outPath = results['out'] as String;
  final dryRun = results['dry-run'] as bool;
  final verbose = results['verbose'] as bool;

  final srcDir = Directory(srcPath);
  final outDir = Directory(outPath);

  if (!srcDir.existsSync()) {
    srcDir.createSync(recursive: true);
    stdout
      ..writeln('Created source directory at ${srcDir.path}.')
      ..writeln('Add your uncropped sprites there and rerun the script.');
    return;
  }

  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
    stdout.writeln('Created output directory at ${outDir.path}.');
  }

  final sourceFiles =
      srcDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (sourceFiles.isEmpty) {
    stdout.writeln('No PNG files found under ${srcDir.path}.');
    return;
  }

  var processed = 0;
  var skippedTransparent = 0;

  for (final file in sourceFiles) {
    final relativePath = p.relative(file.path, from: srcDir.path);
    final outputFile = File(p.join(outDir.path, relativePath));
    final parent = outputFile.parent;
    if (!parent.existsSync()) {
      parent.createSync(recursive: true);
    }

    final bytes = await file.readAsBytes();
    final image = img.decodePng(bytes);
    if (image == null) {
      stderr.writeln('Skipping ${file.path} (unable to decode as PNG).');
      continue;
    }

    final bounds = _trimBounds(image);
    if (bounds == null) {
      skippedTransparent++;
      if (verbose) {
        stdout.writeln('Skipping ${file.path} (fully transparent).');
      }
      continue;
    }

    final trimmed = img.copyCrop(
      image,
      x: bounds.left,
      y: bounds.top,
      width: bounds.width,
      height: bounds.height,
    );

    if (dryRun) {
      stdout.writeln(
        '[dry-run] ${file.path} -> ${outputFile.path} '
        '(${image.width}x${image.height} -> ${trimmed.width}x${trimmed.height})',
      );
      continue;
    }

    final encoded = img.encodePng(trimmed);
    await outputFile.writeAsBytes(encoded, flush: true);
    processed++;

    if (verbose) {
      stdout.writeln(
        'Cropped ${file.path} -> ${outputFile.path} '
        '(${image.width}x${image.height} -> ${trimmed.width}x${trimmed.height})',
      );
    }
  }

  stdout
    ..writeln('Finished. Wrote $processed file(s) to ${outDir.path}.')
    ..writeln('Skipped $skippedTransparent fully transparent file(s).')
    ..writeln('Use --dry-run to preview and --verbose for more detail.');
}

class _CropBounds {
  const _CropBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final int left;
  final int top;
  final int right;
  final int bottom;

  int get width => right - left + 1;
  int get height => bottom - top + 1;
}

_CropBounds? _trimBounds(img.Image image) {
  var minX = image.width;
  var minY = image.height;
  var maxX = -1;
  var maxY = -1;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final alpha = pixel.a;
      if (alpha > _alphaThreshold) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  if (maxX < minX || maxY < minY) {
    return null;
  }

  return _CropBounds(left: minX, top: minY, right: maxX, bottom: maxY);
}
