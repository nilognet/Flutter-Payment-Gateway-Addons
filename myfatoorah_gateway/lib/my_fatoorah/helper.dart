import 'package:myfatoorah_flutter/utils/MFCountry.dart';
dynamic get(dynamic data, List<dynamic> paths, [defaultValue]) {
  if (data == null || (paths.isNotEmpty && !(data is Map || data is List))) return defaultValue;
  if (paths.isEmpty) return data ?? defaultValue;
  List<dynamic> newPaths = List.of(paths);
  String? key = newPaths.removeAt(0);
  return get(data[key], newPaths, defaultValue);
}
class FatoorahHelper {
  static MFCountry codeToCountry(String code) {
    switch (code) {
      case "KWT":
        return MFCountry.KUWAIT;
      case "SAU":
        return MFCountry.SAUDI_ARABIA;
      case "BHR":
        return MFCountry.BAHRAIN;
      case "ARE":
        return MFCountry.UNITED_ARAB_EMIRATES;
      case "QAT":
        return MFCountry.QATAR;
      case "OMN":
        return MFCountry.OMAN;
      case "JOD":
        return MFCountry.JORDAN;
      case "EGY":
        return MFCountry.EGYPT;
      default:
        return MFCountry.KUWAIT;
    }
  }
}
