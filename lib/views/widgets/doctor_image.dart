import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DoctorImage extends StatelessWidget {
  final String pathOrUrl;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const DoctorImage({
    super.key,
    required this.pathOrUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  // Dùng ảnh từ thiết kế cũ (network) để chắc chắn hiển thị trên web.
  static const _fallbackUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuALzjGvI7RG-nVb5i62uMGRIwFkn1VaqIEJ8dKwOcBzjlE7JUMqqfVK3jB3wP_6m-OTymNgCeFebtLzZVBBTkhje88MfyZpwpcMWD3qRFtUouC4n04EA6-xdx_OcLODpP-vTLmT1IBVjaZQFDLbB-1t8I1jWtSznl57ZAN2te6dDUhf-uaogBTbThrBf76asK89gxPyYU8WKwT0cfmdpfBJ7jbuW-y3jSfnNCCMja3qm9C3IxCyCDl31BCMqkygDCGhWeX7Pr2pwbA';

  @override
  Widget build(BuildContext context) {
    final p = pathOrUrl.trim();
    final resolved = p.isEmpty ? _fallbackUrl : p;

    Widget child;
    if (resolved.startsWith('data:image/')) {
      final bytes = _tryDecodeDataUri(resolved);
      child = bytes == null
          ? Image.network(_fallbackUrl, fit: fit)
          : Image.memory(
              Uint8List.fromList(bytes),
              fit: fit,
              errorBuilder: (c, e, s) => Image.network(_fallbackUrl, fit: fit),
            );
    } else if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      child = Image.network(
        resolved,
        fit: fit,
        errorBuilder: (context, error, stack) => Image.network(_fallbackUrl, fit: fit),
      );
    } else if (resolved.toLowerCase().endsWith('.svg')) {
      child = _assetSvg(resolved);
    } else {
      child = Image.asset(
        resolved,
        fit: fit,
        errorBuilder: (context, error, stack) => Image.network(_fallbackUrl, fit: fit),
      );
    }

    return ClipRRect(borderRadius: borderRadius, child: child);
  }

  Widget _assetSvg(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      fit: fit,
      placeholderBuilder: (context) => const ColoredBox(color: Color(0xFFE1E3E4)),
    );
  }

  static List<int>? _tryDecodeDataUri(String uri) {
    // format: data:image/png;base64,....
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

