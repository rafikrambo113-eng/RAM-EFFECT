import 'package:flutter/material.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141414),
      ),
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
  bool isDriveOn = true;
  bool isDelayOn = false;
  bool isReverbOn = true;
  bool isChorusOn = false;

  double gain = 7.5;
  double bass = 6.0;
  double treble = 8.0;
  double masterVolume = 8.5;
  double wahValue = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RAM EFFECT - GUITAR RIG PRO'),
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    // AMP HEAD
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF221C16),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade700, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("TUBE MASTER 50W",
                                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                                Icon(Icons.power_settings_new, color: Colors.redAccent, size: 18),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildRotaryKnob("GAIN", gain, (v) => setState(() => gain = v)),
                                _buildRotaryKnob("BASS", bass, (v) => setState(() => bass = v)),
                                _buildRotaryKnob("TREBLE", treble, (v) => setState(() => treble = v)),
                                _buildRotaryKnob("MASTER", masterVolume, (v) => setState(() => masterVolume = v)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // PEDALBOARD
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStompBox("OVERDRIVE", Colors.green.shade800, isDriveOn, () {
                              setState(() => isDriveOn = !isDriveOn);
                            }),
                            _buildStompBox("DELAY", Colors.blue.shade900, isDelayOn, () {
                              setState(() => isDelayOn = !isDelayOn);
                            }),
                            _buildStompBox("REVERB", Colors.purple.shade900, isReverbOn, () {
                              setState(() => isReverbOn = !isReverbOn);
                            }),
                            _buildStompBox("CHORUS", Colors.orange.shade900, isChorusOn, () {
                              setState(() => isChorusOn = !isChorusOn);
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // WAH PEDAL
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Text("WAH", style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
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
                      Text(wahValue.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRotaryKnob(String label, double val, ValueChanged<double> onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        GestureDetector(
          onVerticalDragUpdate: (details) {
            double change = -details.delta.dy / 15;
            double newVal = (val + change).clamp(0.0, 10.0);
            onChanged(newVal);
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade900,
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Center(
              child: Text(val.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStompBox(String name, Color color, bool isOn, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isOn ? color : color.withOpacity(0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOn ? Colors.redAccent : Colors.black,
              ),
            ),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                border: Border.all(color: Colors.grey.shade800, width: 3),
              ),
              child: const Icon(Icons.circle, color: Colors.black38, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
