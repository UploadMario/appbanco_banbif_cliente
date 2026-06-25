class SupabaseConfig {
  // Compatibilidad temporal no critica. El flujo evaluable usa Core FastAPI.
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
