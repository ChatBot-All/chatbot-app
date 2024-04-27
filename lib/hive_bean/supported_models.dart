import 'package:hive/hive.dart';

part 'supported_models.g.dart';

@HiveType(typeId: 6)
class SupportedModels {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? ownedBy;

  SupportedModels({
    this.id,
    this.ownedBy,
  });

  factory SupportedModels.fromMap(Map<String, dynamic> json) {
    return SupportedModels(
      id: json['id'],
      ownedBy: json['owned_by'],
    );
  }
}
