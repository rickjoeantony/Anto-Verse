/// Severity classification enum for LeukQuant events and incidents.
enum SeverityLevel {
  critical('Critical'),
  high('High'),
  warning('Warning'),
  info('Info'),
  low('Low'),
  healthy('Healthy'),
  success('Success');

  final String displayName;
  const SeverityLevel(this.displayName);

  static SeverityLevel fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'critical':
        return SeverityLevel.critical;
      case 'high':
        return SeverityLevel.high;
      case 'warning':
      case 'warn':
        return SeverityLevel.warning;
      case 'low':
        return SeverityLevel.low;
      case 'healthy':
        return SeverityLevel.healthy;
      case 'success':
        return SeverityLevel.success;
      case 'info':
      default:
        return SeverityLevel.info;
    }
  }
}
