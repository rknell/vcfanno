import 'dart:io';

import 'package:vcfanno_tools/gnomad_config_builder.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.length > 2) {
    _printUsageAndExit();
  }

  final inputPath = arguments[0];
  final outputPath = arguments.length == 2 ? arguments[1] : null;

  final inputFile = File(inputPath);
  if (!await inputFile.exists()) {
    stderr.writeln('Input JSON not found: $inputPath');
    exitCode = 1;
    return;
  }

  try {
    final jsonSource = await inputFile.readAsString();
    final config = buildConfigFromJson(jsonSource);

    if (outputPath == null) {
      stdout.write(config);
    } else {
      final outputFile = File(outputPath);
      await outputFile.writeAsString(config);
    }
  } on FormatException catch (error) {
    stderr.writeln('Invalid annotation JSON: ${error.message}');
    exitCode = 1;
  } on IOException catch (error) {
    stderr.writeln('I/O error: $error');
    exitCode = 1;
  }
}

Never _printUsageAndExit() {
  stderr.writeln(
      'Usage: dart run bin/build_vcfanno_config.dart <input.json> [output.conf]');
  exit(64);
}
