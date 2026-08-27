import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const GuitarRigApp());
}

class GuitarRigApp extends StatelessWidget {
  const GuitarRigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GUITAR EDGE PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
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
  // Pedals state
  bool overdriveOn = true;
  bool delayOn = false;
  bool reverbOn = true;
  bool chorusOn = false;
  bool fpActive = true;

  double wahValue = 0.5;
  double globalVolume = 0.8;
  double noiseGate = 0.4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar
            Container(
              height: 40,
              color: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.menu, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  const Text('GUITAR EDGE PRO: UNLIMITED EFFECTS', 
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.tune, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.save, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.settings, size: 18), onPressed: () {}),
                ],
              ),
            ),
            
            // 2. Main Workspace
            Expanded(
              child: Row(
                children: [
                  // Left Side: Pedals + Amp Unit
                  Expanded(
                    flex: 7,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          // Top Section: Stompboxes & Wah
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF222222),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Row(
                                children: [
                                  _buildStompPedal("OVERDRIVE", Colors.green.shade700, overdriveOn, () => setState(() => overdriveOn = !overdriveOn)),
                                  _buildStompPedal("DELAY", Colors.blue.shade700, delayOn, () => setState(() => delayOn = !delayOn)),
                                  _buildStompPedal("REVERB", Colors.purple.shade700, reverbOn, () => setState(() => reverbOn = !reverbOn)),
                                  _buildStompPedal("CHORUS", Colors.cyan.shade700, chorusOn, () => setState(() => chorusOn = !chorusOn)),
                                  const VerticalDivider(color: Colors.white24, width: 12),
                                  _buildWahPedal(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Bottom Section: Expression Pedals & Amp Head
                          Expanded(
                            flex: 5,
                            child: Row(
                              children: [
                                // F&P + Global Pedals
                                Container(
                                  width: 140,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: _buildBigExpressionPedal("F&P", fpActive, () => setState(() => fpActive = !fpActive))),
                                      const SizedBox(width: 4),
                                      Expanded(child: _buildVolumePedal()),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Tube Amp Cabinet
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B2F23),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber.shade800, width: 2),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        const Text("TUBE MASTER 50", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _MiniKnob(label: "BASS"),
                                            _MiniKnob(label: "MID"),
                                            _MiniKnob(label: "TREBLE"),
                                            _MiniKnob(label: "VOLUME"),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                          child: const Text("12x4 CABINET", style: TextStyle(color: Colors.white70, fontSize: 10)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Signal Meter & Noise Gate
                                Container(
                                  width: 50,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text("SIGNAL", style: TextStyle(color: Colors.amber, fontSize: 8)),
                                      Expanded(
                                        child: Container(
                                          width: 8,
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Colors.red, Colors.yellow, Colors.green],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const _MiniKnob(label: "GATE"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Side: Explorer & Presets Library
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: const Color(0xFF1E1E1E),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.black,
                            child: const Row(
                              children: [
                                Expanded(child: Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("SONG LIBRARY", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold))))),
                                Expanded(child: Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("TONEBRIDGE STYLE", style: TextStyle(color: Colors.white54, fontSize: 11))))),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "SEARCH: Stairway to Heaven...",
                                hintStyle: const TextStyle(fontSize: 10),
                                isDense: true,
                                prefixIcon: const Icon(Icons.search, size: 16),
                                fillColor: Colors.black26,
                                filled: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                _buildPresetTile("FEROZ SOUL", "Acoustic intro sound", Colors.purple),
                                _buildPresetTile("JAMES BROWN FUNK", "Crunch guitar for Funk", Colors.red),
                                _buildPresetTile("HOTEL CALIFORNIA", "Classic solo tone", Colors.amber),
                                _buildPresetTile("METALLICA RIFFS", "Heavy distortion", Colors.blueGrey),
                                _buildPresetTile("CLEAN ATMOSPHERE", "Chorus & Delay ambient", Colors.blue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStompPedal(String name, Color color, bool isOn, VoidCallback toggle) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isOn ? color : color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: isOn ? Colors.redAccent : Colors.black)),
                Text(name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [_MiniKnob(label: "GAIN"), _MiniKnob(label: "VOL")],
            ),
            GestureDetector(
              onTap: toggle,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                child: const Icon(Icons.radio_button_checked, size: 16, color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWahPedal() {
    return Container(
      width: 50,
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          const Text("WAH", style: TextStyle(color: Colors.white70, fontSize: 9)),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: wahValue,
                onChanged: (v) => setState(() => wahValue = v),
                activeColor: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigExpressionPedal(String label, bool active, VoidCallback toggle) {
    return GestureDetector(
      onTap: toggle,
      child: Container(
        decoration: BoxDecoration(
          color: active ? Colors.grey.shade900 : Colors.black,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? Colors.amber : Colors.white24),
        ),
        child: Center(child: Text(label, style: TextStyle(color: active ? Colors.amber : Colors.white38, fontWeight: FontWeight.bold, fontSize: 12))),
      ),
    );
  }

  Widget _buildVolumePedal() {
    return Container(
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("100%", style: TextStyle(color: Colors.amber, fontSize: 8)),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: globalVolume,
                onChanged: (v) => setState(() => globalVolume = v),
                activeColor: Colors.amber,
              ),
            ),
          ),
          const Text("0%", style: TextStyle(color: Colors.white38, fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildPresetTile(String title, String subtitle, Color avatarColor) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(backgroundColor: avatarColor, radius: 12, child: const Icon(Icons.music_note, size: 12, color: Colors.white)),
      title: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 9, color: Colors.white54)),
      onTap: () {},
    );
  }
}

class _MiniKnob extends StatelessWidget {
  final String label;
  const _MiniKnob({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 7, color: Colors.white70)),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade800, border: Border.all(color: Colors.amber, width: 1)),
        ),
      ],
    );
  }
}
