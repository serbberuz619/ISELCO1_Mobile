import 'package:flutter/material.dart';

/// Screen kung saan idinidisplay ang static content para sa Corporate Values ng ISELCO.
/// Nilipat sa more_screen/about_us/corporate_values directory.
class CorporateValuesScreen extends StatelessWidget {
  const CorporateValuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Corporate Values',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            _buildValueItem(
              Icons.gavel_rounded,
              'Discipline',
              'Upholding strict adherence to rules and professional conduct.',
            ),
            _buildValueItem(
              Icons.groups_rounded,
              'Solidarity',
              'Working as one cohesive unit to achieve cooperative goals.',
            ),
            _buildValueItem(
              Icons.work_outline_rounded,
              'Professionalism',
              'Maintaining a high standard of competence and expertise.',
            ),
            _buildValueItem(
              Icons.verified_user_outlined,
              'Honesty',
              'Exhibiting truthfulness and transparency in all dealings.',
            ),
            _buildValueItem(
              Icons.volunteer_activism_rounded,
              'Generosity',
              'Giving back to the community and helping those in need.',
            ),
            _buildValueItem(
              Icons.gpp_good_rounded,
              'Palabra de Honor',
              'Keeping one\'s word of honor and fulfilling commitments.',
            ),
            _buildValueItem(
              Icons.church_rounded,
              'God-Centeredness',
              'Putting faith and divine guidance at the center of all actions.',
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget para sa bawat corporate value gamit ang modern tile layout
  Widget _buildValueItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.blueAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
