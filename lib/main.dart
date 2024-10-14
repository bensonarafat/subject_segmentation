import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scanning_effect/scanning_effect.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SubjectSegmenter segmenter;
  late InputImage inputImage;
  bool processing = false;
  bool segmented = false;
  File? imageFile;
  Uint8List? bitmap;
  final options = SubjectSegmenterOptions(
    enableForegroundBitmap: true,
    enableForegroundConfidenceMask: false,
    enableMultipleSubjects: SubjectResultOptions(
      enableConfidenceMask: false,
      enableSubjectBitmap: false,
    ),
  );

  @override
  void initState() {
    segmenter = SubjectSegmenter(options: options);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subject Segmentation Google ML KIT',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Subject Segmentation Google ML KIT'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageFile != null && !segmented)
              SizedBox(
                height: MediaQuery.of(context).size.height * .30,
                width: MediaQuery.of(context).size.width * .90,
                child: processing
                    ? ScanningEffect(
                        scanningColor: Colors.red,
                        borderLineColor: Colors.white,
                        delay: const Duration(seconds: 0),
                        duration: const Duration(seconds: 2),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height * .30,
                          width: MediaQuery.of(context).size.width * .75,
                        ),
                      )
                    : Image.file(
                        imageFile!,
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height * .30,
                        width: MediaQuery.of(context).size.width * .75,
                      ),
              ),
            if (segmented && bitmap != null)
              Image.memory(
                bitmap!,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width * .90,
              ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (imageFile == null || segmented == true) {
                    pickImage();
                  } else {
                    processImage();
                  }
                },
                child: Text(
                  imageFile == null || segmented == true
                      ? "Select Image"
                      : "Process Image",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imageFile = File(image.path);
      });
    }
  }

  Future<void> processImage() async {
    setState(() {
      processing = true;
    });
    inputImage = InputImage.fromFile(imageFile!);
    SubjectSegmentationResult result = await segmenter.processImage(inputImage);
    bitmap = result.foregroundBitmap;

    setState(() {
      processing = false;
      segmented = true;
      imageFile = null;
    });
  }

  @override
  void dispose() {
    segmenter.close();
    super.dispose();
  }
}
