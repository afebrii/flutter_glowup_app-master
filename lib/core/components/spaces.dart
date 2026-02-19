import 'package:flutter/material.dart';

/// Vertical spacing shortcuts
class SpaceHeight extends StatelessWidget {
  final double height;

  const SpaceHeight(this.height, {super.key});

  /// 4px vertical space
  const SpaceHeight.h4({super.key}) : height = 4;

  /// 6px vertical space
  const SpaceHeight.h6({super.key}) : height = 6;

  /// 8px vertical space
  const SpaceHeight.h8({super.key}) : height = 8;

  /// 12px vertical space
  const SpaceHeight.h12({super.key}) : height = 12;

  /// 16px vertical space
  const SpaceHeight.h16({super.key}) : height = 16;

  /// 20px vertical space
  const SpaceHeight.h20({super.key}) : height = 20;

  /// 24px vertical space
  const SpaceHeight.h24({super.key}) : height = 24;

  /// 32px vertical space
  const SpaceHeight.h32({super.key}) : height = 32;

  /// 40px vertical space
  const SpaceHeight.h40({super.key}) : height = 40;

  /// 48px vertical space
  const SpaceHeight.h48({super.key}) : height = 48;

  /// 64px vertical space
  const SpaceHeight.h64({super.key}) : height = 64;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

/// Horizontal spacing shortcuts
class SpaceWidth extends StatelessWidget {
  final double width;

  const SpaceWidth(this.width, {super.key});

  /// 4px horizontal space
  const SpaceWidth.w4({super.key}) : width = 4;

  /// 8px horizontal space
  const SpaceWidth.w8({super.key}) : width = 8;

  /// 12px horizontal space
  const SpaceWidth.w12({super.key}) : width = 12;

  /// 16px horizontal space
  const SpaceWidth.w16({super.key}) : width = 16;

  /// 20px horizontal space
  const SpaceWidth.w20({super.key}) : width = 20;

  /// 24px horizontal space
  const SpaceWidth.w24({super.key}) : width = 24;

  /// 32px horizontal space
  const SpaceWidth.w32({super.key}) : width = 32;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}
