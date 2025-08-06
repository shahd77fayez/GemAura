// lib/src/shared/services/authenticated_download_service.dart

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthenticatedDownloadService {

  /// Downloads a file from a URL that requires authentication (like Hugging Face)
  /// Returns a Stream<double> with download progress (0.0 to 1.0)
  static Stream<double> downloadWithAuth({
    required String url,
    required String destinationPath,
    String? authToken,
    Map<String, String>? headers,
  }) {
    final controller = StreamController<double>();

    _performDownload(
      url: url,
      destinationPath: destinationPath,
      authToken: authToken,
      headers: headers,
      progressController: controller,
    );

    return controller.stream;
  }

  static Future<void> _performDownload({
    required String url,
    required String destinationPath,
    String? authToken,
    Map<String, String>? headers,
    required StreamController<double> progressController,
  }) async {
    try {
      // Prepare headers
      final requestHeaders = <String, String>{
        'User-Agent': 'Flutter-App/1.0',
        ...?headers,
      };

      // Add authentication header if token is provided
      if (authToken != null && authToken.isNotEmpty) {
        requestHeaders['Authorization'] = 'Bearer $authToken';
      }

      // Make the initial request to get file size
      final response = await http.head(Uri.parse(url), headers: requestHeaders);

      if (response.statusCode == 401) {
        progressController.addError('Authentication failed. Please check your Hugging Face token and make sure you have accepted the model license.');
        return;
      }

      if (response.statusCode == 404) {
        progressController.addError('Model not found. Please check the URL.');
        return;
      }

      if (response.statusCode != 200) {
        progressController.addError('Failed to access model. Status: ${response.statusCode}');
        return;
      }

      // Get content length for progress tracking
      final contentLength = int.tryParse(response.headers['content-length'] ?? '0') ?? 0;

      if (contentLength == 0) {
        progressController.addError('Unable to determine file size');
        return;
      }

      // Start the actual download
      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(requestHeaders);

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        progressController.addError('Download failed with status: ${streamedResponse.statusCode}');
        return;
      }

      // Create destination file
      final file = File(destinationPath);
      await file.create(recursive: true);
      final sink = file.openWrite();

      int downloadedBytes = 0;

      // Listen to the stream and write to file
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        // Calculate and emit progress
        final progress = downloadedBytes / contentLength;
        progressController.add(progress.clamp(0.0, 1.0));
      }

      await sink.close();
      progressController.close();

    } catch (e) {
      progressController.addError('Download error: $e');
    }
  }

  /// Simple download without authentication for testing
  static Stream<double> downloadSimple({
    required String url,
    required String destinationPath,
  }) {
    return downloadWithAuth(
      url: url,
      destinationPath: destinationPath,
    );
  }
}