# Prayer Times

A comprehensive Islamic prayer times calculator for Flutter applications. This package calculates accurate prayer times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) based on geographic coordinates and various calculation methods.

## Features

- 🕌 Multiple calculation methods (MWL, ISNA, Egypt, Makkah, Karachi, Tehran, Jafari, and more)
- 🌍 Works worldwide with any geographic coordinates
- ⏰ Multiple time formats (24h, 12h with AM/PM)
- 🎯 Accurate calculations based on astronomical formulas
- ⚙️ Customizable prayer time adjustments
- 🌙 High latitude adjustments
- 📅 Get times as formatted strings or DateTime objects

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  islamic_prayer_times: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:islamic_prayer_times/islamic_prayer_times.dart';

void main() {
  // Create instance with default method (MWL)
  final prayerTimes = PrayerTimes();
  
  // Set your location (latitude, longitude)
  // Example: Baghdad, Iraq
  prayerTimes.setLocation([33.312806, 44.361488]);
  
  // Get prayer times for today
  final times = prayerTimes.getPrayerTimes();
  
  print('Fajr: ${times['fajr']}');
  print('Sunrise: ${times['sunrise']}');
  print('Dhuhr: ${times['dhuhr']}');
  print('Asr: ${times['asr']}');
  print('Maghrib: ${times['maghrib']}');
  print('Isha: ${times['isha']}');
}
```

### Advanced Usage

```dart
// Use specific calculation method
final prayerTimes = PrayerTimes('Jafari')
  .setLocation([33.7490, -84.3880]) // Atlanta, GA
  .setFormat('12h'); // 12-hour format with AM/PM

// Get times for a specific date
final date = DateTime(2024, 12, 15);
final times = prayerTimes.getPrayerTimes(date);

// Get times as DateTime objects
final dateTimes = prayerTimes.getPrayerTimesAsDateTime(date);
DateTime fajrTime = dateTimes['fajr']!;
```

### Available Calculation Methods

- **MWL**: Muslim World League (default)
- **ISNA**: Islamic Society of North America
- **Egypt**: Egyptian General Authority of Survey
- **Makkah**: Umm al-Qura University, Makkah
- **Karachi**: University of Islamic Sciences, Karachi
- **Tehran**: Institute of Geophysics, University of Tehran
- **Jafari**: Shia Ithna Ashari, Leva Research Institute, Qum
- **France**: Union Organization Islamic de France
- **Russia**: Spiritual Administration of Muslims of Russia
- **Singapore**: Majlis Ugama Islam Singapura

### Customization

```dart
final prayerTimes = PrayerTimes('Jafari')
  .setLocation([33.312806, 44.361488]) // Baghdad
  .setFormat('24h')
  .setRounding('nearest'); // 'nearest', 'up', 'down', 'none'

// Fine-tune prayer times (add/subtract minutes)
prayerTimes.tune({
  'fajr': 2,    // Add 2 minutes to Fajr
  'dhuhr': -1,  // Subtract 1 minute from Dhuhr
  'asr': 0,
  'maghrib': 1,
  'isha': -2,
});

// Adjust calculation parameters
prayerTimes.adjust({
  'asr': 'Hanafi',        // Use Hanafi method for Asr
  'highLats': 'AngleBased', // High latitude adjustment
});
```

### High Latitude Adjustments

For locations with extreme latitudes (where the sun doesn't rise or set):

```dart
prayerTimes.adjust({
  'highLats': 'NightMiddle', // Options: 'NightMiddle', 'AngleBased', 'OneSeventh', 'None'
});
```

### Time Formats

```dart
// 24-hour format: "14:30"
prayerTimes.setFormat('24h');

// 12-hour format with Arabic markers: "2:30 م" (PM)
prayerTimes.setFormat('12h');

// 12-hour format without markers: "2:30"
prayerTimes.setFormat('12H');
```

## Example

Check the [example](example/) directory for a complete Flutter application demonstrating all features.

## Calculation Details

This package uses astronomical calculations based on:
- Solar position algorithms
- Geographic coordinates
- Multiple madhab (school of thought) methodologies
- High latitude considerations

The calculations are based on the work of Hamid Zarrabi-Zadeh (PrayTimes.org) and have been thoroughly tested for accuracy.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

Based on PrayTimes.js v3.2 by Hamid Zarrabi-Zadeh
- Website: https://praytimes.org
- Original License: MIT

## Support

If you find this package helpful, please give it a ⭐️ on GitHub!

For issues and feature requests, please visit the [issue tracker](https://github.com/hawkiq/islamic_prayer_times/issues).