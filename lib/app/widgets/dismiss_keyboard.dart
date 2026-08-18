import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: _KeyboardDoneBar(child: child),
    );
  }
}

class _KeyboardDoneBar extends StatelessWidget {
  final Widget child;
  static const double _height = 40;

  const _KeyboardDoneBar({required this.child});

  void _dismiss() {
    HapticFeedback.lightImpact();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final keyboardOpen = mq.viewInsets.bottom > 0;

    return MediaQuery(
      data: mq.copyWith(
        viewInsets: keyboardOpen
            ? EdgeInsets.fromLTRB(
                mq.viewInsets.left,
                mq.viewInsets.top,
                mq.viewInsets.right,
                mq.viewInsets.bottom + _height,
              )
            : mq.viewInsets,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          if (keyboardOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: mq.viewInsets.bottom,
              child: Material(
                color: AppColors.otpBoxBg,
                child: InkWell(
                  onTap: _dismiss,
                  child: SizedBox(
                    height: _height,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Done',
                          style: AppTextStyles.pSmallSemiBold.copyWith(
                            color: AppColors.tintBlue,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
