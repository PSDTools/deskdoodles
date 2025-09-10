// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_SettingsModel', json, ($checkedConvert) {
      final val = _SettingsModel(
        themeMode: $checkedConvert(
          'themeMode',
          (v) => $enumDecode(_$ThemeModeEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SettingsModelToJson(_SettingsModel instance) =>
    <String, dynamic>{'themeMode': _$ThemeModeEnumMap[instance.themeMode]!};

const _$ThemeModeEnumMap = {
  ThemeMode.system: 'system',
  ThemeMode.light: 'light',
  ThemeMode.dark: 'dark',
};
