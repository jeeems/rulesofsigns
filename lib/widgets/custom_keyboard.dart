import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onDone;

  const CustomKeyboard({
    super.key,
    required this.onKeyPress,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color secondaryColor = Theme.of(context).colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          String buttonText = '';
          IconData? icon;

          switch (index) {
            case 9:
              buttonText = '.';
              break;
            case 10:
              buttonText = '0';
              break;
            case 11:
              icon = Icons.backspace;
              break;
            default:
              buttonText = '${index + 1}';
          }

          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: index == 11
                  ? Colors.redAccent
                  : primaryColor, // Backspace button in red
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (index == 11) {
                onKeyPress('backspace');
              } else if (index == 9) {
                onKeyPress('.');
              } else {
                onKeyPress(buttonText);
              }
            },
            child: index == 11
                ? Icon(icon, color: Colors.white)
                : Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          );
        },
      ),
    );
  }
}
