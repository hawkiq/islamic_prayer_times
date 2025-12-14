import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_prayer_times/islamic_prayer_times.dart';

void main() {
  group('PrayerTimes', () {
    test('should calculate prayer times', () {
      final prayerTimes = PrayerTimes('Jafari')
        ..setLocation([33.312806, 44.361488]);

      final times = prayerTimes.getPrayerTimes(DateTime(2025, 11, 11));

      expect(times, isNotNull);
      expect(times['fajr'], isNotEmpty);
      expect(times['dhuhr'], isNotEmpty);
    });

    test('should return DateTime objects', () {
      final prayerTimes = PrayerTimes()..setLocation([33.312806, 44.361488]);

      final times = prayerTimes.getPrayerTimesAsDateTime();

      expect(times['fajr'], isA<DateTime>());
    });
  });
}
