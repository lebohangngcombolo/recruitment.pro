import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:recruitment_frontend/utils/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final double elevation;
  final Color backgroundColor;

  const CustomAppBar({
    super.key,
    this.title = '',
    this.actions = const [],
    this.showBackButton = true,
    this.onBackPressed,
    this.leading,
    this.elevation = 0,
    this.backgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title,
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      leading: showBackButton
          ? (leading ??
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.primaryRed),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                ))
          : null,
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primaryRed),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final bool showBackButton;

  const GlassAppBar({
    super.key,
    this.title = '',
    this.actions = const [],
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title,
              style: TextStyle(
                color: AppColors.darkText,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.primaryRed),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      backgroundColor: Colors.white.withOpacity(0.1),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primaryRed),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.02),
            ],
          ),
          border: Border(bottom: BorderSide(color: Colors.white30, width: 0.5)),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
