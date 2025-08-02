import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_models.freezed.dart';
part 'app_models.g.dart';

@freezed
class AppInfo with _$AppInfo {
  const factory AppInfo({
    required String name,
    required String icon,
    required String description,
  }) = _AppInfo;

  factory AppInfo.fromJson(Map<String, dynamic> json) => _$AppInfoFromJson(json);
}
