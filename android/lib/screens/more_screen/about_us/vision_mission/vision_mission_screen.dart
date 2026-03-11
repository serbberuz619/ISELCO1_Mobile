import 'package:flutter/material.dart';

/// Screen kung saan idinidisplay ang static content para sa Vision at Mission ng ISELCO.
class VisionMissionScreen extends StatelessWidget {
  const VisionMissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Vision & Mission',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withValues(alpha: 0.1), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: "VISION",
              icon: Icons.visibility_outlined,
              content:
                  "An excellent power service distributor in the archipelago focused on bringing delight to our member-consumer-owners.",
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: "MISSION",
              icon: Icons.track_changes_outlined,
              content:
                  "To deliver high quality electric service responsive to the changing consumer's demand.",
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget para mapanatiling malinis ang code natin sa bawat section
  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
