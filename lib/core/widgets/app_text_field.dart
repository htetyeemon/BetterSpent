import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class AppTextField extends StatelessWidget {
  final Widget? prefix;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final TextStyle? style;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.prefix,
    required this.controller,
    required this.keyboardType,
    this.inputFormatters,
    required this.hintText,
    this.validator,
    this.style,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        children: [
          ?prefix,
          Expanded(
            child: TextFormField(
              controller: controller,
              autofocus: autofocus,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              style: style,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                  vertical: AppConstants.spacingMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
