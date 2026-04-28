import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorImage extends StatelessWidget {
  final String pathOrUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;

  const DoctorImage({
    super.key,
    required this.pathOrUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.width,
    this.height,
  });

  // Sử dụng một ảnh Placeholder chuyên nghiệp hơn từ Unsplash nếu link lỗi
  static const _fallbackUrl =
      'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=1000&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    final p = pathOrUrl.trim();
    final resolved = p.isEmpty ? _fallbackUrl : p;

    // Xác định kiểu Border: Nếu không truyền thì mặc định bo tròn nhẹ theo phong cách Bento
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F4), // Màu nền nhẹ khi đang tải
        borderRadius: effectiveRadius,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: _buildImage(resolved),
      ),
    );
  }

  Widget _buildImage(String source) {
    // 1. Xử lý Base64 Data URI
    if (source.startsWith('data:image/')) {
      final bytes = _tryDecodeDataUri(source);
      if (bytes == null) return _networkErrorWidget();
      return Image.memory(
        Uint8List.fromList(bytes),
        fit: fit,
        errorBuilder: (c, e, s) => _networkErrorWidget(),
      );
    }

    // 2. Xử lý Network URL (HTTP/HTTPS)
    if (source.startsWith('http://') || source.startsWith('https://')) {
      return Image.network(
        source,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _loadingPlaceholder();
        },
        errorBuilder: (context, error, stack) => _networkErrorWidget(),
      );
    }

    // 3. Xử lý SVG Assets
    if (source.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        source,
        fit: fit,
        placeholderBuilder: (context) => _loadingPlaceholder(),
      );
    }

    // 4. Xử lý Local Assets
    return Image.asset(
      source,
      fit: fit,
      errorBuilder: (context, error, stack) => _networkErrorWidget(),
    );
  }

  // Widget hiển thị khi ảnh đang tải (Placeholder shimmer-like)
  Widget _loadingPlaceholder() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF2EC4B6).withOpacity(0.3)),
      ),
    );
  }

  // Widget hiển thị khi ảnh lỗi
  Widget _networkErrorWidget() {
    return Image.network(
      _fallbackUrl,
      fit: fit,
    );
  }

  static List<int>? _tryDecodeDataUri(String uri) {
    final idx = uri.indexOf('base64,');
    if (idx < 0) return null;
    final b64 = uri.substring(idx + 'base64,'.length);
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }
}