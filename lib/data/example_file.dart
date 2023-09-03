import 'package:json_annotation/json_annotation.dart';

part 'example_file.g.dart';

@JsonSerializable(explicitToJson: true)

class ExampleFile {
 
  String? type;
  String? fileName;
  String? downloadUrl;

  ExampleFile({required this.type, required this.fileName, required this.downloadUrl});

  factory ExampleFile.fromJson(Map<String, dynamic> json) => _$ExampleFileFromJson(json);
  Map<String, dynamic> toJson() => _$ExampleFileToJson(this);

}
