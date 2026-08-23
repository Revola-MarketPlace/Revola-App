import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';

class AppImageView extends StatelessWidget {
  final String? imageUrl;
  final String? materialName;
  final String? categoryName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImageView({
    super.key,
    required this.imageUrl,
    this.materialName,
    this.categoryName,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  /// Get intelligent fallback image based on material name and category
  static String getFallbackForMaterial({String? name, String? category}) {
    final combined = '${name ?? ''} ${category ?? ''}'.toLowerCase();

    if (combined.contains('wood') ||
        combined.contains('timber') ||
        combined.contains('pallet') ||
        combined.contains('plank') ||
        combined.contains('lumber') ||
        combined.contains('eucalyptus')) {
      return 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600&auto=format&fit=crop&q=80';
    }
    if (combined.contains('metal') ||
        combined.contains('steel') ||
        combined.contains('iron') ||
        combined.contains('rebar') ||
        combined.contains('sheet') ||
        combined.contains('pipe') ||
        combined.contains('scrap')) {
      return 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=600&auto=format&fit=crop&q=80';
    }
    if (combined.contains('electric') ||
        combined.contains('wire') ||
        combined.contains('cable') ||
        combined.contains('circuit') ||
        combined.contains('motor') ||
        combined.contains('copper') ||
        combined.contains('panel')) {
      return 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&auto=format&fit=crop&q=80';
    }
    if (combined.contains('plastic') ||
        combined.contains('barrel') ||
        combined.contains('tank') ||
        combined.contains('drum') ||
        combined.contains('crate') ||
        combined.contains('hdpe') ||
        combined.contains('pvc')) {
      return 'https://images.unsplash.com/photo-1584473457406-6240486418e9?w=600&auto=format&fit=crop&q=80';
    }
    if (combined.contains('furnit') ||
        combined.contains('desk') ||
        combined.contains('chair') ||
        combined.contains('table') ||
        combined.contains('door') ||
        combined.contains('frame')) {
      return 'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=600&auto=format&fit=crop&q=80';
    }
    if (combined.contains('brick') ||
        combined.contains('stone') ||
        combined.contains('cement') ||
        combined.contains('concrete') ||
        combined.contains('sand') ||
        combined.contains('aggregate') ||
        combined.contains('block')) {
      return 'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1541888946425-d0fbb18086f6?w=600&auto=format&fit=crop&q=80';
  }

  @override
  Widget build(BuildContext context) {
    final String raw = (imageUrl ?? '').trim();
    Widget imageWidget;

    if (raw.isEmpty) {
      imageWidget = _buildFallbackImage();
    } else if (raw.startsWith('data:image')) {
      // 1. Handle Base64 Data URI: data:image/jpeg;base64,.....
      imageWidget = _buildBase64Image(raw);
    } else if (raw.startsWith('http://') || raw.startsWith('https://')) {
      // 2. Handle HTTP/HTTPS Network URL
      imageWidget = _buildNetworkImage(raw);
    } else if (raw.startsWith('/uploads/') || raw.startsWith('uploads/')) {
      // 3. Handle Relative Upload Path from Server
      final serverHost = AppConfig.baseUrl.replaceAll('/api/v1', '');
      final fullUrl = raw.startsWith('/')
          ? '$serverHost$raw'
          : '$serverHost/$raw';
      imageWidget = _buildNetworkImage(fullUrl);
    } else if (raw.startsWith('/') ||
        raw.contains(':\\') ||
        raw.startsWith('file://')) {
      // 4. Handle Local File Path
      imageWidget = _buildLocalFileImage(raw);
    } else {
      // Fallback
      imageWidget = _buildFallbackImage();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(width: width, height: height, child: imageWidget),
      );
    }

    return SizedBox(width: width, height: height, child: imageWidget);
  }

  Widget _buildBase64Image(String dataUri) {
    try {
      final base64String = dataUri.contains(',')
          ? dataUri.split(',').last
          : dataUri;
      final Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    } catch (_) {
      return _buildFallbackImage();
    }
  }

  Widget _buildLocalFileImage(String path) {
    try {
      final cleanPath = path.replaceFirst('file://', '');
      final file = File(cleanPath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildFallbackImage(),
        );
      }
    } catch (_) {}
    return _buildFallbackImage();
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) =>
          placeholder ??
          Container(
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
      errorWidget: (_, __, ___) => _buildFallbackImage(),
    );
  }

  Widget _buildFallbackImage() {
    final fallbackUrl = getFallbackForMaterial(
      name: materialName,
      category: categoryName,
    );
    return CachedNetworkImage(
      imageUrl: fallbackUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) =>
          placeholder ??
          Container(
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
      errorWidget: (_, __, ___) =>
          errorWidget ??
          Container(
            color: const Color(0xFFF1F5F9),
            child: const Center(
              child: Icon(
                Icons.inventory_2_outlined,
                color: AppTheme.primaryBlue,
                size: 36,
              ),
            ),
          ),
    );
  }
}
