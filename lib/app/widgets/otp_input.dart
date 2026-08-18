import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class OtpInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final ValueChanged<String> onChanged;
  final bool autofocus;
  final MainAxisAlignment alignment;
  final double boxSize;
  final bool showDashes;

  const OtpInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.onChanged,
    this.autofocus = false,
    this.alignment = MainAxisAlignment.start,
    this.boxSize = 48,
    this.showDashes = false,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _requestFocus() {
    HapticFeedback.selectionClick();
    if (!widget.focusNode.hasFocus) widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([widget.controller, widget.focusNode]),
          builder: (context, _) {
            final text = widget.controller.text;
            final hasFocus = widget.focusNode.hasFocus;
            final activeIndex =
                text.length < widget.length ? text.length : -1;
            return Row(
              mainAxisAlignment: widget.alignment,
              mainAxisSize: (widget.alignment == MainAxisAlignment.center ||
                      widget.alignment == MainAxisAlignment.start)
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              children: List.generate(
                  widget.showDashes
                      ? (widget.length * 2 - 1)
                      : widget.length, (i) {
                if (widget.showDashes && i % 2 != 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: 12,
                      height: 1,
                      color: const Color(0xFFE5E7EB),
                    ),
                  );
                }

                final index = widget.showDashes ? i ~/ 2 : i;
                final filled = index < text.length;
                final isActive = hasFocus && index == activeIndex;
                final showBorder = filled || isActive;
                final digit = filled ? text[index] : '';

                return Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: widget.showDashes ? 0 : 6),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _requestFocus,
                    child: Container(
                      width: widget.boxSize,
                      height: widget.boxSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: filled
                            ? AppColors.white
                            : AppColors.otpBoxBg,
                        borderRadius: BorderRadius.circular(12),
                        border: showBorder
                            ? Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: isActive && !filled
                          ? FadeTransition(
                              opacity: _blinkController,
                              child: Container(
                                width: 2,
                                height: widget.boxSize * 0.5,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            )
                          : Text(
                              digit,
                              style: AppTextStyles.pMedium.copyWith(
                                color: AppColors.otpDigit,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        SizedBox(
          width: 1,
          height: 1,
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.length),
            ],
            showCursor: false,
            cursorWidth: 0,
            style: const TextStyle(color: Colors.transparent, fontSize: 1),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
