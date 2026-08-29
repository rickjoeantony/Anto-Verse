// lib/features/settings/domain/user_profile.dart

/// Clean domain model representing authenticated user profile.
class UserProfile {
  final String id;
  final String name;
  final String? email;
  final String? avatar;
  final String plan; // 'starter' | 'growth' | 'enterprise' | 'admin'
  final String? organisation;
  final String? workspaceId;
  final bool isBackendConnected;

  const UserProfile({
    this.id = '',
    required this.name,
    this.email,
    this.avatar,
    required this.plan,
    this.organisation,
    this.workspaceId,
    this.isBackendConnected = false,
  });

  /// Alias for backward compatibility with existing views
  String get role => plan;

  /// Human-readable Plan label for UI display
  String get planDisplayName {
    switch (plan.toLowerCase()) {
      case 'enterprise':
        return 'Enterprise Plan';
      case 'growth':
        return 'Growth Plan';
      case 'starter':
        return 'Starter Plan';
      case 'admin':
        return 'Enterprise Admin';
      default:
        return '${plan[0].toUpperCase()}${plan.substring(1)} Plan';
    }
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? plan,
    String? organisation,
    String? workspaceId,
    bool? isBackendConnected,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      plan: plan ?? this.plan,
      organisation: organisation ?? this.organisation,
      workspaceId: workspaceId ?? this.workspaceId,
      isBackendConnected: isBackendConnected ?? this.isBackendConnected,
    );
  }

  /// Default state when backend connection is pending
  factory UserProfile.awaitingBackend() {
    return const UserProfile(
      id: '',
      name: 'Security User',
      email: null,
      avatar: 'shield',
      plan: 'growth',
      organisation: 'Leukquant Enterprise',
      workspaceId: null,
      isBackendConnected: false,
    );
  }

  /// Parse real profile JSON from GET /api/user/profile or login response user object
  factory UserProfile.fromJson(Map<String, dynamic> json, {String? fallbackEmail}) {
    final id = (json['id'] ?? json['user_id'] ?? json['uuid'] ?? '').toString();

    final name = (json['name'] ??
            json['full_name'] ??
            json['username'] ??
            json['user'] ??
            'Security Analyst')
        .toString();

    final email = (json['email'] ?? fallbackEmail)?.toString();
    final avatar = json['avatar']?.toString() ?? json['avatar_url']?.toString() ?? 'shield';

    final rawPlan = (json['plan'] ?? json['role'] ?? json['tier'] ?? 'growth').toString().toLowerCase();

    final organisation = (json['organisation'] ??
            json['organization'] ??
            json['company'] ??
            json['tenant_name'] ??
            'Leukquant Enterprise')
        .toString();

    final workspaceId = (json['workspace_id'] ?? json['tenant_id'] ?? 'WS-STAGING-01').toString();

    return UserProfile(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      plan: rawPlan,
      organisation: organisation,
      workspaceId: workspaceId,
      isBackendConnected: true,
    );
  }
}