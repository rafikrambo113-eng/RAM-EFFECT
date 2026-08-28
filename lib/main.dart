import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const RAmEffectApp());
  });
}

class RAmEffectApp extends StatelessWidget {
  const RAmEffectApp({super.key});

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

class PedalType {
  final String name;
  final Color color;
  final List<String> knobLabels;
  const PedalType(this.name, this.color, this.knobLabels);
}

const List<PedalType> availablePedalTypes = [
  PedalType('OD-1', Color(0xFFE0A94A), ['DRIVE', 'TONE']),
  PedalType('FUZZ', Color(0xFFC9B896), ['FUZZ', 'LEVEL']),
  PedalType('EQ-5', Color(0xFFB0B0B0), ['LOW', 'MID', 'HIGH']),
  PedalType('DL-4', Color(0xFF4CAF6D), ['TIME', 'REPEATS', 'MIX']),
  PedalType('CHORUS', Color(0xFF4FA8DE), ['RATE', 'DEPTH']),
  PedalType('LOOPER', Color(0xFF3D8B52), ['LEVEL']),
  PedalType('WAHS', Color(0xFF9B59B6), ['RANGE']),
  PedalType('COMPRESSORS', Color(0xFF7986CB), ['SUSTAIN', 'LEVEL']),
  PedalType('FLANGERS', Color(0xFFEC7FA9), ['RATE', 'DEPTH']),
  PedalType('PHASER', Color(0xFF26C6DA), ['SPEED', 'DEPTH']),
  PedalType('PREAMP', Color(0xFF8D6E63), ['GAIN']),
  PedalType('MODULATION', Color(0xFF66BB6A), ['RATE']),
];

class ChainPedal {
  final String id;
  final PedalType type;
  bool isOn;
  Map<String, double> values;
  ChainPedal({required this.id, required this.type, this.isOn = true})
      : values = {for (var k in type.knobLabels) k: 5.0};
}

class MainRigScreen extends StatefulWidget {
  const MainRigScreen({super.key});

  @override
  State<MainRigScreen> createState() => _MainRigScreenState();
}

class _MainRigScreenState extends State<MainRigScreen> {
  bool leftPanelVisible = true;
  bool ampOn = true;
  bool fpFunctionOn = false;
  double globalVolume = 7;

  final Map<String, double> ampKnobs = {
    'BASS': 5,
    'MID': 5,
    'TREBLE': 6,
    'VOLUME': 7,
    'GAIN': 6,
    'MASTER': 7,
  };
  final Map<String, double> noiseGate = {'THRESHOLD': 3, 'RELEASE': 4};

  List<ChainPedal> chain = [];
  int _pedalCounter = 0;

