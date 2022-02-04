import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddBookModel extends ChangeNotifier {
  String? title;
  String? author;
  File? imageFile;
  bool isLoading = false;

  final picker = ImagePicker();

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future addBook() async {
    if (title == null || title!.isEmpty) {
      throw '本のタイトルが入力されていません。';
    }

    if (author == null || author!.isEmpty) {
      throw '著者が入力されていません。';
    }

    final doc = FirebaseFirestore.instance.collection('books').doc();

    String? imgURL;

    if (imageFile != null) {
      // storageにアップロード
      final task = await FirebaseStorage.instance
          .ref('books/${doc.id}')
          .putFile(imageFile!);
      imgURL = await task.ref.getDownloadURL();
    }

    // firestoreに追加
    await FirebaseFirestore.instance.collection('books').add({
      'title': title,
      'author': author,
      'imgURL': imgURL,
    });
  }

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      notifyListeners();
    }
  }
}