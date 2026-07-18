import 'package:flutter/material.dart';
import 'app_colors.dart';

export 'app_animations.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Color fillColor;

  const AppSearchBar({
    Key? key,
    this.controller,
    required this.hintText,
    this.onChanged,
    this.fillColor = Colors.white,
  }) : super(key: key);

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _internalController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _internalController.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color       : widget.fillColor,
        borderRadius: BorderRadius.circular(8),
        border      : Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _internalController,
              onChanged: widget.onChanged,
              style     : const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText      : widget.hintText,
                hintStyle     : TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border        : InputBorder.none,
                isDense       : true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_internalController.text.isNotEmpty)
            GestureDetector(
              onTap : () {
                _internalController.clear();
                if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
              },
              child : Icon(Icons.close_rounded, size: 18, color: Colors.grey.shade400),
            ),
        ],
      ),
    );
  }
}

class AppActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const AppActionButton({
    Key? key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.navy, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class AppStatusBadge extends StatelessWidget {
  final String status;

  const AppStatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final style = AppStatusColors.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color       : style.bg,
        borderRadius: BorderRadius.circular(20),
        border      : Border.all(
            color: style.border.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color        : style.text,
          fontSize     : 9,
          fontWeight   : FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// State kosong standar untuk list / view yang belum ada datanya.
class AppEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AppEmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.receipt_long_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color       : AppColors.chipBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 36, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize  : 15,
              fontWeight: FontWeight.w500,
              color     : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
