import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StarRow extends StatelessWidget {
  final int stars;
  final double size;

  const StarRow({super.key, required this.stars, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Icon(
            i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < stars ? AppColors.star : AppColors.starEmpty,
          ),
      ],
    );
  }
}
