import 'dart:collection';

/// Service to capture and store comparison logs
class ComparisonLogger {
  static final ComparisonLogger _instance = ComparisonLogger._internal();
  factory ComparisonLogger() => _instance;
  ComparisonLogger._internal();

  final Queue<String> _logs = Queue<String>();
  static const int _maxLogs = 1000; // Keep last 1000 log entries

  /// Add a log entry
  void log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _logs.add('[$timestamp] $message');

    // Keep only recent logs
    while (_logs.length > _maxLogs) {
      _logs.removeFirst();
    }
  }

  /// Get all logs as a string
  String getAllLogs() {
    return _logs.join('\n');
  }

  /// Get logs from a specific session (after a certain time)
  String getLogsAfter(DateTime after) {
    return _logs
        .where((log) {
          // Extract timestamp from log entry
          final match = RegExp(r'\[(.*?)\]').firstMatch(log);
          if (match != null) {
            try {
              final logTime = DateTime.parse(match.group(1)!);
              return logTime.isAfter(after);
            } catch (e) {
              return false;
            }
          }
          return false;
        })
        .join('\n');
  }

  /// Clear all logs
  void clear() {
    _logs.clear();
  }

  /// Get log count
  int get logCount => _logs.length;

  /// Check if has logs
  bool get hasLogs => _logs.isNotEmpty;
}
