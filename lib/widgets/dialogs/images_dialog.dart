import 'dart:ui';
import 'package:custom_cached_image/custom_cached_image_with_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';


class ImagesDialog extends StatefulWidget {
  final List<String> imageUrls;

  const ImagesDialog({super.key, required this.imageUrls});

  @override
  State<ImagesDialog> createState() => _ImagesDialogState();
}

class _ImagesDialogState extends State<ImagesDialog> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _goToPrevious() {
    if (_currentPage > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  void _goToNext() {
    if (_currentPage < widget.imageUrls.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
    }
  }

  Widget _blurredBackground({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.sp),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15), // light grey tint
            borderRadius: BorderRadius.circular(50.sp),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox(); // Return empty if no images
    }

    return Stack(
      children: [
        // Fullscreen background image carousel
        SizedBox(
          height: 510.h,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return CustomCachedImage(
                fit: BoxFit.cover,
                imageUrl: widget.imageUrls[index],
                height: 450.h,
                width: double.infinity,
                borderRadius: 22.sp,
                isProfile: false,
              );
            },
          ),
        ),

        // Top bar with close button
        Positioned(
          top: 10.h,
          right: 10.w,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: _blurredBackground(
              child: Padding(
                padding: EdgeInsets.all(8.sp),
                child: const Icon(Icons.close, color: Colors.black, size: 24),
              ),
            ),
          ),
        ),

        // Previous Arrow
        Positioned(
          left: 20.w,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: _goToPrevious,
              child: _blurredBackground(
                child: SizedBox(
                  height: 40.sp,
                  width: 40.sp,
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.black, size: 18),
                ),
              ),
            ),
          ),
        ),

        // Next Arrow
        Positioned(
          right: 20.w,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: _goToNext,
              child: _blurredBackground(
                child: SizedBox(
                  height: 40.sp,
                  width: 40.sp,
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Colors.black, size: 18),
                ),
              ),
            ),
          ),
        ),

        // Page Indicator
        Positioned(
          bottom: 40.h,
          left: 0,
          right: 0,
          child: Center(
            child: _blurredBackground(
              child: Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: widget.imageUrls.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: Colors.black,
                    dotColor: Colors.white.withOpacity(0.5),
                    spacing: 8,
                    expansionFactor: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
