import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_chat/widget/common/loading_shimmer.dart';

class ProfileCardShimmer extends StatelessWidget {
  const ProfileCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingShimmer(height: 200, width: 200),
        LoadingShimmer(height: 30, width: 150),
        LoadingShimmer(height: 50, width: 150),
        LoadingShimmer(height: 50, width: 150),
      ],
    );
  }
}
