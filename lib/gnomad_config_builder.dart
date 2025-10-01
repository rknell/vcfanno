import 'dart:convert';

/// Represents a parsed configuration describing the gnomAD annotations.
class GnomadAnnotationSpec {
  GnomadAnnotationSpec({
    required this.files,
    required this.fields,
    required this.defaultOps,
    required this.defaultPrefix,
  });

  factory GnomadAnnotationSpec.fromJson(Map<String, dynamic> json) {
    final files = List<String>.from(json['files'] as List? ?? const []);
    if (files.isEmpty) {
      throw FormatException('`files` must contain at least one entry.');
    }

    final fieldMaps = List<Map<String, dynamic>>.from(
      (json['fields'] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map)),
    );
    if (fieldMaps.isEmpty) {
      throw FormatException('`fields` must contain at least one field.');
    }

    final defaultOps = json['default_ops'] as String? ?? 'self';
    final defaultPrefix = json['default_prefix'] as String? ?? '';

    final fields = fieldMaps
        .map(
          (raw) => FieldSpec(
            name: raw['name'] as String? ??
                (throw FormatException('Each field requires a `name` value.')),
            op: raw['ops'] as String?,
            alias: raw['alias'] as String?,
          ),
        )
        .toList(growable: false);

    return GnomadAnnotationSpec(
      files: files,
      fields: fields,
      defaultOps: defaultOps,
      defaultPrefix: defaultPrefix,
    );
  }

  final List<String> files;
  final List<FieldSpec> fields;
  final String defaultOps;
  final String defaultPrefix;
}

/// Represents a single annotation field mapping.
class FieldSpec {
  FieldSpec({required this.name, this.op, this.alias});

  final String name;
  final String? op;
  final String? alias;
}

/// Builds the configuration text for vcfanno using the provided JSON payload.
String buildConfigFromJson(String jsonSource) {
  final data = jsonDecode(jsonSource) as Map<String, dynamic>;
  final spec = GnomadAnnotationSpec.fromJson(data);
  return buildConfig(spec);
}

/// Builds the configuration text for vcfanno using an already parsed spec.
String buildConfig(GnomadAnnotationSpec spec) {
  final fields = spec.fields
      .map(
        (field) => _ResolvedField(
          name: field.name,
          op: field.op ?? spec.defaultOps,
          alias: field.alias ?? _aliasFromName(spec.defaultPrefix, field.name),
        ),
      )
      .toList(growable: false);

  final fieldNames = fields.map((field) => field.name).toList(growable: false);
  final ops = fields.map((field) => field.op).toList(growable: false);
  final aliases = fields.map((field) => field.alias).toList(growable: false);

  final fieldsLine = 'fields=${_formatList(fieldNames)}';
  final opsLine = 'ops=${_formatList(ops)}';
  final namesLine = 'names=${_formatList(aliases)}';

  final buffer = StringBuffer();
  for (var i = 0; i < spec.files.length; i++) {
    final file = spec.files[i];
    buffer.writeln('[[annotation]]');
    buffer.writeln('file="$file"');
    buffer.writeln(fieldsLine);
    buffer.writeln(opsLine);
    buffer.writeln(namesLine);
    if (i != spec.files.length - 1) {
      buffer.writeln();
    }
  }

  // Ensure the file terminates with a newline.
  if (!buffer.toString().endsWith('\n')) {
    buffer.writeln();
  }

  return buffer.toString();
}

String _formatList(List<String> values) {
  final quoted = values.map((value) => '"$value"').join(', ');
  return '[$quoted]';
}

String _aliasFromName(String prefix, String name) {
  final lower = name.toLowerCase();
  if (prefix.isEmpty) {
    return lower;
  }
  return '${prefix}_$lower';
}

class _ResolvedField {
  _ResolvedField({required this.name, required this.op, required this.alias});

  final String name;
  final String op;
  final String alias;
}
