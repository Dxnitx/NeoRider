/// Central backend configuration shared by every NeoRider entry point.
abstract final class NeoRiderApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'NEORIDER_API_BASE_URL',
    defaultValue: 'http://REPLACE_WITH_PC_IPV4:8002',
  );

  static Uri uri(String path) {
    if (baseUrl.contains('REPLACE_WITH_PC_IPV4')) {
      throw const FormatException(
        'Set NEORIDER_API_BASE_URL to the PC LAN address or deployed backend',
      );
    }
    return Uri.parse('${baseUrl.replaceAll(RegExp(r'/+$'), '')}$path');
  }
}
