// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;

  const FullScreenImageViewer({Key? key, this.imageUrl, this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          elevation: 0.0,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Container(
          color: Colors.black,
          child: PhotoView(
            imageProvider: imageFile == null ? NetworkImage(imageUrl!) : Image.file(imageFile!).image,
          ),
        ));
  }
}