// lib/features/mode_select/mode_select_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/widgets/portrait_lock.dart';
import 'widgets/simple_description.dart';
import 'widgets/mode_buttons.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PortraitLock(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                const Expanded(
                  child: SimpleDescription(),
                ),
                SizedBox(
                  height: 320.h,
                  child: const ModeButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
