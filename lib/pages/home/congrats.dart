import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:workitoff/navigation_bar.dart';
import 'package:workitoff/providers/user_provider.dart';
import 'package:workitoff/widgets.dart';

final BottomNavigationBar navBar = navBarGlobalKey.currentWidget;

class ParticleModel {
  Animatable tween;
  double size;
  AnimationProgress animationProgress;
  Random random;

  ParticleModel(this.random) {
    restart();
  }

  restart({Duration time = Duration.zero}) {
    // For the y-values -- 0.0 is top, 1.0 is bottom
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final duration = Duration(milliseconds: 2500 + random.nextInt(2500));

    tween = MultiTrackTween([
      Track("x").add(duration, Tween(begin: startPosition.dx, end: endPosition.dx), curve: Curves.easeInOutSine),
      Track("y").add(duration, Tween(begin: startPosition.dy, end: endPosition.dy), curve: Curves.easeIn),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    // size = 0.2 + random.nextDouble() * 0.4;
    size = 0.07;
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  Duration time;
  List<Color> colors;

  ParticlePainter(this.particles, this.time, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    // final paint = Paint()..color = Colors.white.withAlpha(50);
    int index = 0;
    particles.forEach((particle) {
      var progress = particle.animationProgress.progress(time);
      final animation = particle.tween.transform(progress);
      final position = Offset(animation["x"] * size.width, animation["y"] * size.height);
      final paint = Paint()..color = colors.elementAt(index);
      canvas.drawCircle(position, size.width * 0.2 * particle.size, paint);
      index++;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Particles extends StatefulWidget {
  final int numberOfParticles;

  Particles(this.numberOfParticles);

  @override
  _ParticlesState createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random random = Random();

  final List<ParticleModel> _particles = [];
  final List<Color> _colors = [];

  Color _makeRadomColor() {
    int alpha = (Random().nextInt(250) * 0.5 ).round();
    return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0).withAlpha(125 + alpha);
  }

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      _particles.add(ParticleModel(random));
    });

    List.generate(widget.numberOfParticles, (index) {
      _colors.add(_makeRadomColor());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      startTime: Duration(seconds: 30),
      onTick: _simulateParticles,
      builder: (context, time) {
        _simulateParticles(time);
        return CustomPaint(
          painter: ParticlePainter(_particles, time, _colors),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    _particles.forEach((particle) => particle.maintainRestart(time));
  }
}

class CongratsPage extends StatelessWidget {
  Widget _buildColumn(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Congrats!', style: TextStyle(fontSize: 40)),
          SizedBox(height: 30),
          Text('You Worked It Off!', style: TextStyle(fontSize: 30)),
          SizedBox(height: 80),
          Container(
            alignment: Alignment.center,
            width: 180,
            height: 35,
            decoration: BoxDecoration(
              color: Color(0xff4ff7d3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              child: const Text(
                'Log New Meal',
                style: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Provider.of<WorkItOffUser>(context, listen: false).updateProfile(calsAdded: 0, calsBurned: 0);
                navBar.onTap(1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      decoration: getBasicGradient(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: buildBackground()),
        Positioned.fill(child: Particles(200)),
        Positioned.fill(child: _buildColumn(context)),
      ],
    );
  }
}
