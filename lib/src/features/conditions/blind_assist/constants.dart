// lib/constants.dart

import 'package:camera/camera.dart';

// Global variable for cameras, initialized in main.dart
List<CameraDescription> cameras = [];

// Gemma Model Constants
const String GEMMA_MODEL_URL =
    'https://huggingface.co/google/gemma-3n-E4B-it-litert-preview/resolve/main/gemma.task';
const String GEMMA_MODEL_FILENAME = 'gemma.task';