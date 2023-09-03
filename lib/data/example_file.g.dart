// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExampleFile _$ExampleFileFromJson(Map<String, dynamic> json) => ExampleFile(
      type: json['type'] as String?,
      fileName: json['fileName'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
    );

Map<String, dynamic> _$ExampleFileToJson(ExampleFile instance) =>
    <String, dynamic>{
      'type': instance.type,
      'fileName': instance.fileName,
      'downloadUrl': instance.downloadUrl,
    };
