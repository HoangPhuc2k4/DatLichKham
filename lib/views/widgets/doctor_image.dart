import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorImage extends StatelessWidget {
  final String pathOrUrl;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final double? width;
  final double? height;

  const DoctorImage({
    super.key,
    required this.pathOrUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
    this.width,
    this.height,
  });

  // Ảnh dự phòng khi link lỗi hoặc trống (Placeholder cao cấp)
  static const _fallbackUrl = 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=500&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    final p = pathOrUrl.trim();
    final resolved = p.isEmpty ? _fallbackUrl : p;

    Widget imageChild;

    if (resolved.startsWith('data:image/')) {
      // Xử lý Base64
      final bytes = _tryDecodeDataUri(resolved);
      imageChild = bytes == null
          ? _networkImage(_fallbackUrl)
          : Image.memory(
        Uint8List.fromList(bytes),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _networkImage(_fallbackUrl),
      );
    } else if (resolved.startsWith('http')) {
      // Xử lý Network Image
      imageChild = _networkImage(resolved);
    } else if (resolved.toLowerCase().endsWith('.svg')) {
      // Xử lý SVG
      imageChild = SvgPicture.asset(
        resolved,
        fit: fit,
        width: width,
        height: height,
        placeholderBuilder: (_) => _loadingPlaceholder(),
      );
    } else {
      // Xử lý Assets
      imageChild = Image.asset(
        resolved,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _networkImage(_fallbackUrl),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: imageChild,
      ),
    );
  }

  // Widget hiển thị ảnh từ mạng với hiệu ứng loading chuyên nghiệp
  Widget _networkImage(String url) {
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _loadingPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        // Nếu ảnh chính lỗi, thử hiển thị fallback, nếu fallback vẫn lỗi thì hiện màu xám
        return url == _fallbackUrl
            ? _loadingPlaceholder()
            : _networkImage(_fallbackUrl);
      },
    );
  }

  // Widget hiển thị trạng thái đang tải hoặc lỗi
  Widget _loadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate 100
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.person_outline_rounded,
          color: const Color(0xFF94A3B8), // Slate 400
          size: width != null ? width! * 0.4 : 32,
        ),
      ),
    );
  }

  static List<int>? _tryDecodeDataUri(String uri) {
    try {
      final idx = uri.indexOf('base64,');
      if (idx < 0) return null;
      final b64 = uri.substring(idx + 7);
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }
}