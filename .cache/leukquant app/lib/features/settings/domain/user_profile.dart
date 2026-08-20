// lib/features/settings/domain/user_profile.dart

/// Clean domain model representing authenticated user profile.
class UserProfile {
  final String name;
  final String? email;
  final String? role;
  final String? organisation;
  final String? workspaceId;
  final bool isBackendConnected;

  const UserProfile({
    required this.name,
    this.email,
    this.role,
    this.organisation,
    this.workspaceId,
    this.isBackendConnected = false,
  });

  /// Default state when backend connection is pending
  factory UserProfile.awaitingBackend() {
    return const UserProfile(
      name: 'Security User',
      email: null,
      role: null,
      organisation: null,
      workspaceId: null,
      isBackendConnected: false,
    );
  }

  /// Parse real profile JSON from GET /api/user/profile
  factory UserProfile.fromJson(Map<String, dynamic> json, {String? fallbackEmail}) {
    final name = (json['name'] ??
            json['full_name'] ??
            json['username'] ??
            json['user'] ??
            'Security Analyst')
        .toString();

    final email = (json['email'] ?? fallbackEmail)?.toString();
    final role = (json['role'] ?? json['title'] ?? 'SOC Analyst').toString();
    final organisation = (json['organisation'] ??
            json['organization'] ??
            json['company'] ??
            json['tenant_name'] ??
            'Enterprise Workspace')
        .toString();

    final workspaceId = (json['workspace_id'] ?? json['tenant_id'] ?? 'WS-STAGING-01').toString();

    return UserProfile(
      name: name,
      email: email,
      role: role,
      organisation: organisation,
      workspaceId: workspaceId,
      isBackendConnected: true,
    );
  }
}
