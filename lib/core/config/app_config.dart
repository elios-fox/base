abstract final class AppConfig {
  static const String pbUrlDev = 'http://127.0.0.1:8090';
  static const String pbUrlStaging = 'https://staging-api.clubhub.nl';
  static const String pbUrlProd = 'https://api.clubhub.nl';

  static String get pbUrl {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return switch (env) {
      'prod' => pbUrlProd,
      'staging' => pbUrlStaging,
      _ => pbUrlDev,
    };
  }
}
