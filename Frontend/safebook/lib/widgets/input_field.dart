import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    required this.title,
    required this.hintText,
    required this.prefixIcon,
    this.furtherAction = "",
    this.furtherActionRequired = false,
    this.action = _defaultAction,
    required this.validator,
    required this.controller,
    this.maxLines = 1,
    this.maxLength,
    this.initialValue = "",
    this.isEditing = false,
    this.isPassword = false,
    this.obscureText = false,
    this.iconOnPressed = _defaultAction,
  });

  final String title;
  final String hintText;
  final IconData? prefixIcon;
  final String furtherAction;
  final bool furtherActionRequired;
  final VoidCallback action;
  final String? Function(String?) validator;
  final TextEditingController controller;
  final int? maxLines;
  final int? maxLength;
  final String initialValue;
  final bool isEditing;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback iconOnPressed;

  static void _defaultAction() {}

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF172033);
  static const Color textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveMaxLines = widget.isPassword ? 1 : widget.maxLines;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and optional action
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (widget.furtherActionRequired)
                TextButton(
                  onPressed: widget.action,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: primaryBlue,
                  ),
                  child: Text(
                    widget.furtherAction,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 9),

          // Input field
          TextFormField(
            controller: widget.controller,
            maxLines: effectiveMaxLines,
            maxLength: widget.maxLength,
            obscureText: widget.isPassword && widget.obscureText,
            validator: widget.validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(widget.prefixIcon, size: 20, color: textMuted),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      tooltip: widget.obscureText
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: widget.iconOnPressed,
                      icon: Icon(
                        widget.obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: textMuted,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: effectiveMaxLines != null && effectiveMaxLines > 1
                    ? 16
                    : 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: primaryBlue, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(color: Color(0xFFDC2626)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(13),
                borderSide: const BorderSide(
                  color: Color(0xFFDC2626),
                  width: 1.5,
                ),
              ),
              errorStyle: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 12,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
              counterStyle: const TextStyle(color: textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
