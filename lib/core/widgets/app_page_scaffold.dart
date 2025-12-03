// lib/core/widgets/app_page_scaffold.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPageScaffold extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
  final Widget? bottom;

  final bool isCentered;

  const AppPageScaffold({
    super.key,
    this.header,
    required this.children,
    this.bottom,
    this.isCentered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: isCentered 
              ? _buildCenteredLayout(context) 
              : _buildStandardLayout(context),
        ),
      ),
    );
  }

  Widget _buildStandardLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            if (header != null)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 0),
                child: header!,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w,
                    20.h + MediaQuery.of(context).viewInsets.bottom),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
            if (bottom != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  12.h,
                  24.w,
                  12.h + MediaQuery.of(context).padding.bottom,
                ),
                color: Colors.white,
                child: bottom!,
              ),
          ],
        );
      },
    );
  }

  Widget _buildCenteredLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    if (header != null) header!,
                    ...children,
                    if (bottom != null) ...[
                      SizedBox(height: 32.h),
                      bottom!,
                    ],
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
