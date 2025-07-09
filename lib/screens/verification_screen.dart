import 'package:camera/camera.dart';

import 'package:celebrating/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../utils/route.dart';
import '../widgets/app_buttons.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  XFile? _frontImage;
  XFile? _backImage;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _takingFront = true; // true: taking front, false: taking back

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final image = await _cameraController!.takePicture();
      setState(() {
        if (_takingFront) {
          _frontImage = image;
          _takingFront = false;
        } else {
          _backImage = image;
        }
      });
    }
  }

  Future<void> _retakePhoto() async {
    setState(() {
      if (!_takingFront) {
        _backImage = null;
        _takingFront = false;
      } else {
        _frontImage = null;
        _backImage = null;
        _takingFront = true;
      }
      _isCameraInitialized = false;
    });
    await _cameraController?.dispose();
    _cameraController = null;
    await _initCamera();
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 44),
            Text(
              AppLocalizations.of(context)!.identityVerification,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.identityVerificationDesc,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Only show the instruction if not both photos are taken
            if (!(_frontImage != null && _backImage != null))
              Text(
                _takingFront
                    ? AppLocalizations.of(context)!.takeFrontPhotoInstruction
                    : AppLocalizations.of(context)!.takeBackPhotoInstruction,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            if (!(_frontImage != null && _backImage != null))
              const SizedBox(height: 12),
            _frontImage == null || (_frontImage != null && !_takingFront)
                ? _isCameraInitialized && _cameraController != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 220,
                          height: 300,
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    : Container(
                        width: 220,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!, width: 1.2),
                        ),
                        child: const Center(
                          child: Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                        ),
                      )
                : const SizedBox.shrink(),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: Text(_frontImage == null
                  ? AppLocalizations.of(context)!.takeFrontPhoto
                  : _backImage == null
                      ? AppLocalizations.of(context)!.takeBackPhoto
                      : AppLocalizations.of(context)!.retakePhoto),
              onPressed: _backImage == null ? _takePicture : _retakePhoto,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_frontImage != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        Text(AppLocalizations.of(context)!.frontOfId, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_frontImage!.path),
                            width: 90,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_backImage != null)
                  Column(
                    children: [
                      Text(AppLocalizations.of(context)!.backOfId, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_backImage!.path),
                          width: 90,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Spacer(),
            AppButton(
              text: AppLocalizations.of(context)!.submitForVerification,
              isEnabled: (_frontImage != null && _backImage != null),
              onPressed: () {
                // TODO: Implement upload/submit logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.verificationSubmitted)),
                );
                Navigator.pop(context, [_frontImage, _backImage]);
                Navigator.pushNamed(context, celebrityProfileCreate);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}



