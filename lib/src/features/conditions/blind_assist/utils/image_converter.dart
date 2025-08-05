// lib/utils/image_converter.dart

import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

// This function acts as a dispatcher based on the image format.
Future<Uint8List?> convertCameraImageToUint8List(CameraImage cameraImage) async {
  print("DEBUG: Camera Image Format Group: ${cameraImage.format.group}");

  try {
    img.Image? image;
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      image = _convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      image = img.Image.fromBytes(
        width: cameraImage.width,
        height: cameraImage.height,
        bytes: cameraImage.planes[0].bytes.buffer,
        format: img.Format.uint8,
        numChannels: 4, // BGRA
      );
    } else {
      print("WARNING: Unsupported Camera Image Format Group: ${cameraImage.format.group}");
      return null;
    }

    if (image != null) {
      // Resize for performance and model consistency
      final resizedImage = img.copyResize(image, width: 256, height: 256);
      return Uint8List.fromList(img.encodeJpg(resizedImage));
    }
  } catch (e) {
    print("Error during image conversion: $e");
  }
  return null;
}

// The detailed YUV420 conversion logic.
img.Image? _convertYUV420ToImage(CameraImage cameraImage) {
  final int width = cameraImage.width;
  final int height = cameraImage.height;

  print("YUV420 Conversion: Width=$width, Height=$height");

  if (cameraImage.planes.length < 3) {
    print("ERROR: YUV420 Conversion: Not enough planes (${cameraImage.planes.length})");
    return null;
  }

  final Uint8List yPlane = cameraImage.planes[0].bytes;
  final Uint8List uPlane = cameraImage.planes[1].bytes;
  final Uint8List vPlane = cameraImage.planes[2].bytes;

  final int yRowStride = cameraImage.planes[0].bytesPerRow;
  final int uvRowStride = cameraImage.planes[1].bytesPerRow;
  final int uvPixelStride = cameraImage.planes[1].bytesPerPixel ?? 2;

  print("YUV420 Conversion: yRowStride=$yRowStride, uvRowStride=$uvRowStride, uvPixelStride=$uvPixelStride");
  print("YUV420 Plane Lengths: Y=${yPlane.length}, U=${uPlane.length}, V=${vPlane.length}");

  final image = img.Image(width: width, height: height);

  for (int h = 0; h < height; h++) {
    for (int w = 0; w < width; w++) {
      final int yIndex = h * yRowStride + w;
      final int uvIndex = (h ~/ 2) * uvRowStride + (w ~/ 2) * uvPixelStride;

      if (yIndex >= yPlane.length || uvIndex >= uPlane.length || uvIndex >= vPlane.length) {
        continue;
      }

      final int Y = yPlane[yIndex];
      final int U = uPlane[uvIndex];
      final int V = vPlane[uvIndex];

      final int C = Y - 16;
      final int D = U - 128;
      final int E = V - 128;

      int R = (298 * C + 409 * E + 128) >> 8;
      int G = (298 * C - 100 * D - 208 * E + 128) >> 8;
      int B = (298 * C + 516 * D + 128) >> 8;

      image.setPixelRgb(w, h, R.clamp(0, 255), G.clamp(0, 255), B.clamp(0, 255));
    }
  }
  return image;
}