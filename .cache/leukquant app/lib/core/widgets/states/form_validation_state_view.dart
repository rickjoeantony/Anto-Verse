// lib/core/widgets/states/form_validation_state_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

/// Interactive Form Validation State view for LeukQuant Decoy Deployment.
/// Demonstrates comprehensive error, warning, pristine, dirty, and valid states.
class FormValidationStateView extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onSubmitSuccess;
  final bool isCard;

  const FormValidationStateView({
    super.key,
    this.onSubmitSuccess,
    this.isCard = false,
  });

  @override
  State<FormValidationStateView> createState() => _FormValidationStateViewState();
}

class _FormValidationStateViewState extends State<FormValidationStateView> {
  final _formKey = GlobalKey<FormState>();

  final _nodeNameController = TextEditingController();
  final _ipCidrController = TextEditingController();
  final _portController = TextEditingController();
  final _canaryTokenController = TextEditingController();
  final _authCodeController = TextEditingController();

  String _selectedProtocol = 'SSH (Port 22)';
  bool _enableActiveBaiting = true;
  bool _autoRotatePayload = false;

  // Validation States
  bool _hasSubmittedOnce = false;
  String? _nodeNameError;
  String? _ipCidrError;
  String? _portError;
  String? _canaryTokenError;
  String? _authCodeError;

  @override
  void initState() {
    super.initState();
    // Default placeholder pre-fill for demo/testing
    _nodeNameController.text = 'dc-prod-auth-decoy';
    _ipCidrController.text = '10.24.180.12/24';
    _portController.text = '2222';
    _canaryTokenController.text = 'LKQ-CANARY-SECRET-9941X';
    _authCodeController.text = 'AUTH-7721';
  }

