import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swiftdrop_driver_app/generated/assets.dart';
import '../constants/app_strings.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../themes/app_text_styles.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class AppTextField extends StatelessWidget {
  static const OutlineInputBorder _fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
  );

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final Color? fillColor;
  final Color? textColor;
  final Color? labelColor;
  final bool isRequired;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final double? labelFontSize;
  final FontWeight? labelFontWeight;
  final String? labelFontFamily;
  final TextStyle? hintStyle;
  final AutovalidateMode? autovalidateMode;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.errorText,
    this.fillColor,
    this.textColor,
    this.labelColor,
    this.isRequired = false,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.labelFontSize,
    this.labelFontWeight,
    this.labelFontFamily,
    this.hintStyle,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabelStyle = AppTextStyles.build(
      size: labelFontSize ?? 14,
      height: labelFontSize != null ? null : 20,
      weight: labelFontWeight ?? FontWeight.w500,
      fontFamily: labelFontFamily,
      color: labelColor ?? textColor ?? AppColors.textSecondary,
    );

    final effectiveStyle = AppTextStyles.build(
      size: fontSize ?? 14,
      height: fontSize != null ? null : 20,
      weight: fontWeight ?? FontWeight.w400,
      fontFamily: fontFamily,
      color: textColor ?? AppColors.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          RichText(
            text: TextSpan(
              text: label!,
              style: effectiveLabelStyle,
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.gapSm),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: effectiveStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintStyle ?? AppTextStyles.build(
              size: 14,
              height: 20,
              weight: FontWeight.w400,
              color: AppColors.textHint,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            errorStyle: AppTextStyles.build(
              size: 12,
              height: 16,
              weight: FontWeight.w400,
              color: AppColors.error,
            ).copyWith(fontStyle: FontStyle.normal),
            counterText: '',
            filled: true,
            fillColor: fillColor ?? (enabled ? AppColors.darkInputBg : AppColors.darkSurface),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            prefixIconConstraints: const BoxConstraints(minHeight: 0, minWidth: 0),
            border: _fieldBorder,
            enabledBorder: _fieldBorder,
            focusedBorder: _fieldBorder,
            disabledBorder: _fieldBorder,
            errorBorder: _fieldBorder,
            focusedErrorBorder: _fieldBorder,
          ),
          validator: validator,
          autovalidateMode: autovalidateMode,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
        ),
      ],
    );
  }
}

// ─── Phone field ──────────────────────────────────────────────────────────────

class PhoneTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  // Country picker callback
  final VoidCallback? onCountryTap;

  // Selected country data
  final String countryCode;
  final String flagEmoji;
  final String? isoCode;

  final Color? fillColor;
  final Color? textColor;
  final Color? labelColor;
  final bool isRequired;
  final bool enabled;
  final bool readOnly;
  final Widget? suffixIcon;

  // Input text style
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;

  // Label style
  final double? labelFontSize;
  final FontWeight? labelFontWeight;
  final String? labelFontFamily;

  // Country code style
  final double? countryCodeFontSize;
  final FontWeight? countryCodeFontWeight;
  final String? countryCodeFontFamily;

  // Hint style
  final double? hintFontSize;
  final FontWeight? hintFontWeight;
  final String? hintFontFamily;

  // Flag sizing
  final double flagHeight;

  final AutovalidateMode? autovalidateMode;

  const PhoneTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,

    this.onCountryTap,

    this.countryCode = '+44',
    this.flagEmoji = '🇬🇧',
    this.isoCode,
    this.label = AppStrings.mobileNumber,

    this.fillColor,
    this.textColor,
    this.labelColor,
    this.isRequired = false,

    this.fontSize,
    this.fontWeight,
    this.fontFamily,

    this.labelFontSize,
    this.labelFontWeight,
    this.labelFontFamily,

    this.countryCodeFontSize,
    this.countryCodeFontWeight,
    this.countryCodeFontFamily,

    this.hintFontSize,
    this.hintFontWeight,
    this.hintFontFamily,

    this.flagHeight = 24,
    this.autovalidateMode,
    this.enabled = true,
    this.readOnly = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final errorStyle = AppTextStyles.build(
      size: 12,
      height: 16,
      weight: FontWeight.w400,
      color: AppColors.error,
    ).copyWith(fontStyle: FontStyle.normal);

    return FormField<String>(
      validator: validator,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      initialValue: controller?.text ?? '',
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(context, state),
            if (state.hasError) ...[
              const SizedBox(height: 6),
              Text(state.errorText!, style: errorStyle),
            ],
          ],
        );
      },
    );
  }

  Widget _buildField(BuildContext context, FormFieldState<String> state) {
    // Logic to get ISO code for flag image
    String? effectiveIsoCode = isoCode?.toLowerCase();
    
    if (effectiveIsoCode == null) {
      try {
        final country = CountryService().findByPhoneCode(countryCode.replaceAll('+', ''));
        effectiveIsoCode = country?.countryCode.toLowerCase();
      } catch (_) {}
    }

    return AppTextField(
      label: label,

      isRequired: isRequired,
      hint: AppStrings.enterMobileNumber,

      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      suffixIcon: suffixIcon,

      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,

      maxLength: 12,

      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(12),
      ],

      fillColor: fillColor,
      textColor: textColor ?? Colors.black,
      labelColor: labelColor,

      // Input text style
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight,
      fontFamily: fontFamily,

      // Label style
      labelFontSize: labelFontSize,
      labelFontWeight: labelFontWeight,
      labelFontFamily: labelFontFamily,

      // Hint style
      hintStyle: AppTextStyles.build(
        size: 14,
        height: 16,
        weight: FontWeight.w400,
        color: AppColors.textHint,
      ),

      prefixIcon: GestureDetector(
        onTap: onCountryTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onCountryTap!();
              },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -1),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 36,
                    height: 24,
                    child: effectiveIsoCode != null
                        ? Image.network(
                            'https://flagcdn.com/w80/$effectiveIsoCode.png',
                            width: 36,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => FittedBox(
                              fit: BoxFit.cover,
                              child: Text(flagEmoji),
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.cover,
                            child: Text(flagEmoji),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    countryCode,
                    style: AppTextStyles.build(
                      size: countryCodeFontSize ?? 14,
                      weight: countryCodeFontWeight ?? FontWeight.w400,
                      fontFamily: countryCodeFontFamily,
                      color: textColor ?? AppColors.textSecondary,
                      height: 20,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: (textColor ?? AppColors.textSecondary).withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 44,
                    color: (textColor ?? AppColors.textSecondary).withOpacity(0.15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      onChanged: (v) {
        state.didChange(v);
        onChanged?.call(v);
      },
    );
  }
}