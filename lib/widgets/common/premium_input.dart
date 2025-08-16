import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_color.dart';

enum PremiumInputVariant {
  default_,
  filled,
  outline,
  underlined,
}

class PremiumInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;
  final PremiumInputVariant variant;
  final bool showCounter;
  final bool autofocus;

  const PremiumInput({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.variant = PremiumInputVariant.default_,
    this.showCounter = false,
    this.autofocus = false,
  });

  const PremiumInput.filled({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.showCounter = false,
    this.autofocus = false,
  }) : variant = PremiumInputVariant.filled;

  const PremiumInput.outline({
    super.key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.showCounter = false,
    this.autofocus = false,
  }) : variant = PremiumInputVariant.outline;

  @override
  State<PremiumInput> createState() => _PremiumInputState();
}

class _PremiumInputState extends State<PremiumInput> {
  bool _obscureText = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          _buildLabel(),
          const SizedBox(height: 8),
        ],
        _buildInputField(),
        if (widget.helperText != null || widget.errorText != null || widget.showCounter) ...[
          const SizedBox(height: 6),
          _buildHelperRow(),
        ],
      ],
    );
  }

  Widget _buildLabel() {
    return Text(
      widget.label!,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: widget.errorText != null
            ? AppColors.destructive
            : _isFocused
                ? AppColors.primary
                : AppColors.foreground,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInputField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: _getInputDecoration(),
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        onTap: widget.onTap,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: _obscureText,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        maxLines: _obscureText ? 1 : widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: widget.enabled 
              ? AppColors.foreground
              : AppColors.mutedForeground,
        ),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.mutedForeground.withOpacity(0.6),
          ),
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          prefixText: widget.prefixText,
          suffixText: widget.suffixText,
          contentPadding: widget.contentPadding ?? 
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: false,
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          counterText: widget.showCounter ? null : '',
          errorText: null, // Handle error display manually
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.mutedForeground,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  Widget _buildHelperRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: widget.errorText != null
              ? Text(
                  widget.errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.destructive,
                  ),
                )
              : widget.helperText != null
                  ? Text(
                      widget.helperText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    )
                  : const SizedBox.shrink(),
        ),
        if (widget.showCounter && widget.maxLength != null) ...[
          const SizedBox(width: 8),
          Text(
            '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ],
    );
  }

  BoxDecoration _getInputDecoration() {
    Color borderColor;
    Color backgroundColor;
    
    if (widget.errorText != null) {
      borderColor = AppColors.destructive;
    } else if (_isFocused) {
      borderColor = AppColors.ring;
    } else {
      borderColor = AppColors.border;
    }

    switch (widget.variant) {
      case PremiumInputVariant.default_:
      case PremiumInputVariant.filled:
        backgroundColor = widget.enabled 
            ? AppColors.muted
            : AppColors.muted.withOpacity(0.5);
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppColors.radius),
          border: Border.all(
            color: borderColor.withOpacity(_isFocused ? 1.0 : 0.3),
            width: _isFocused ? 2 : 1,
          ),
        );

      case PremiumInputVariant.outline:
        backgroundColor = Colors.transparent;
        return BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppColors.radius),
          border: Border.all(
            color: borderColor,
            width: _isFocused ? 2 : 1.5,
          ),
        );

      case PremiumInputVariant.underlined:
        return BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: borderColor,
              width: _isFocused ? 2 : 1,
            ),
          ),
        );
    }
  }
}

class PremiumSearchInput extends StatelessWidget {
  final String? placeholder;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final bool enabled;
  final Widget? leading;

  const PremiumSearchInput({
    super.key,
    this.placeholder,
    this.onChanged,
    this.controller,
    this.onClear,
    this.enabled = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumInput.filled(
      placeholder: placeholder ?? 'Search...',
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      prefixIcon: leading ?? Icon(
        Icons.search,
        color: AppColors.mutedForeground,
        size: 20,
      ),
      suffixIcon: (controller?.text.isNotEmpty == true && onClear != null)
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: AppColors.mutedForeground,
                size: 18,
              ),
              onPressed: onClear,
            )
          : null,
      textInputAction: TextInputAction.search,
    );
  }
}

class PremiumOTPInput extends StatefulWidget {
  final int length;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final bool enabled;

  const PremiumOTPInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<PremiumOTPInput> createState() => _PremiumOTPInputState();
}

class _PremiumOTPInputState extends State<PremiumOTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 48,
          child: PremiumInput.outline(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.number,
            maxLength: 1,
            enabled: widget.enabled,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < widget.length - 1) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  _focusNodes[index].unfocus();
                }
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              
              _updateValue();
            },
          ),
        ),
      ),
    );
  }

  void _updateValue() {
    final value = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(value);
    
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }
}