import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:kmrldb/data/cloudinary_service.dart';
import 'package:kmrldb/presentation/widgets/appbar.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? _address;
double? _lat;
double? _lng;

  File? _image;
  String? _uploadedUrl;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? selectedCategory;
  bool _isLoadingLocation = false;
  bool _isUploadingImage = false;

  Future<void> _takePhoto() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage == null) return;

      setState(() {
        _image = File(pickedImage.path);
        _uploadedUrl = null;
      });

      setState(() => _isUploadingImage = true);
      String? imageUrl = await CloudinaryService.uploadImage(_image!);
      setState(() => _isUploadingImage = false);

      if (imageUrl != null) {
        setState(() {
          _uploadedUrl = imageUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to upload image"),
          backgroundColor: Colors.red,
        ));
      }

      // Fetch location only after taking photo
      await _getCurrentLocation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Camera error: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _getCurrentLocation() async {
  setState(() => _isLoadingLocation = true);
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      setState(() => _isLoadingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    // Get exact GPS location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    // Convert to address
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    String address = "";
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      address =
          "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    }

    setState(() {
      _lat = position.latitude;
      _lng = position.longitude;
      _address = address;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Failed to get location: $e"),
      backgroundColor: Colors.red,
    ));
  } finally {
    setState(() => _isLoadingLocation = false);
  }
}



  void submitReport() {
    if (selectedCategory == null ||
        _titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields, capture photo, and add location"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Report submitted successfully!"),
      backgroundColor: Colors.green,
    ));
  }

  Widget _buildCategoryButton(String title, IconData icon) {
  final isSelected = selectedCategory == title;
  return GestureDetector(
    onTap: () => setState(() => selectedCategory = title),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Selection.

            const Text("Select a Category",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCategoryButton("Safety", Icons.health_and_safety),
                _buildCategoryButton("Maintenance", Icons.build),
                _buildCategoryButton("Passenger", Icons.people),
                _buildCategoryButton("Technical", Icons.settings),
                _buildCategoryButton("Security", Icons.security),
                _buildCategoryButton("Others", Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Report Title",
                hintText: "Eg: Broken seat inside coach",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            
            //select role
            // Select Role Dropdown
DropdownButtonFormField<String>(
  dropdownColor: Colors.white,
  isExpanded: true,
  decoration: InputDecoration(
    labelText: "Select Role",
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  items: const [
    DropdownMenuItem(value: "Operations Department", child: Text("Operations Department")),
    DropdownMenuItem(value: "Engineering & Maintenance", child: Text("Engineering & Maintenance")),
    DropdownMenuItem(value: "Rolling Stock (Trains)", child: Text("Rolling Stock (Trains)")),
    DropdownMenuItem(value: "Signaling & Electrical (S&T / E&M)", child: Text("Signaling & Electrical (S&T / E&M)")),
    DropdownMenuItem(value: "Procurement & Stores (Materials Management)", child: Text("Procurement & Stores (Materials Management)")),
    DropdownMenuItem(value: "Finance Department", child: Text("Finance Department")),
    DropdownMenuItem(value: "Human Resources (HR)", child: Text("Human Resources (HR)")),
    DropdownMenuItem(value: "Legal & Compliance", child: Text("Legal & Compliance")),
    DropdownMenuItem(value: "Safety Department", child: Text("Safety Department")),
    DropdownMenuItem(value: "Environmental & CSR", child: Text("Environmental & CSR")),
    DropdownMenuItem(value: "Executive / Board of Directors", child: Text("Executive / Board of Directors")),
  ],
  onChanged: (value) {
    // Save selected department
  },
),
const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Description",
                hintText:
                    "Eg: One of the passenger seats in coach 2 is broken and unsafe to use...",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Capture Photo
            // Capture Photo
const Text("Attach Media",
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
const SizedBox(height: 10),
GestureDetector(
  onTap: _takePhoto,
  child: Container(
    height: 150,
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: _image == null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text("Tap to Capture Photo",
                  style: TextStyle(color: Colors.grey)),
            ],
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _image!,
              width: double.infinity,
              height: 150,        // 👈 Fixes the height
              fit: BoxFit.cover,  // 👈 Makes it fit the container nicely
            ),
          ),
  ),
),
if (_isUploadingImage)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text("Uploading image..."),
                  ],
                ),
              ),
            if (_uploadedUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SelectableText(
                  "Image Link: $_uploadedUrl",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),


            const SizedBox(height: 16),

            // Location
            // Location Container
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey.shade400),
    borderRadius: BorderRadius.circular(12),
    color: Colors.grey.shade100,
  ),
  child: _isLoadingLocation
      ? const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text("Fetching location..."),
          ],
        )
      : (_lat != null && _lng != null && _address != null)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Latitude: $_lat"),
                Text("Longitude: $_lng"),
                const SizedBox(height: 6),
                Text("Address: $_address"),
              ],
            )
          : const Text("No location available"),
),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Submit",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
} 
