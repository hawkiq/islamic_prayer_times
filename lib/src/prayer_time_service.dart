import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

/// Prayer Times Calculator for Flutter/Dart
/// Adapted from praytime.js v3.2
/// Copyright (c) 2007-2025 Hamid Zarrabi-Zadeh
/// Source: https://praytimes.org
/// License: MIT

class PrayerTimes {
  // Calculation methods
  static const Map<String, Map<String, dynamic>> _methods = {
    'MWL': {'fajr': 18, 'isha': 17},
    'ISNA': {'fajr': 15, 'isha': 15},
    'Egypt': {'fajr': 19.5, 'isha': 17.5},
    'Makkah': {'fajr': 18.5, 'isha': '90 min'},
    'Karachi': {'fajr': 18, 'isha': 18},
    'Tehran': {'fajr': 17.7, 'maghrib': 4.5, 'midnight': 'Jafari'},
    'Jafari': {'fajr': 18, 'maghrib': 4, 'midnight': 'Jafari'},
    'France': {'fajr': 12, 'isha': 12},
    'Russia': {'fajr': 16, 'isha': 15},
    'Singapore': {'fajr': 20, 'isha': 18},
    'defaults': {'isha': 14, 'maghrib': '1 min', 'midnight': 'Standard'},
  };

  // Settings
  late Map<String, dynamic> _settings;
  late int _utcTime;
  bool _adjusted = false;

  /// Constructor
  /// [method] - Calculation method (default: 'MWL')
  PrayerTimes([String method = 'MWL']) {
    _settings = {
      'dhuhr': '0 min',
      'asr': 'Standard',
      'highLats': 'NightMiddle',
      'tune': <String, double>{},
      'format': '24h',
      'rounding': 'nearest',
      'utcOffset': 'auto',
      'timezone': DateTime.now().timeZoneName,
      'location': [0.0, -(DateTime.now().timeZoneOffset.inMinutes / 4)],
      'iterations': 1,
    };

    setMethod(method);
  }

  // ==================== Public API ====================

  /// Set calculation method
  PrayerTimes setMethod(String method) {
    _set(_methods['defaults']!);
    if (_methods.containsKey(method)) {
      _set(_methods[method]!);
    }
    return this;
  }

  /// Set location coordinates [latitude, longitude]
  PrayerTimes setLocation(List<double> location) {
    _settings['location'] = location;
    return this;
  }

  /// Set timezone
  PrayerTimes setTimezone(String timezone) {
    _settings['timezone'] = timezone;
    return this;
  }

  /// Set UTC offset in minutes or hours
  PrayerTimes setUtcOffset(dynamic utcOffset) {
    if (utcOffset is num && utcOffset.abs() < 16) {
      utcOffset = utcOffset * 60;
    }
    _settings['timezone'] = 'UTC';
    _settings['utcOffset'] = utcOffset;
    return this;
  }

  /// Adjust calculation parameters
  PrayerTimes adjust(Map<String, dynamic> params) {
    _set(params);
    return this;
  }

  /// Tune prayer times by given minutes
  PrayerTimes tune(Map<String, double> tuneParams) {
    _settings['tune'] = tuneParams;
    return this;
  }

  /// Set time format ('24h', '12h', '12H')
  PrayerTimes setFormat(String format) {
    _settings['format'] = format;
    return this;
  }

  /// Set rounding method ('nearest', 'up', 'down', 'none')
  PrayerTimes setRounding(String rounding) {
    _settings['rounding'] = rounding;
    return this;
  }

  /// Get prayer times for a specific date
  /// [date] - DateTime object or null for today
  Map<String, String> getPrayerTimes([DateTime? date]) {
    date ??= DateTime.now();
    debugPrint("Date : $date");
    _utcTime = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).millisecondsSinceEpoch;

