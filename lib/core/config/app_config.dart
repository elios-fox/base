abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xhnorfsckgdbrdxsrbjp.supabase.co',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhobm9yZnNja2dkYnJkeHNyYmpwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM5MTkxNTUsImV4cCI6MjA4OTQ5NTE1NX0.V34Q6rLeoguL5ybVDmgokHbzh9U76oAWjYRtUhKXYX0',
  );
}
