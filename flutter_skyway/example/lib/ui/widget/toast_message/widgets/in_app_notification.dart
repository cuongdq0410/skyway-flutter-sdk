import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InAppNotificationWidget extends StatelessWidget {
  final String text;
  final Color? colorBackground;
  final TextStyle? textStyle;
  final Widget? icon;
  final Color? colorIcon;

  const InAppNotificationWidget({
    Key? key,
    required this.text,
    this.textStyle,
    this.colorBackground,
    this.icon,
    this.colorIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6.0.sp),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              blurRadius: 5,
              color: Color(0xffD1D3D4),
              offset: Offset(0, 0),
            )
          ],
          borderRadius: BorderRadius.circular(8.r),
          color: colorBackground ?? Theme.of(context).colorScheme.background,
        ),
        padding: EdgeInsets.all(8.sp),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: icon ??
                  Icon(
                    CupertinoIcons.checkmark_circle,
                    color: colorIcon ?? Colors.black,
                    size: 24.sp,
                  ),
            ),
            Expanded(
              child: Text(
                text,
                style: textStyle ?? Theme.of(context).textTheme.bodyLarge,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
