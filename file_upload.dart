import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart'; // for DOCX

class FileUploadProvider with ChangeNotifier {
  bool isLoading = false;
  String? uploadedFileURL;
  String? extractedText; // keep text in memory (not Firestore)

  /// Pick a file, extract text, and store file info in Firestore
  Future<void> pickAndProcessFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'], // allow all three
      );

      if (result == null) return;

      isLoading = true;
      notifyListeners();

      final fileName = result.files.single.name;
      final filePath = result.files.single.path;
      final fileBytes = result.files.single.bytes;

      uploadedFileURL = fileName;

      // 🔹 Extract text
      String text = "";
      if (fileName.toLowerCase().endsWith(".pdf")) {
        try {
          final bytes = fileBytes ?? File(filePath!).readAsBytesSync();
          final document = PdfDocument(inputBytes: bytes);

          for (int i = 0; i < document.pages.count; i++) {
            text += PdfTextExtractor(document)
                .extractText(startPageIndex: i, endPageIndex: i);
          }

          document.dispose();
        } catch (e) {
          text = "Failed to extract text from PDF: $e";
        }
      } else if (fileName.toLowerCase().endsWith(".docx")) {
        try {
          // Using docx_to_text package
          final docxBytes = fileBytes ?? File(filePath!).readAsBytesSync();
          text = await docxToText(docxBytes);
        } catch (e) {
          text = "Failed to extract text from DOCX: $e";
        }
      } 

      extractedText = text;

      // 🔹 Store file info in Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('documents')
            .add({
          "filename": fileName,
          "url": uploadedFileURL,
          "uploadedAt": FieldValue.serverTimestamp(),
          "uploadedBy": user.uid,
        });
      }

      // 🔹 Navigate to extracted text preview page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExtractedTextPage(text: extractedText ?? ""),
        ),
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("Error during file processing: $e");
    }
  }
}

/// Page to preview extracted text
class ExtractedTextPage extends StatelessWidget {
  final String text;
  const ExtractedTextPage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Extracted Text")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            text.isNotEmpty ? text : "No text extracted",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
