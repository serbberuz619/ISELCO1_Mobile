import 'package:flutter/material.dart';

/// Screen kung saan idinidisplay ang simula at kasaysayan ng ISELCO I.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'ISELCO UNO History',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withOpacity(0.1), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
              ),
              child: const Text(
                "The ISABELA I ELECTRIC COOPERATIVE, INC. was organized, incorporated and registered on March 24, 1972.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            _buildHistoryParagraph(
              "Before this date, a feasibility study was conducted by the Provincial Electric Cooperative Team (PECT) created by Governor Faustino N. Dy, to facilitate the implementation of the electrification program of the government, designating Honorable Efren N. Ambrosio, then a Provincial Board Member to head the team, together with the Municipal mayor of Ramon - Angelino Viscarra, Ricardo N. Bareng - NEA Training Officer; Napoleon N. Daway - PACD; Eusebio M. Juan - BVS, Head, Vocational Department; Antonio B. Martinez - CAO-CCO and Cesar Melegrito PACD-APDC.",
            ),
            _buildHistoryParagraph(
              "The feasibility study covered six (6) municipalities - Alicia, Angadanan, Echague, San Isidro, Ramon, and San Mateo - the nucleus of ISELCO I coverage area.",
            ),
            _buildHistoryParagraph(
              "The organization of ISELCO I Board of Directors was facilitated by organizing the District Electrification Committee of the six (6) municipalities who elected their Chairman. The Chairman became the Directors of the 1st Ad interim Board (Incorporators) of ISELCO I with the following officers: Chairman - Arsenio B. Bumalay, Sr.; Vice-President Engr. Inocencio C. Castañeda; Secretary - Eufracio M. Gumpal; Treasurer Col. Andres Damian; Members: Rolando P. Garcia and Rafael Zipagan.",
            ),
            _buildHistoryParagraph(
              "The interim Board sworn into office by Governor Faustino N. Dy without delay. The Board immediately went into business, adopted the constitution and by-laws, signed the incorporation papers, ratified by proper authorities concerned after which the Franchise of ISELCO I was delivered to the Board. Under the guidance of Atty. Aristedes Sebastian, Board Resolution was adopted by the Directors and other legal actuations necessary as initial performance of the 1st Ad Interim Board.",
            ),
            _buildHistoryParagraph(
              "On March 22, 1972, the District Electrification Committee of the six (6) municipalities with the Chairman met in Alicia Elementary School where a formal program of organization, incorporation and registration was effected in a package deal delivered by the representatives of the National Electrification Committee headed by Acting Administrator Leonardo Coloso, officiated by the Provincial Governor Faustino N. Dy and other ranking officials connected with rural electrification program of the administration.",
            ),
            _buildHistoryParagraph(
              "On July 12, 1973, the Board held a meeting at the Ideal Restaurant, Echague, Isabela, appointing the General Manager of the Isabela I Electric Cooperative, Inc., Engr. Pablo S. Sison.",
            ),
            _buildHistoryParagraph(
              "Closely after the appointment of the General Manager, the board was called to NEA to sign the first loan given to ISELCO I in the amount of P26,301,800.00 followed by the hiring or appointment of the Adrian Wilson International Association (AWIA) as the Engineering Consultants of ISELCO I.",
            ),
            _buildHistoryParagraph(
              "On February 1974, the Board of Directors and the General Manager were sent to attend the 7th NEA Cooperative Management Course held at Searsolin, Cagayan de Oro.",
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          height: 1.6,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
