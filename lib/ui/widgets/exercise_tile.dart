import 'package:flutter/material.dart';
import 'package:your_reps/data/objects/exercise.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final void Function() onTap;
  final void Function() onPin;
  final List<String> muscles;
  final String lastSetInfo;
  final String lastDate;
  final bool isPinned;

  const ExerciseTile({
    required this.exercise,
    required this.onTap,
    required this.onPin,
    required this.muscles,
    required this.lastSetInfo,
    required this.lastDate,
    required this.isPinned,
    super.key,
  });

  Color generateColor(String input) {
    final hash = input.codeUnits.fold(0, (prev, elem) => prev + elem);
    final hue = (hash * 37) % 360;
    return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.45, 0.65).toColor();
  }

  String getAcronym(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) return parts.first[0].toUpperCase();
    if (parts.first.length >= 2) return parts.first.substring(0, 2).toUpperCase();
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = generateColor(exercise.name);
    final acronym = getAcronym(exercise.name);

    return Column(
      children: [
        SizedBox(
          height: 60,
          width: MediaQuery.of(context).size.width,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Replace your Container with this
                  CircleAvatar(
                    // The radius controls the size of the circle.
                    radius: 24, // Adjust this value to your desired size
                    backgroundColor: color,
                    child: Text(
                      acronym,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          exercise.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          muscles.join(' - '),
                          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          lastSetInfo,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(lastDate),
                      GestureDetector(
                          onTap: onPin,
                          child:
                              Icon(Icons.push_pin_rounded, size: 20, color: isPinned ? Colors.orangeAccent : Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
