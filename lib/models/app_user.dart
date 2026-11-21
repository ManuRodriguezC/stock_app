import 'package:supabase_flutter/supabase_flutter.dart';

class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AppUser.fromSupabaseUser(User user) {
    final metadataName = user.userMetadata?['name'];

    return AppUser(
      id: user.id,
      name: metadataName is String ? metadataName : '',
      email: user.email ?? '',
    );
  }
}
