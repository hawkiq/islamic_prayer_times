import 'package:flutter/material.dart';
import 'package:islamic_prayer_times/islamic_prayer_times.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times Example',
      home: PrayerTimesDemo(),
    );
  }
}

class PrayerTimesDemo extends StatefulWidget {
  const PrayerTimesDemo({super.key});

  @override
  State<PrayerTimesDemo> createState() => _PrayerTimesDemoState();
}

class _PrayerTimesDemoState extends State<PrayerTimesDemo> {
  late Map<String, String> prayerTimes;

  @override
  void initState() {
    super.initState();
    calculatePrayerTimes();
  }

  void calculatePrayerTimes() {
    final calculator = PrayerTimes('Jafari')
      ..setLocation([33.312806, 44.361488]) // Baghdad
      ..setFormat('12h');

    setState(() {
      prayerTimes = calculator.getPrayerTimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: prayerTimes.entries.map((entry) {
          return Card(
            child: ListTile(
              title: Text(entry.key.toUpperCase()),
              trailing: Text(entry.value, style: const TextStyle(fontSize: 18)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
