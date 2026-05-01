import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget de carga tipo esqueleto (Shimmer) reutilizable en toda la app
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 60,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1C284A) : const Color(0xFFE2E8F0),
      highlightColor: isDark ? const Color(0xFF2A3F6F) : const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C284A) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Fila de shimmer para simular una lista de carga
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({super.key, this.itemCount = 4, this.itemHeight = 64});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerBox(height: itemHeight),
        ),
      ),
    );
  }
}
