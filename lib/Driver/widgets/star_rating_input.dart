import 'package:flutter/material.dart';

import '../theme/driver_theme.dart';

class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  final int rating;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(5, (index) {
        final int starValue = index + 1;
        return IconButton(
          tooltip: '$starValue Star',
          onPressed: () => onRatingChanged(starValue),
          icon: Icon(
            starValue <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: starValue <= rating
                ? DriverThemePalette.accent
                : DriverThemePalette.textMuted,
            size: 34,
          ),
        );
      }),
    );
  }
}
