import 'package:flutter/material.dart';
import 'package:kmrldb/presentation/pages/screens/dashboard/file_list_screen.dart';

class Directivesscreen extends StatefulWidget {
  const Directivesscreen({super.key});

  @override
  State<Directivesscreen> createState() => _DirectivesscreenState();
}

class _DirectivesscreenState extends State<Directivesscreen> {
  final Map<String, List<String>> departmentFiles = {
    "Operations Department": [
      "Standard Operating Procedures.pdf",
      "Daily Duty Roster.xlsx",
      "Emergency Protocols.docx",
    ],
    "Engineering & Maintenance": [
      "Maintenance Schedule.xlsx",
      "Asset Inspection Report.pdf",
      "Technical Manual.pdf",
    ],
    "Rolling Stock (Trains)": [
      "Train Performance Report.pdf",
      "Safety Checklist.docx",
      "Maintenance Logbook.xlsx",
    ],
    "Signaling & Electrical (S&T / E&M)": [
      "Circuit Diagrams.pdf",
      "Fault Logs.xlsx",
      "System Upgrade Report.docx",
    ],
    "Procurement & Stores (Materials Management)": [
      "Vendor List.pdf",
      "Purchase Orders.xlsx",
      "Inventory Report.pdf",
    ],
    "Finance Department": [
      "Annual Budget.xlsx",
      "Audit Report.pdf",
      "Expense Statement.docx",
    ],
    "Human Resources (HR)": [
      "Employee Handbook.pdf",
      "Leave Policy.docx",
      "Training Plan.pdf",
    ],
    "Legal & Compliance": [
      "Contract Template.docx",
      "Compliance Checklist.pdf",
      "Legal Notices.pdf",
    ],
    "Safety Department": [
      "Safety Guidelines.pdf",
      "Accident Report.docx",
      "Fire Drill Instructions.pdf",
    ],
    "Environmental & CSR": [
      "Sustainability Report.pdf",
      "Environmental Impact.pdf",
      "CSR Activity Report.docx",
    ],
    "Executive / Board of Directors": [
      "Strategic Plan.pdf",
      "Meeting Minutes.docx",
      "Policy Directives.pdf",
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Directives'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: departmentFiles.keys.length,
        itemBuilder: (context, index) {
          String department = departmentFiles.keys.elementAt(index);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            child: SizedBox(
              height: 80,
              child: Card(
                elevation: 3,
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.folder, color: Colors.blue),
                  title: Text(
                    department,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FilesScreen(
                          department: department,
                          files: departmentFiles[department]!,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