  List<Map<String, String>> savedBoards = [
    {"name": "Backing Tittle", "sub": "Genre"},
    {"name": "Artist - The InLeep", "sub": "Genre"},
    {"name": "Leost - Rontie", "sub": "Genre"},
    {"name": "Artist - Seerets", "sub": "Genre"},
  ];

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  double vuValue = 0.2;
  Timer? _vuTimer;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    chain.add(_makeChainPedal(availablePedalTypes[0]));
    chain.add(_makeChainPedal(availablePedalTypes[3]));
    _vuTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      final anyOn = ampOn && chain.any((p) => p.isOn);
      if (!mounted) return;
      setState(() {
        vuValue = anyOn ? (0.3 + _rand.nextDouble() * 0.6) : (vuValue * 0.85);
      });
    });
  }

  @override
  void dispose() {
    _vuTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  ChainPedal _makeChainPedal(PedalType type) {
    _pedalCounter++;
    return ChainPedal(id: 'p$_pedalCounter', type: type);
  }

  void _addPedal(PedalType type) {
    setState(() {
      chain.add(_makeChainPedal(type));
    });
  }

  void _removePedal(String id) {
    setState(() {
      chain.removeWhere((p) => p.id == id);
    });
  }

  void _togglePedal(String id) {
    setState(() {
      final p = chain.firstWhere((p) => p.id == id);
      p.isOn = !p.isOn;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  void _saveBoardDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A241C),
        title: const Text('حفظ Board جديد', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'اسم الأغنية أو البورد'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  savedBoards.insert(0, {
                    'name': controller.text,
                    'sub': '${chain.length} pedals',
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _newPreset() {
    setState(() {
      chain.clear();
    });
    _showSnack('بدأت Preset جديد فارغ');
  }

  @override
  Widget build(BuildContext context) {
    final filteredBoards = savedBoards
        .where((b) => (b['name'] ?? '').toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF15120D),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: leftPanelVisible ? 190 : 0,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(),
                        child: leftPanelVisible ? _buildLeftPanel(filteredBoards) : null,
                      ),
                      Expanded(child: _buildMainArea()),
                      _buildRightColumn(),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: () => setState(() => leftPanelVisible = !leftPanelVisible),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black87,
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        leftPanelVisible ? Icons.chevron_left : Icons.chevron_right,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const Text('SHOW/HIDE', style: TextStyle(color: Colors.white70, fontSize: 6)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 46,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.menu, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          const Text(
            'RAM EFFECT',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white54, size: 18),
            onPressed: () => _showSnack('الإعدادات قريباً'),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white54, size: 18),
            onPressed: () => _showSnack('استخدم مربع البحث في القائمة الجانبية'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54, size: 18),
            onPressed: _newPreset,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white54, size: 18),
            onPressed: _saveBoardDialog,
          ),
          IconButton(
            icon: Icon(Icons.power_settings_new, color: ampOn ? Colors.greenAccent : Colors.white24, size: 18),
            onPressed: () => setState(() => ampOn = !ampOn),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(List<Map<String, String>> filteredBoards) {
    return Container(
      color: const Color(0xFF1C1712),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Text('PEDAL LIBRARY',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: availablePedalTypes.map((t) => _buildLibraryIcon(t)).toList(),
              ),
            ),
            const Divider(color: Colors.white12, height: 20),
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 4),
              child: Text('SONG & BOARD EXPLORER',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'بحث...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 16),
                  filled: true,
                  fillColor: Colors.black38,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => searchQuery = v),
              ),
            ),
            const SizedBox(height: 6),
            ...filteredBoards.map((b) => _buildSongItem(b)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryIcon(PedalType type) {
    return GestureDetector(
      onTap: () => _addPedal(type),
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: type.color.withOpacity(0.6)),
        ),
        child: Column(
          children: [
            Icon(Icons.graphic_eq, color: type.color, size: 18),
            const SizedBox(height: 2),
            Text(
              type.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongItem(Map<String, String> board) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.amber.withOpacity(0.3),
        child: const Icon(Icons.music_note, color: Colors.amber, size: 14),
      ),
      title: Text(
        board['name'] ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        board['sub'] ?? '',
        style: const TextStyle(color: Colors.white38, fontSize: 10),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.play_arrow, color: Colors.white54, size: 16),
      onTap: () => _showSnack('تحميل: ${board['name']}'),
    );
  }

  Widget _buildMainArea() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text('UNLIMITED PEDAL CHAIN',
              style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2)),
        ),
        Expanded(
          flex: 5,
          child: chain.isEmpty
              ? const Center(
                  child: Text(
                    'دوس على دواسة من القائمة الجانبية عشان تضيفها',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: chain.map((p) => _buildChainPedal(p)).toList(),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton('SAVE BOARD', Icons.add, _saveBoardDialog),
              const SizedBox(width: 10),
              _actionButton('NEW PRESET', Icons.add, _newPreset),
            ],
          ),
        ),
        Expanded(flex: 6, child: _buildAmpSection()),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            const SizedBox(width: 4),
            Icon(icon, color: Colors.amber, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildChainPedal(ChainPedal p) {
    return Container(
      width: 118,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: p.isOn ? p.type.color : p.type.color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black54, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(2, 3))],
            ),
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: p.type.knobLabels
                      .map((k) => Knob(
                            label: k,
                            value: p.values[k] ?? 5,
                            size: 38,
                            onChanged: (v) => setState(() => p.values[k] = v),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  p.type.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _togglePedal(p.id),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: p.isOn ? Colors.greenAccent : Colors.black45,
                      border: Border.all(color: Colors.white54, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: () => _removePedal(p.id),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black87),
                child: const Icon(Icons.close, size: 12, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmpSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF241D14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A3A22), width: 2),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (i) => _buildTube()),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'TUBE MASTER 50',
                  style: TextStyle(color: Colors.amber.withOpacity(0.9), fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 90,
                  height: 60,
                  child: CustomPaint(painter: VuMeterPainter(vuValue)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => ampOn = !ampOn),
                    child: Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ampOn ? Colors.greenAccent : Colors.black54,
                            border: Border.all(color: Colors.white38),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(ampOn ? 'ON' : 'OFF', style: const TextStyle(color: Colors.white54, fontSize: 8)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ...ampKnobs.keys.map((k) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Knob(
                          label: k,
                          value: ampKnobs[k]!,
                          size: 40,
                          onChanged: (v) => setState(() => ampKnobs[k] = v),
                        ),
                      )),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.white12,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  const SizedBox(
                    width: 40,
                    child: Text('NOISE\nGATE',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 8)),
                  ),
                  ...noiseGate.keys.map((k) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Knob(
                          label: k,
                          value: noiseGate[k]!,
                          size: 36,
                          onChanged: (v) => setState(() => noiseGate[k] = v),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTube() {
    return Container(
      width: 16,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: RadialGradient(
          colors: [
            ampOn ? Colors.orangeAccent : Colors.white24,
            const Color(0xFF241D14),
          ],
        ),
        border: Border.all(color: Colors.black87),
      ),
    );
  }

  Widget _buildRightColumn() {
    return Container(
      width: 90,
      color: const Color(0xFF1C1712),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          const Text('Global\nVolume',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 6),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: globalVolume,
                min: 0,
                max: 10,
                activeColor: Colors.amber,
                onChanged: (v) => setState(() => globalVolume = v),
              ),
            ),
          ),
          const Text('Global Volume', style: TextStyle(color: Colors.white38, fontSize: 8)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => fpFunctionOn = !fpFunctionOn),
            child: Container(
              width: 66,
              height: 140,
              decoration: BoxDecoration(
                color: fpFunctionOn ? Colors.deepPurple.withOpacity(0.6) : Colors.black45,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.change_history, color: fpFunctionOn ? Colors.amber : Colors.white38, size: 22),
                  const SizedBox(height: 6),
                  const Text('F&P Function',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 9)),
                  const Text('Wah/Pitch',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 8)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Knob extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double size;
  const Knob({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final angle = (value / 10) * 270 - 135;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onVerticalDragUpdate: (details) {
            final newValue = (value - details.delta.dy * 0.12).clamp(0.0, 10.0);
            onChanged(newValue);
          },
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0xFF3A3A3A), Color(0xFF141414)]),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 3, offset: Offset(1, 2))],
            ),
            child: Transform.rotate(
              angle: angle * pi / 180,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 3),
                  width: 2.5,
                  height: size / 2 - 6,
                  color: Colors.amberAccent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 8)),
      ],
    );
  }
}

class VuMeterPainter extends CustomPainter {
  final double value;
  VuMeterPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF3E3B0);
    final rect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(4));
    canvas.drawRRect(rect, bg);

    final center = Offset(size.width / 2, size.height * 0.95);
    final radius = size.width * 0.45;

    final tickPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.2;
    for (int i = 0; i <= 8; i++) {
      final a = pi + (pi * i / 8);
      final p1 = Offset(center.dx + radius * 0.8 * cos(a), center.dy + radius * 0.8 * sin(a));
      final p2 = Offset(center.dx + radius * cos(a), center.dy + radius * sin(a));
      canvas.drawLine(p1, p2, tickPaint);
    }

    final needleAngle = pi + pi * value.clamp(0.0, 1.0);
    final needleEnd = Offset(
      center.dx + radius * 0.85 * cos(needleAngle),
      center.dy + radius * 0.85 * sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant VuMeterPainter oldDelegate) => oldDelegate.value != value;
}
