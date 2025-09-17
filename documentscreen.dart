import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kmrldb/data/file_upload.dart';
import 'package:kmrldb/presentation/widgets/appbar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../widgets/documenttile.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final user = FirebaseAuth.instance.currentUser; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppbarCustom(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Search bar (not functional yet)
            TextField(
              decoration: InputDecoration(
                hintText: "Search Documents",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            /// Upload Section
            Text(
              "Upload Documents",
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Consumer<FileUploadProvider>(
              builder: (context, provider, _) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        radius: 28,
                        child: const Icon(
                          Icons.upload_file,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Tap the button to upload\ndocuments from your device",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      provider.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                            onPressed: () {
                              provider.pickAndProcessFile(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              "Select files to upload",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      // if (provider.uploadedFileURL != null) ...[
                      //   const SizedBox(height: 10),
                      //   Text(
                      //     "Uploaded: ${provider.uploadedFileURL}",
                      //     textAlign: TextAlign.center,
                      //     style: const TextStyle(
                      //       fontSize: 12,
                      //       color: Colors.black87,
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// All Documents Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Documents",
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.filter_list,
                    size: 18,
                    color: Colors.black,
                  ),
                  label: Text(
                    "Filter",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            /// Documents List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // stream changed to user's subcollection
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .collection('documents')
                    .orderBy('uploadedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No documents uploaded yet."),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final timestamp =
                          (doc['uploadedAt'] as Timestamp).toDate();
                      final timeAgo = timeago.format(timestamp);

                      return DocumentTile(
                        title: doc['filename'],
                        subtitle: "uploaded $timeAgo",
                        color: Colors.blue,
                        icon: Icons.insert_drive_file,
                        url: doc['url'],
                        docId: doc.id,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
