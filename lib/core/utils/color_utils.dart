import 'package:flutter/painting.dart';
import 'package:palette_generator/palette_generator.dart';

abstract final class ColorUtils {
  static Future<Color> dominantColorFromUrl(String imageUrl) async {
    final generator = await PaletteGenerator.fromImageProvider(
      NetworkImage(imageUrl),
      maximumColorCount: 5,
    );
    return generator.dominantColor?.color ?? const Color(0xFF2E7D32);
  }

  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).padLeft(6, '0').toUpperCase()}';
  }

  static Color hexToColor(String hex) {
    final buffer = StringBuffer();
    buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
