import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const TitleBar({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Center(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: TextStyle(color: hintColor),
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      hintText: "Search Exercise",
                      hintStyle: TextStyle(color: hintColor.withAlpha(179)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: controller.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.clear();
                          onChanged("");
                        },
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(2),
                        icon: const Icon(Icons.close_sharp, color: Colors.grey))
                    : IconButton(
                        onPressed: () {},
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(2),
                        icon: const Icon(Icons.person_2_rounded, color: Colors.white),
                        constraints: const BoxConstraints(),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: Colors.grey,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
