import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';

// ─── Base shimmer box ─────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppDimensions.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─── Order card shimmer ───────────────────────────────────────────────────────

class ShimmerOrderCard extends StatelessWidget {
  const ShimmerOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.gapXs,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.darkBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _rect(60, 20, radius: AppDimensions.radiusXs),
                const Spacer(),
                _rect(80, 20, radius: AppDimensions.radiusXs),
              ],
            ),
            const SizedBox(height: AppDimensions.gapMd),
            _rect(double.infinity, 14),
            const SizedBox(height: AppDimensions.gapSm),
            _rect(200, 14),
            const SizedBox(height: AppDimensions.gapMd),
            Row(
              children: [
                _rect(100, 16),
                const Spacer(),
                _rect(80, 36, radius: AppDimensions.radiusLg),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _rect(double w, double h, {double radius = 6}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceElevated,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

// ─── List item shimmer ────────────────────────────────────────────────────────

class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.gapSm,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.gapMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceElevated,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXs),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.gapSm),
                  Container(
                    height: 12,
                    width: 160,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceElevated,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXs),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Banner shimmer ───────────────────────────────────────────────────────────

class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLg),
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }
}

// ─── Profile shimmer ──────────────────────────────────────────────────────────

class ShimmerProfile extends StatelessWidget {
  const ShimmerProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.darkSurfaceElevated,
            ),
            const SizedBox(height: AppDimensions.sp16),
            Container(
              height: 20,
              width: 160,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
            ),
            const SizedBox(height: AppDimensions.gapSm),
            Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceElevated,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grid item shimmer ────────────────────────────────────────────────────────

class ShimmerGridItem extends StatelessWidget {
  const ShimmerGridItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          const SizedBox(height: AppDimensions.gapSm),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            ),
          ),
          const SizedBox(height: AppDimensions.gapXs),
          Container(
            height: 10,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceElevated,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Profile card shimmer (light background) ─────────────────────────────────

class ShimmerProfileCard extends StatelessWidget {
  const ShimmerProfileCard({super.key});

  static const Color _base      = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Shimmer.fromColors(
        baseColor: _base,
        highlightColor: _highlight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 44),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 20,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 14,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Full profile-page skeleton (light background) ───────────────────────────

class ShimmerProfilePage extends StatelessWidget {
  const ShimmerProfilePage({super.key});

  static const Color _base      = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 44),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(height: 20, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 4),
                        Container(height: 14, width: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 4),
                        Container(height: 14, width: 150, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.gapXl),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.gapLg),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.gapXl),

          // Menu items
          for (int i = 0; i < 4; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              child: Row(
                children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                  const SizedBox(width: 12),
                  Expanded(child: Container(height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(width: 12),
                  Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
            if (i < 3) Container(height: 0.5, color: Colors.white),
          ],
        ],
      ),
    );
  }
}

// ─── Edit-profile skeleton (light background) ────────────────────────────────

class ShimmerEditProfile extends StatelessWidget {
  const ShimmerEditProfile({super.key});

  static const Color _base      = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _label(100),
          const SizedBox(height: 8),
          _field(),
          const SizedBox(height: 16),
          _label(120),
          const SizedBox(height: 8),
          _field(),
          const SizedBox(height: 16),
          _label(110),
          const SizedBox(height: 8),
          _field(),
        ],
      ),
    );
  }

  Widget _label(double width) => Container(
        width: width,
        height: 13,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        ),
      );

  Widget _field() => Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      );
}

// ─── Shimmer list helper ──────────────────────────────────────────────────────

class ShimmerList extends StatelessWidget {
  final int count;
  final Widget Function() itemBuilder;

  const ShimmerList({
    super.key,
    this.count = 6,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }
}