    Map<String, double> times = _computeTimes();
    return _formatTimes(times);
  }

  /// Get prayer times as DateTime objects
  Map<String, DateTime> getPrayerTimesAsDateTime([DateTime? date]) {
    date ??= DateTime.now();

    _utcTime = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).millisecondsSinceEpoch;

    Map<String, double> times = _computeTimes();
    Map<String, DateTime> result = {};

    for (String prayer in times.keys) {
      final timeValue = times[prayer];
      if (timeValue != null && !timeValue.isNaN) {
        try {
          result[prayer] = DateTime.fromMillisecondsSinceEpoch(
            _roundTime(timeValue).round(),
          );
        } catch (e) {
          debugPrint('Error converting time for $prayer: $e');
        }
      }
    }

    return result;
  }

  // ==================== Private Methods ====================

  void _set(Map<String, dynamic> params) {
    _settings.addAll(params);
  }

  Map<String, double> _computeTimes() {
    Map<String, double> times = {
      'fajr': 5,
      'sunrise': 6,
      'dhuhr': 12,
      'asr': 13,
      'sunset': 18,
      'maghrib': 18,
      'isha': 18,
      'midnight': 24,
    };

    for (int i = 0; i < _settings['iterations']; i++) {
      times = _processTimes(times);
    }

    _adjustHighLats(times);
    _updateTimes(times);
    _tuneTimes(times);
    _convertTimes(times);

    return times;
  }

  Map<String, double> _processTimes(Map<String, double> times) {
    const double horizon = 0.833;

    return {
      'fajr': _angleTime(_getValue(_settings['fajr']), times['fajr'] ?? 5, -1),
      'sunrise': _angleTime(horizon, times['sunrise'] ?? 6, -1),
      'dhuhr': _midDay(times['dhuhr'] ?? 12),
      'asr': _angleTime(
        _asrAngle(_settings['asr'], times['asr'] ?? 13),
        times['asr'] ?? 13,
      ),
      'sunset': _angleTime(horizon, times['sunset'] ?? 18),
      'maghrib': _angleTime(
        _getValue(_settings['maghrib']),
        times['maghrib'] ?? 18,
      ),
      'isha': _angleTime(_getValue(_settings['isha']), times['isha'] ?? 18),
      'midnight': _midDay(times['midnight'] ?? 24) + 12,
    };
  }

  void _updateTimes(Map<String, double> times) {
    if (_isMin(_settings['maghrib'])) {
      times['maghrib'] =
          (times['sunset'] ?? 18) + _getValue(_settings['maghrib']) / 60;
    }
    if (_isMin(_settings['isha'])) {
      times['isha'] =
          (times['maghrib'] ?? 18) + _getValue(_settings['isha']) / 60;
    }
    if (_settings['midnight'] == 'Jafari') {
      double nextFajr = _angleTime(_getValue(_settings['fajr']), 29, -1) + 24;
      times['midnight'] = ((times['sunset'] ?? 18) +
              (_adjusted ? (times['fajr'] ?? 5) + 24 : nextFajr)) /
          2;
    }
    times['dhuhr'] =
        (times['dhuhr'] ?? 12) + _getValue(_settings['dhuhr']) / 60;
  }

  void _tuneTimes(Map<String, double> times) {
    Map<String, double> tune = Map<String, double>.from(
      _settings['tune'] ?? {},
    );
    for (String prayer in times.keys) {
      if (tune.containsKey(prayer)) {
        final currentTime = times[prayer];
        final tuneValue = tune[prayer];
        if (currentTime != null && tuneValue != null) {
          times[prayer] = currentTime + tuneValue / 60;
        }
      }
    }
  }

  void _convertTimes(Map<String, double> times) {
    final location = _settings['location'] as List<double>;
    double lng = location.length > 1 ? location[1] : 0.0;

    for (String prayer in times.keys) {
      final time = times[prayer];
      if (time != null) {
        double adjustedTime = time - lng / 15;
        int timestamp = _utcTime + (adjustedTime * 3600000).toInt();
        times[prayer] = _roundTime(timestamp.toDouble());
      }
    }
  }

  double _roundTime(double timestamp) {
    String rounding = _settings['rounding'] ?? 'nearest';
    if (rounding == 'none') return timestamp;

    const double oneMinute = 60000;
    switch (rounding) {
      case 'up':
        return (timestamp / oneMinute).ceil() * oneMinute;
      case 'down':
        return (timestamp / oneMinute).floor() * oneMinute;
      case 'nearest':
      default:
        return (timestamp / oneMinute).round() * oneMinute;
    }
  }

  Map<String, double> _sunPosition(double time) {
    final location = _settings['location'] as List<double>;
    double lng = location.length > 1 ? location[1] : 0.0;
    double d = _utcTime / 86400000 - 10957.5 + _getValue(time) / 24 - lng / 360;

    double g = _mod(357.529 + 0.98560028 * d, 360);
    double q = _mod(280.459 + 0.98564736 * d, 360);
    double l = _mod(q + 1.915 * _sin(g) + 0.020 * _sin(2 * g), 360);
    double e = 23.439 - 0.00000036 * d;
    double ra = _mod(_arctan2(_cos(e) * _sin(l), _cos(l)) / 15, 24);

    return {'declination': _arcsin(_sin(e) * _sin(l)), 'equation': q / 15 - ra};
  }

  double _midDay(double time) {
    final sunPos = _sunPosition(time);
    double eqt = sunPos['equation'] ?? 0.0;
    return _mod(12 - eqt, 24);
  }

  double _angleTime(double angle, double time, [int direction = 1]) {
    final location = _settings['location'] as List<double>;
    double lat = location.isNotEmpty ? location[0] : 0.0;

    final sunPos = _sunPosition(time);
    double decl = sunPos['declination'] ?? 0.0;
    double numerator = -_sin(angle) - _sin(lat) * _sin(decl);
    double denominator = _cos(lat) * _cos(decl);

    if (denominator == 0) return double.nan;

    double diff = _arccos(numerator / denominator) / 15;
    return _midDay(time) + diff * direction;
  }

  double _asrAngle(dynamic asrParam, double time) {
    Map<String, double> shadowFactors = {'Standard': 1, 'Hanafi': 2};
    double shadowFactor = shadowFactors[asrParam] ?? _getValue(asrParam);

    final location = _settings['location'] as List<double>;
    double lat = location.isNotEmpty ? location[0] : 0.0;

    final sunPos = _sunPosition(time);
    double decl = sunPos['declination'] ?? 0.0;
    return -_arccot(shadowFactor + _tan((lat - decl).abs()));
  }

  void _adjustHighLats(Map<String, double> times) {
    if (_settings['highLats'] == 'None') return;

    _adjusted = false;
    double night = 24 + (times['sunrise'] ?? 6) - (times['sunset'] ?? 18);

    times['fajr'] = _adjustTime(
      times['fajr'] ?? 5,
      times['sunrise'] ?? 6,
      _getValue(_settings['fajr']),
      night,
      -1,
    );
    times['isha'] = _adjustTime(
      times['isha'] ?? 18,
      times['sunset'] ?? 18,
      _getValue(_settings['isha']),
      night,
    );
    times['maghrib'] = _adjustTime(
      times['maghrib'] ?? 18,
      times['sunset'] ?? 18,
      _getValue(_settings['maghrib']),
      night,
    );
  }

  double _adjustTime(
    double time,
    double base,
    double angle,
    double night, [
    int direction = 1,
  ]) {
    Map<String, double> factors = {
      'NightMiddle': 1 / 2,
      'OneSeventh': 1 / 7,
      'AngleBased': 1 / 60 * angle,
    };

    double portion = (factors[_settings['highLats']] ?? 0.5) * night;
    double timeDiff = (time - base) * direction;

    if (time.isNaN || timeDiff > portion) {
      time = base + portion * direction;
      _adjusted = true;
    }

    return time;
  }

  Map<String, String> _formatTimes(Map<String, double> times) {
    Map<String, String> result = {};
    for (String prayer in times.keys) {
      final timeValue = times[prayer];
      result[prayer] = timeValue != null ? _formatTime(timeValue) : '-----';
    }
    return result;
  }

  String _formatTime(double timestamp) {
    if (timestamp.isNaN) return '-----';

    String format = _settings['format'] ?? '24h';
    return _timeToString(timestamp, format);
  }

  String _timeToString(double timestamp, String format) {
    try {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp.round());

      switch (format) {
        case '24h':
          return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        case '12h':
          int hour = date.hour;
          String period = hour >= 12 ? 'م' : 'ص';
          hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
        case '12H':
          int hour = date.hour;
          hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
          return '$hour:${date.minute.toString().padLeft(2, '0')}';
        default:
          return date.toString();
      }
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return '-----';
    }
  }

  // ==================== Helper Functions ====================

  double _getValue(dynamic str) {
    if (str == null) return 0.0;
    if (str is num) return str.toDouble();
    String s = str.toString();
    RegExp regex = RegExp(r'[^0-9.+-]');
    List<String> parts = s.split(regex);
    String numStr = parts.isNotEmpty ? parts[0] : '0';
    return double.tryParse(numStr) ?? 0.0;
  }

  bool _isMin(dynamic str) {
    return str?.toString().contains('min') ?? false;
  }

  double _mod(double a, double b) {
    return ((a % b) + b) % b;
  }

  // Trigonometric functions (degree-based)
  double _dtr(double d) => d * math.pi / 180;
  double _rtd(double r) => r * 180 / math.pi;

  double _sin(double d) => math.sin(_dtr(d));
  double _cos(double d) => math.cos(_dtr(d));
  double _tan(double d) => math.tan(_dtr(d));

  double _arcsin(double d) => _rtd(math.asin(d));
  double _arccos(double d) => _rtd(math.acos(d));

  double _arccot(double x) => _rtd(math.atan(1 / x));
  double _arctan2(double y, double x) => _rtd(math.atan2(y, x));
}
