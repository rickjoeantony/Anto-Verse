// lib/features/settings/presentation/widgets/edit_profile_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/user_profile.dart';
import '../../providers/settings_provider.dart';
import 'user_avatar_widget.dart';

/// Ultra-responsive, premium modal sheet for customizing analyst profile & organization.
class EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileSheet({
    super.key,
    required this.profile,
  });

  static Future<void> show(BuildContext context, UserProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => EditProfileSheet(profile: profile),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late String _selectedAvatar;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _companyController = TextEditingController(
      text: widget.profile.organisation?.isNotEmpty == true
          ? widget.profile.organisation!
          : 'Leukquant Enterprise',
    );
    _selectedAvatar = widget.profile.avatar ?? 'shield';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final company = _companyController.text.trim();

    if (name.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: const Color(0xFFFF3B30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Text(
            'Please enter your name',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    // Optimistic fast update
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    await ref.read(userProfileProvider.notifier).updateProfile(
      name: name,
      organisation: company.isNotEmpty ? company : 'Leukquant Enterprise',
      avatar: _selectedAvatar,
    );

    if (mounted) {
      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF30D158), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Profile and company updated successfully',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final activePreset = kCyberAvatarPresets.firstWhere(
      (p) => p.key == _selectedAvatar,
      orElse: () => kCyberAvatarPresets.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Header & Live Preview Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activePreset.gradient.first.withValues(alpha: isDark ? 0.18 : 0.08),
                    activePreset.gradient.last.withValues(alpha: isDark ? 0.08 : 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activePreset.gradient.first.withValues(alpha: isDark ? 0.35 : 0.2),
                ),
              ),
              child: Row(
                children: [
                  UserAvatarWidget(
                    avatarKey: _selectedAvatar,
                    name: _nameController.text,
                    size: 54,
                    showGlow: true,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CUSTOMIZE PROFILE',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: activePreset.gradient.first,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activePreset.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Analyst identity across alerts & telemetry',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.textSecondary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. Cyber Avatar Preset Selector (Buttery Smooth Horizontal List)
            Text(
              'SELECT AVATAR PRESET',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colors.textSecondary.withValues(alpha: 0.75),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: kCyberAvatarPresets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final preset = kCyberAvatarPresets[index];
                  final isSelected = _selectedAvatar == preset.key;

                  return GestureDetector(
                    onTap: () {
                      if (_selectedAvatar != preset.key) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedAvatar = preset.key);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? preset.gradient.first : Colors.transparent,
                              width: isSelected ? 2.5 : 0,
                            ),
                          ),
                          child: UserAvatarWidget(
                            avatarKey: preset.key,
                            name: widget.profile.name,
                            size: 46,
                            showGlow: isSelected,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          preset.label.split(' ').first,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? colors.textPrimary : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // 4. Analyst Name Input Field
            Text(
              'ANALYST FULL NAME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colors.textSecondary.withValues(alpha: 0.75),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person_rounded, color: activePreset.gradient.first, size: 20),
                hintText: 'Enter analyst full name',
                hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.45), fontSize: 13.5),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: activePreset.gradient.first, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Company / Organization Input Field
            Text(
              'COMPANY / ORGANIZATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colors.textSecondary.withValues(alpha: 0.75),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _companyController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSave(),
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.business_rounded, color: activePreset.gradient.last, size: 20),
                hintText: 'e.g. Acme Cybersecurity, Leukquant SOC',
                hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.45), fontSize: 13.5),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: activePreset.gradient.last, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 6. Action Save Button with Tactile Gradient
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activePreset.gradient.first,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.save_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Save Profile & Organization',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}