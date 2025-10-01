# VCFAnno Config Builder

Utilities for generating `vcfanno` configuration files from structured JSON descriptions.  The current JSON specification (`gnomad_annotation.json`) mirrors the gnomAD dataset, but the tooling is dataset-agnostic.

## Features
- JSON-driven specification of annotation files and fields.
- Dart library (`lib/gnomad_config_builder.dart`) that converts the JSON into the INI-style config that `vcfanno` expects.
- CLI entry point (`bin/build_vcfanno_config.dart`) for building configs from the command line.
- Regression test ensuring the generated config stays aligned with the checked-in reference (`test/gnomad_config.conf`).

## Getting Started
1. Install the Dart SDK (>= 3.0.0).
2. Fetch dependencies and run the unit test:
   ```bash
   dart pub get
   dart test
   ```
3. Generate a config file from the JSON spec:
   ```bash
   dart run bin/build_vcfanno_config.dart gnomad_annotation.json output.conf
   ```
   Omit `output.conf` to print the config to stdout.

## Project Layout
- `gnomad_annotation.json` – JSON specification of files and fields.
- `lib/gnomad_config_builder.dart` – core conversion logic.
- `bin/build_vcfanno_config.dart` – CLI wrapper around the builder.
- `test/gnomad_config.conf` – reference config used by the regression test.
- `test/gnomad_config_builder_test.dart` – verifies generator output matches the reference config.

## Contributing
Issues and pull requests are welcome.  Please run `dart test` before submitting changes.

## License
See [LICENSE](LICENSE) for details.
