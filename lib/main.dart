
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';


// --- DATA MODEL & ASSETS ---

class Assets {
  // Using your local GIFs as the source for all icons
  static const String dart = 'assets/0106.gif';
  static const String flutter = 'assets/01060.gif';
  static const String riverpod = 'assets/0106.gif';
  static const String firebase = 'assets/01060.gif';
  static const String supabase = 'assets/0106.gif';
}

class SkillModel {
  final String imageUrl;
  final String title;
  final double rate;
  final String? about;
  final Color skillColor;

  SkillModel({
    required this.imageUrl,
    required this.title,
    required this.rate,
    this.about,
    Color? color,
  }) : skillColor = color ?? Colors.blue;
}

List<SkillModel> testSkills = [
  SkillModel(imageUrl: Assets.dart, title: 'Dart', rate: 0.88, color: Colors.blue, about: 'Core language for development.'),
  SkillModel(imageUrl: Assets.flutter, title: 'Flutter', rate: 0.95, color: const Color(0xFF44D1FD), about: 'Expert in building UIs.'),
  SkillModel(imageUrl: Assets.riverpod, title: 'Bloc', rate: 0.80, color: Colors.indigo, about: 'State management.'),
  SkillModel(imageUrl: Assets.firebase, title: 'Firebase', rate: 0.75, color: Colors.orange, about: 'Backend services.'),
  SkillModel(imageUrl: Assets.supabase, title: 'Supabase', rate: 0.70, color: const Color(0xFF34B27B), about: 'Open-source DB.'),
];

void main() => runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdvancevToolTip()
));

// --- MAIN SCREEN ---

class AdvancevToolTip extends StatelessWidget {
  const AdvancevToolTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A), // Dark premium background
      body: Stack(
        children: [
          // Background Grid
          Positioned.fill(child: CustomPaint(painter: GridPainter())),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: testSkills.map((skill) => SkillItem(skill: skill)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ICON ITEM WITH GLOW ---

class SkillItem extends StatefulWidget {
  const SkillItem({super.key, required this.skill});
  final SkillModel skill;

  @override
  State<SkillItem> createState() => _SkillItemState();
}

class _SkillItemState extends State<SkillItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool isFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _animation = Tween<double>(begin: 0.0, end: 15.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: CustomToolTip(
            skill: widget.skill,
            onEnter: () { setState(() => isFocus = true); _controller.forward(); },
            onExit: () { setState(() => isFocus = false); _controller.reverse(); },
            child: Transform.translate(
              offset: Offset(0.0, -_animation.value),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    padding: const EdgeInsets.all(18), // Keeps logo centered and clean
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isFocus ? widget.skill.skillColor : Colors.white10,
                          width: 2
                      ),
                      boxShadow: isFocus ? [
                        BoxShadow(
                            color: widget.skill.skillColor.withOpacity(0.4),
                            blurRadius: 25,
                            spreadRadius: 2
                        )
                      ] : [],
                    ),
                    child: Image.asset(widget.skill.imageUrl, fit: BoxFit.contain), // Local GIF logic
                  ),
                  const SizedBox(height: 15),
                  Text(
                      widget.skill.title,
                      style: TextStyle(
                          color: isFocus ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      )
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- TOOLTIP OVERLAY ---

class CustomToolTip extends StatefulWidget {
  const CustomToolTip({super.key, required this.child, required this.onEnter, required this.onExit, required this.skill});
  final SkillModel skill;
  final Widget child;
  final VoidCallback onEnter;
  final VoidCallback onExit;

  @override
  State<CustomToolTip> createState() => _CustomToolTipState();
}

class _CustomToolTipState extends State<CustomToolTip> {
  final LayerLink layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 240,
        child: CompositedTransformFollower(
          link: layerLink,
          offset: const Offset(-80, -200), // Centers the card above the icon
          child: Material(
            color: Colors.transparent,
            child: ToolTipCard(skill: widget.skill),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) { widget.onEnter(); _showOverlay(); },
      onExit: (_) { widget.onExit(); _overlayEntry?.remove(); },
      child: CompositedTransformTarget(link: layerLink, child: widget.child),
    );
  }
}

class ToolTipCard extends StatelessWidget {
  const ToolTipCard({super.key, required this.skill});
  final SkillModel skill;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: skill.rate),
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // Glass effect
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(skill.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 60, width: 60,
                        child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 6,
                            color: skill.skillColor,
                            backgroundColor: Colors.white10
                        ),
                      ),
                      Text("${(value * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(skill.about ?? "", style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- GRID PAINTER ---

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.03)..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 45) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 45) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}