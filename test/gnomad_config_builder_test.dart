import 'dart:io';

import 'package:test/test.dart';
import 'package:vcfanno_tools/gnomad_config_builder.dart';

void main() {
  test('generated config matches current gnomad_config.conf', () async {
    final jsonSource = await File('gnomad_annotation.json').readAsString();
    final expected = await File('test/gnomad_config.conf').readAsString();
    final generated = buildConfigFromJson(jsonSource);
    expect(generated, expected);
  });
}
