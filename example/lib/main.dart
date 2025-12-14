import 'package:flutter/material.dart';
import 'package:islamic_prayer_times/islamic_prayer_times.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Times Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const PrayerTimesDemo(),
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
  String selectedMethod = 'Jafari';
  final List<String> methods = [
    'MWL',
    'ISNA',
    'Egypt',
    'Makkah',
    'Karachi',
    'Tehran',
    'Jafari'
  ];

  @override
  void initState() {
    super.initState();
    calculatePrayerTimes();
  }

  void calculatePrayerTimes() {
    final calculator = PrayerTimes(selectedMethod)
      ..setLocation([33.312806, 44.361488]) // Baghdad, Iraq
      ..setFormat('12h');

    setState(() {
      prayerTimes = calculator.getPrayerTimes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Prayer Times'),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Baghdad, Iraq',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Calculation Method: '),
                    DropdownButton<String>(
                      value: selectedMethod,
                      items: methods.map((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedMethod = newValue;
                          });
                          calculatePrayerTimes();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPrayerCard(
                    'Fajr', prayerTimes['fajr'] ?? '--:--', Icons.wb_twilight),
                _buildPrayerCard('Sunrise', prayerTimes['sunrise'] ?? '--:--',
                    Icons.wb_sunny),
                _buildPrayerCard(
                    'Dhuhr', prayerTimes['dhuhr'] ?? '--:--', Icons.light_mode),
                _buildPrayerCard(
                    'Asr', prayerTimes['asr'] ?? '--:--', Icons.wb_cloudy),
                _buildPrayerCard('Maghrib', prayerTimes['maghrib'] ?? '--:--',
                    Icons.wb_twilight),
                _buildPrayerCard(
                    'Isha', prayerTimes['isha'] ?? '--:--', Icons.nightlight),
                _buildPrayerCard('Midnight', prayerTimes['midnight'] ?? '--:--',
                    Icons.bedtime),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(String name, String time, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.green),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          time,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