  @override
  void dispose() {
    _nodeNameController.dispose();
    _ipCidrController.dispose();
    _portController.dispose();
    _canaryTokenController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  void _validateAllFields() {
    setState(() {
      // 1. Node Name Validation
      final name = _nodeNameController.text.trim();
      if (name.isEmpty) {
        _nodeNameError = 'Decoy node name is required.';
      } else if (name.length < 4) {
        _nodeNameError = 'Decoy name must be at least 4 characters long.';
      } else if (!RegExp(r'^[a-zA-Z0-9_\-]+$').hasMatch(name)) {
        _nodeNameError = 'Only letters, numbers, hyphens, and underscores allowed.';
      } else {
        _nodeNameError = null;
      }

      // 2. IP / CIDR Validation
      final ip = _ipCidrController.text.trim();
      final ipRegex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\/([0-9]|[1-2][0-9]|3[0-2]))?$',
      );
      if (ip.isEmpty) {
        _ipCidrError = 'Target IP Address or CIDR is required.';
      } else if (!ipRegex.hasMatch(ip)) {
        _ipCidrError = 'Invalid IPv4/CIDR format (e.g., 10.0.4.12/24 or 192.168.1.1).';
      } else {
        _ipCidrError = null;
      }

      // 3. Port Number Validation
      final portText = _portController.text.trim();
      if (portText.isEmpty) {
        _portError = 'Port number is required.';
      } else {
        final port = int.tryParse(portText);
        if (port == null || port < 1 || port > 65535) {
          _portError = 'Port must be an integer between 1 and 65535.';
        } else {
          _portError = null;
        }
      }

      // 4. Canary Token Validation
      final token = _canaryTokenController.text.trim();
      if (token.isEmpty) {
        _canaryTokenError = 'Canary payload token is required.';
      } else if (token.length < 8) {
        _canaryTokenError = 'Canary token must have minimum 8 entropy characters.';
      } else {
        _canaryTokenError = null;
      }

      // 5. Auth Code Validation
      final auth = _authCodeController.text.trim();
      if (auth.isEmpty) {
        _authCodeError = 'SOC authorization code is required for decoy provisioning.';
      } else if (!auth.startsWith('AUTH-')) {
        _authCodeError = 'Authorization code must start with prefix "AUTH-".';
      } else {
        _authCodeError = null;
      }
    });
  }

  int get _errorCount {
    int count = 0;
    if (_nodeNameError != null) count++;
    if (_ipCidrError != null) count++;
    if (_portError != null) count++;
    if (_canaryTokenError != null) count++;
    if (_authCodeError != null) count++;
    return count;
  }

  void _handleSubmit() {
    setState(() => _hasSubmittedOnce = true);
    _validateAllFields();

    if (_errorCount == 0) {
      final payload = {
        'nodeName': _nodeNameController.text.trim(),
        'ipCidr': _ipCidrController.text.trim(),
        'port': int.parse(_portController.text.trim()),
        'protocol': _selectedProtocol,
        'canaryToken': _canaryTokenController.text.trim(),
        'authCode': _authCodeController.text.trim(),
        'activeBaiting': _enableActiveBaiting,
        'autoRotate': _autoRotatePayload,
      };

      if (widget.onSubmitSuccess != null) {
        widget.onSubmitSuccess!(payload);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Decoy Node "${payload['nodeName']}" validated and queued for deployment!'),
            backgroundColor: AppColors.of(context).success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resetToErrorSample() {
    setState(() {
      _nodeNameController.text = 'dc'; // too short
      _ipCidrController.text = '999.300.1.200'; // invalid IP
      _portController.text = '999999'; // invalid port
      _canaryTokenController.text = 'xyz'; // too short
      _authCodeController.text = 'INVALID-123'; // invalid prefix
      _hasSubmittedOnce = true;
    });
    _validateAllFields();
  }

  void _resetToValidSample() {
    setState(() {
      _nodeNameController.text = 'prod-auth-decoy-01';
      _ipCidrController.text = '10.24.180.12/24';
      _portController.text = '2222';
      _canaryTokenController.text = 'LKQ-CANARY-SECRET-9941X';
      _authCodeController.text = 'AUTH-SOC-ADMIN-88';
      _hasSubmittedOnce = true;
    });
    _validateAllFields();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deploy Security Decoy Node',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                        fontSize: 16.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time field validation & honeypot rules',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.brandPrimary.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.rule_folder_outlined, color: colors.brandPrimary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sample Switcher Bar
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.surfaceMuted.withValues(alpha: isDark ? 0.6 : 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  const Text('Test Presets:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        side: BorderSide(color: colors.critical.withValues(alpha: 0.5)),
                        foregroundColor: colors.critical,
                      ),
                      onPressed: _resetToErrorSample,
                      child: const Text('Fill All Errors', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        backgroundColor: colors.success,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _resetToValidSample,
                      child: const Text('Fill Valid Form', style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary Error Banner if has submitted and has errors
            if (_hasSubmittedOnce && _errorCount > 0) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.critical.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.critical.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 18, color: colors.critical),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please resolve $_errorCount highlighted field errors before deploying.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.critical,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Field 1: Decoy Node Name
            _buildField(
              label: 'Decoy Node Name',
              hint: 'e.g. dc-prod-auth-decoy',
              controller: _nodeNameController,
              errorText: _nodeNameError,
              prefixIcon: Icons.dns_outlined,
              helperText: 'Must be 4-32 alphanumeric characters.',
              onChanged: (_) {
                if (_hasSubmittedOnce) _validateAllFields();
              },
              colors: colors,
            ),
            const SizedBox(height: 14),

            // Field 2: Target Subnet / IPv4 CIDR
            _buildField(
              label: 'Target Subnet / IPv4 CIDR',
              hint: 'e.g. 10.24.180.12/24',
              controller: _ipCidrController,
              errorText: _ipCidrError,
              prefixIcon: Icons.lan_outlined,
              helperText: 'Valid IPv4 address with optional CIDR mask.',
              onChanged: (_) {
                if (_hasSubmittedOnce) _validateAllFields();
              },
              colors: colors,
            ),
            const SizedBox(height: 14),

            // Field 3: Port Number & Protocol Dropdown in a Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildField(
                    label: 'Port Number',
                    hint: '2222',
                    controller: _portController,
                    errorText: _portError,
                    prefixIcon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    helperText: '1 - 65535',
                    onChanged: (_) {
                      if (_hasSubmittedOnce) _validateAllFields();
                    },
                    colors: colors,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Protocol',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedProtocol,
                            isExpanded: true,
                            dropdownColor: colors.surface,
                            items: const [
                              DropdownMenuItem(value: 'SSH (Port 22)', child: Text('SSH (Port 22)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'HTTP (Port 80)', child: Text('HTTP (Port 80)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'MySQL (Port 3306)', child: Text('MySQL (3306)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'Redis (Port 6379)', child: Text('Redis (6379)', style: TextStyle(fontSize: 12))),
                              DropdownMenuItem(value: 'SMB (Port 445)', child: Text('SMB (445)', style: TextStyle(fontSize: 12))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedProtocol = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Field 4: Honeytoken Canary Secret
            _buildField(
              label: 'Honeytoken Canary Payload',
              hint: 'e.g. LKQ-CANARY-SECRET-9941X',
              controller: _canaryTokenController,
              errorText: _canaryTokenError,
              prefixIcon: Icons.key_outlined,
              helperText: 'Entropic secret payload embedded inside fake credentials.',
              onChanged: (_) {
                if (_hasSubmittedOnce) _validateAllFields();
              },
              colors: colors,
            ),
            const SizedBox(height: 14),

            // Field 5: Authorization Code
            _buildField(
              label: 'SOC Admin Authorization Code',
              hint: 'e.g. AUTH-SOC-ADMIN-88',
              controller: _authCodeController,
              errorText: _authCodeError,
              prefixIcon: Icons.verified_user_outlined,
              helperText: 'Required clearance signature with prefix "AUTH-".',
              onChanged: (_) {
                if (_hasSubmittedOnce) _validateAllFields();
              },
              colors: colors,
            ),
            const SizedBox(height: 16),

            // Toggles
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active Baiting & Live Telemetry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Broadcast decoys to local ARP & routing tables.', style: TextStyle(fontSize: 11)),
              value: _enableActiveBaiting,
              activeThumbColor: colors.brandPrimary,
              onChanged: (val) => setState(() => _enableActiveBaiting = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-Rotate Canary Credentials', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('Regenerate token signatures every 24 hours.', style: TextStyle(fontSize: 11)),
              value: _autoRotatePayload,
              activeThumbColor: colors.brandPrimary,
              onChanged: (val) => setState(() => _autoRotatePayload = val),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _handleSubmit,
                icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                label: const Text('Validate & Deploy Decoy Node', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasSubmittedOnce && _errorCount > 0 ? colors.critical : colors.brandPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.isCard) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? colors.border.withValues(alpha: 0.8) : colors.border),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: content,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: content,
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? errorText,
    required IconData prefixIcon,
    required String helperText,
    required ValueChanged<String> onChanged,
    required AppColorScheme colors,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: hasError ? colors.critical : colors.textPrimary,
              ),
            ),
            if (hasError)
              Row(
                children: [
                  Icon(Icons.error_rounded, size: 13, color: colors.critical),
                  const SizedBox(width: 4),
                  Text(
                    'Invalid Field',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.critical),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: TextStyle(fontSize: 13, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12.5, color: colors.textSecondary.withValues(alpha: 0.6)),
            prefixIcon: Icon(prefixIcon, size: 18, color: hasError ? colors.critical : colors.textSecondary),
            filled: true,
            fillColor: hasError
                ? colors.critical.withValues(alpha: 0.05)
                : colors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? colors.critical : colors.border,
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasError ? colors.critical : colors.brandPrimary,
                width: 1.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize: 11,
                color: colors.critical,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}
