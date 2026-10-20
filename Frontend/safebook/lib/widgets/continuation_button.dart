import 'package:flutter/material.dart';

class ContinuationButton extends StatelessWidget {
  const ContinuationButton({
    super.key,
    required this.continuationText,
    required this.onTap,
  });
  final String continuationText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 50),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10),
        ),
      ),
      child: Text(
        continuationText,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
