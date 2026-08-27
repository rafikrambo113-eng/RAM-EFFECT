import 'package:flutter/material.dart';

void main() {
  runApp(const RAmEffectApp());
}

class RAmEffectApp extends StatelessWidget {
  const RAmEffectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAm EFFECT',
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
  List<String> savedBoards = [
    "فيروز - سولوهات",
    "James Brown - Funk",
    "Hotel California",
    "Clean Acoustic",
    "Heavy Distortion Solo"
  ];

  double gainValue = 5.0;
  double bassValue = 6.0;
  double trebleValue = 7.5;
  double volumeValue = 8.0;
  double wahValue = 0.0;
  bool isOverdriveOn = true;
  bool isDelayOn = false;
  bool isReverbOn = true;
  bool isChorusOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('RAm EFFECT - Unlimited Boards'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_to_photos, color: Colors.amber),
            onPressed: () {
              _showSaveBoardDialog();
            },
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
                  onTap: () {
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade700, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPedal("Overdrive", Colors.green, isOverdriveOn, () {
                          setState(() => isOverdriveOn = !isOverdriveOn);
                        }),
                        _buildPedal("Delay", Colors.blue, isDelayOn, () {
                          setState(() => isDelayOn = !isDelayOn);
                        }),
                        _buildPedal("Reverb", Colors.purple, isReverbOn, () {
                          setState(() => isReverbOn = !isReverbOn);
                        }),
                        _buildPedal("Chorus", Colors.deepOrange, isChorusOn, () {
                          setState(() => isChorusOn = !isChorusOn);
                        }),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C251E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orangeAccent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("TUBE MASTER 50 AMP", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildKnob("Gain", gainValue, (v) => setState(() => gainValue = v)),
                            _buildKnob("Bass", bassValue, (v) => setState(() => bassValue = v)),
                            _buildKnob("Treble", trebleValue, (v) => setState(() => trebleValue = v)),
                            _buildKnob("Volume", volumeValue, (v) => setState(() => volumeValue = v)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text("EXPRESSION", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Expanded(
                    child: Column(
                      children: [
                        const Text("VOLUME", style: TextStyle(color: Colors.amber, fontSize: 10)),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: volumeValue,
                              min: 0,
                              max: 10,
                              activeColor: Colors.amber,
                              onChanged: (v) => setState(() => volumeValue = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: Column(
                      children: [
                        const Text("WAH / GAIN", style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                        Expanded(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Slider(
                              value: wahValue,
                              min: 0,
                              max: 10,
                              activeColor: Colors.redAccent,
                              onChanged: (v) => setState(() => wahValue = v),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPedal(String name, Color color, bool isOn, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        height: 120,
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
    return Column(
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
