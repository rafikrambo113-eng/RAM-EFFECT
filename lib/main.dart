import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const GuitarRigApp());
}

class GuitarRigApp extends StatelessWidget {
  const GuitarRigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAM EFFECT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MainRigScreen(),
    );
  }
}

class MainRigScreen extends StatefulWidget {
  const MainRigScreen({super.key});

  @override
  State<MainRigScreen> createState() => _MainRigScreenState();
}

class _MainRigScreenState extends State<MainRigScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<String> savedBoards = [
    "فيروز - سولوهات",
    "James Brown - Funk",
    "Hotel California",
    "Clean Acoustic",
    "Heavy Distortion Solo"
  ];

  double gainValue = 5.0;
  double volumeValue = 8.0;
  double wahValue = 0.0;
  bool isOverdriveOn = true;
  bool isDelayOn = false;

  void _playSound(String soundName) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/$soundName'));
    } catch (e) {
      debugPrint("خطأ في تشغيل الصوت: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('RAM EFFECT'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos, color: Colors.amber),
            onPressed: _showSaveBoardDialog,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: Text(
                'مكتبة الـ Boards المخصصة',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ...savedBoards.map((board) => ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.amber),
                  title: Text(board),
                  onTap: () => Navigator.pop(context),
                )),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // قسم الدواسات (Pedals)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade700, width: 1.5),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPedal("Overdrive", Colors.green, isOverdriveOn, () {
                          setState(() => isOverdriveOn = !isOverdriveOn);
                          _playSound('overdrive.mp3');
                        }),
                        const SizedBox(width: 10),
                        _buildPedal("Delay", Colors.blue, isDelayOn, () {
                          setState(() => isDelayOn = !isDelayOn);
                          _playSound('delay.mp3');
                        }),
                        const SizedBox(width: 10),
                        _buildPedal("Reverb", Colors.purple, true, () {
                          _playSound('reverb.mp3');
                        }),
                        const SizedBox(width: 10),
                        _buildPedal("Chorus", Colors.deepOrange, false, () {
                          _playSound('chorus.mp3');
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // قسم الأمبليفاير (Amplifier)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C251E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orangeAccent, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text("TUBE MASTER 50 AMP", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceAround,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildKnob("Gain", gainValue, (v) => setState(() => gainValue = v)),
                          _buildKnob("Bass", 6.0, (v) {}),
                          _buildKnob("Treble", 7.5, (v) {}),
                          _buildKnob("Volume", volumeValue, (v) => setState(() => volumeValue = v)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // قسم دواسة التعبير (Expression Controls)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text("EXPRESSION CONTROLS", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text("VOLUME", style: TextStyle(color: Colors.amber, fontSize: 10)),
                                Slider(
                                  value: volumeValue,
                                  min: 0,
                                  max: 10,
                                  activeColor: Colors.amber,
                                  onChanged: (v) => setState(() => volumeValue = v),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text("WAH / GAIN", style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                                Slider(
                                  value: wahValue,
                                  min: 0,
                                  max: 10,
                                  activeColor: Colors.redAccent,
                                  onChanged: (v) => setState(() => wahValue = v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPedal(String name, Color color, bool isOn, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 110,
        decoration: BoxDecoration(
          color: isOn ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Icon(Icons.power_settings_new, color: isOn ? Colors.white : Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildKnob(String label, double value, ValueChanged<double> onChanged) {
    return SizedBox(
      width: 140,
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Slider(
            value: value,
            min: 0,
            max: 10,
            activeColor: Colors.amber,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showSaveBoardDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حفظ Board جديد"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "ادخل اسم الاغنية أو الـ Preset"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  savedBoards.add(controller.text);
                });
                Navigator.pop(context);
              }
            },
            child: const Text("حفظ"),
          )
        ],
      ),
    );
  }
}
