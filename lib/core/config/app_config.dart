abstract final class AppConfig {
  static const String supabaseUrlDev = 'http://127.0.0.1:54321';
  static const String supabaseUrlStaging = 'https://your-project.supabase.co';
  static const String supabaseUrlProd = 'https://your-project.supabase.co';

  static const String supabaseAnonKeyDev = 'your-dev-anon-key';
  static const String supabaseAnonKeyStaging = 'your-staging-anon-key';
  static const String supabaseAnonKeyProd = 'your-prod-anon-key';

  static const _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static String get supabaseUrl {
    switch (_env) {
      case 'prod':
        return supabaseUrlProd;
      case 'staging':
        return supabaseUrlStaging;
      default:
        return supabaseUrlDev;
    }
  }

  static String get supabaseAnonKey {
    switch (_env) {
      case 'prod':
        return supabaseAnonKeyProd;
      case 'staging':
        return supabaseAnonKeyStaging;
      default:
        return supabaseAnonKeyDev;
    }
  }
}
