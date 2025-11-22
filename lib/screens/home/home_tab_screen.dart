import 'package:flutter/material.dart';
import 'components/home_tab_header.dart';
import 'components/main_image_section.dart';
// import 'components/ads_section.dart';
import 'components/messages_section.dart';
import 'components/product_section.dart';
import '../services/services_screen.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              HomeTabHeader(
                onSearchTap: () {
                  print('Search tapped');
                },
                onNotificationsTap: () {
                  print('Notifications tapped');
                },
              ),
              MainImageSection(
                onDiscoverTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ServicesScreen()),
                  );
                },
              ),
              // AdsSection(
              //   onAdTap: (index) {
              //     print('Ad ${index + 1} tapped');
              //   },
              // ),
              MessagesSection(
                onChatTap: (index) {
                  print('Chat with User ${index + 1} tapped');
                },
                onViewAllTap: () {
                  print('View all messages tapped');
                },
              ),
              ProductSection(
                title: 'Troov. Mobilier d\'occasion à bon prix',
                images: List.generate(
                  5,
                  (index) => 'assets/images/refri.png',
                ),
                colors: [
                  Colors.indigo.shade300,
                  Colors.teal.shade300,
                  Colors.pink.shade300,
                  Colors.amber.shade300,
                  Colors.cyan.shade300,
                ],
                onProductTap: (index) {
                  print('Product ${index + 1} in Mobilier tapped');
                },
                onSeeMoreTap: () {
                  print('See more in Mobilier tapped');
                },
              ),
              ProductSection(
                title: 'Troov. Transferts d\'argent au meilleur prix',
                images: List.generate(
                  5,
                  (index) => 'assets/images/refri.png',
                ),
                colors: [
                  Colors.blue.shade300,
                  Colors.green.shade300,
                  Colors.orange.shade300,
                  Colors.purple.shade300,
                  Colors.red.shade300,
                ],
                onProductTap: (index) {
                  print('Product ${index + 1} in Transferts tapped');
                },
                onSeeMoreTap: () {
                  print('See more in Transferts tapped');
                },
              ),
              SizedBox(height: screenWidth * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}