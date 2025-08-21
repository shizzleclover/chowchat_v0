import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewer({super.key, required this.imageUrls, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          onVerticalDragEnd: (_) => Navigator.pop(context),
          child: PageView.builder(
            controller: PageController(initialPage: initialIndex.clamp(0, imageUrls.length - 1)),
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final url = imageUrls[index];
              return PhotoView(
                imageProvider: NetworkImage(url),
                minScale: PhotoViewComputedScale.contained,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              );
            },
          ),
        ),
      ),
    );
  }
}

