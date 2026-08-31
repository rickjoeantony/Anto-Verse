// lib/features/settings/presentation/widgets/user_avatar_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';

class CyberAvatarPreset {
  final String key;
  final String label;
  final IconData? icon;
  final String? imageAsset;
  final List<Color> gradient;

  const CyberAvatarPreset({
    required this.key,
    required this.label,
    this.icon,
    this.imageAsset,
    required this.gradient,
  });

  bool get isPhoto => imageAsset != null;
}

final List<CyberAvatarPreset> kCyberAvatarPresets = [
  // ── PHOTO AVATARS ───────────────────────────────────────────
  const CyberAvatarPreset(
    key: 'anto',
    label: 'Anto · Lead Architect',
    imageAsset: 'assets/images/avatars/avatar_anto.png',
    gradient: [Color(0xFF007AFF), Color(0xFF00D2FF)],
  ),
  const CyberAvatarPreset(
    key: 'soc',
    label: 'SOC Defense Commander',
    imageAsset: 'assets/images/avatars/avatar_soc.png',
    gradient: [Color(0xFF30D158), Color(0xFF64D2FF)],
  ),
  const CyberAvatarPreset(
    key: 'sentinel_photo',
    label: 'Cyber Sentinel',
    imageAsset: 'assets/images/avatars/avatar_sentinel.png',
    gradient: [Color(0xFF5E5CE6), Color(0xFFBF5AF2)],
  ),
  const CyberAvatarPreset(
    key: 'falcon_photo',
    label: 'Incident Responder',
    imageAsset: 'assets/images/avatars/avatar_falcon.png',
    gradient: [Color(0xFFFF3B30), Color(0xFFFF9500)],
  ),
  const CyberAvatarPreset(
    key: 'quantum_photo',
    label: 'Quantum Specialist',
    imageAsset: 'assets/images/avatars/avatar_quantum.png',
    gradient: [Color(0xFF0A84FF), Color(0xFF30B0C7)],
  ),
  const CyberAvatarPreset(
    key: 'operator_photo',
    label: 'Field Operator',
    imageAsset: 'assets/images/avatars/avatar_operator.png',
    gradient: [Color(0xFFFF9500), Color(0xFFFFD60A)],
  ),

  // ── ICON PRESETS ────────────────────────────────────────────
  const CyberAvatarPreset(
    key: 'shield',
    label: 'Cyber Shield',
    icon: Icons.shield_rounded,
    gradient: [Color(0xFF007AFF), Color(0xFF00D2FF)],
  ),
  const CyberAvatarPreset(
    key: 'quantum',
    label: 'Quantum Core',
    icon: Icons.hub_rounded,
    gradient: [Color(0xFF5E5CE6), Color(0xFFBF5AF2)],
  ),
  const CyberAvatarPreset(
    key: 'sentinel',
    label: 'SOC Sentinel',
    icon: Icons.visibility_rounded,
    gradient: [Color(0xFF30D158), Color(0xFF64D2FF)],
  ),
  const CyberAvatarPreset(
    key: 'guard',
    label: 'Perimeter Guard',
    icon: Icons.security_rounded,
    gradient: [Color(0xFFFF9500), Color(0xFFFFD60A)],
  ),
  const CyberAvatarPreset(
    key: 'falcon',
    label: 'Cyber Falcon',
    icon: Icons.bolt_rounded,
    gradient: [Color(0xFFFF3B30), Color(0xFFFF9500)],
  ),
  const CyberAvatarPreset(
    key: 'lock',
    label: 'Zero Trust',
    icon: Icons.lock_outline_rounded,
    gradient: [Color(0xFF636366), Color(0xFFAEB2B8)],
  ),
  const CyberAvatarPreset(
    key: 'network',
    label: 'Mesh Node',
    icon: Icons.language_rounded,
    gradient: [Color(0xFF0A84FF), Color(0xFF30B0C7)],
  ),
  const CyberAvatarPreset(
    key: 'analyst',
    label: 'SOC Analyst',
    icon: Icons.person_rounded,
    gradient: [Color(0xFF1D3557), Color(0xFF457B9D)],
  ),
];

class UserAvatarWidget extends StatelessWidget {
  final String? avatarKey;
  final String name;
  final double size;
  final bool showGlow;
  final VoidCallback? onTap;

  const UserAvatarWidget({
    super.key,
    this.avatarKey,
    required this.name,
    this.size = 48,
    this.showGlow = true,
    this.onTap,
  });

  CyberAvatarPreset _resolvePreset(String? key) {
    if (key != null) {
      final found = kCyberAvatarPresets.where((p) => p.key == key.toLowerCase()).firstOrNull;
      if (found != null) return found;
    }
    return kCyberAvatarPresets.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCustomFile = avatarKey != null &&
        (avatarKey!.startsWith('/') || avatarKey!.contains(':\\') || avatarKey!.startsWith('file:'));

    final preset = _resolvePreset(avatarKey);

    Widget innerContent;

    if (isCustomFile) {
      // User uploaded personal photo
      final file = File(avatarKey!.replaceFirst('file://', ''));
      if (file.existsSync()) {
        innerContent = ClipOval(
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } else {
        innerContent = _buildFallbackContent(preset);
      }
    } else if (preset.isPhoto) {
      // Preloaded Photo Portrait
      innerContent = ClipOval(
        child: Image.asset(
          preset.imageAsset!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      innerContent = _buildFallbackContent(preset);
    }

    final avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: preset.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: preset.gradient.first.withValues(alpha: isDark ? 0.45 : 0.25),
                  blurRadius: size * 0.3,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: size > 40 ? 2.0 : 1.5,
        ),
      ),
      child: innerContent,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildFallbackContent(CyberAvatarPreset preset) {
    return Center(
      child: preset.icon != null
          ? Icon(
              preset.icon,
              size: size * 0.52,
              color: Colors.white,
            )
          : Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'A',
              style: TextStyle(
                fontSize: size * 0.44,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
    );
  }
}