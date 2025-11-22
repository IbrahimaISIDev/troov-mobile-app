import 'package:flutter/material.dart';

class MessagesSection extends StatelessWidget {
  final Function(int) onChatTap;
  final VoidCallback onViewAllTap;

  const MessagesSection({
    Key? key,
    required this.onChatTap,
    required this.onViewAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Messages récents',
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Semantics(
                button: true,
                label: 'Voir tous les messages',
                child: TextButton(
                  onPressed: onViewAllTap,
                  child: Text(
                    'Voir tout',
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 12 : 14,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.04),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildChatStatus(index, screenWidth);
              },
            ),
          ),
          SizedBox(height: screenWidth * 0.05),
        ],
      ),
    );
  }

  Widget _buildChatStatus(int index, double screenWidth) {
    List<Color> profileColors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
      Colors.indigo.shade400,
    ];
    List<int> messageCounts = [3, 1, 5, 2, 8, 1, 12, 4];

    return GestureDetector(
      onTap: () => onChatTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: screenWidth * 0.04, left: screenWidth * 0.0125),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: screenWidth < 600 ? 60 : 65,
                  height: screenWidth < 600 ? 60 : 65,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Semantics(
                      image: true,
                      label: 'Profil de User ${index + 1}',
                      child: Image.asset(
                        'assets/images/ouz.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Erreur de chargement de l'image de profil ${index + 1}: $error");
                          return Container(
                            color: profileColors[index % profileColors.length],
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth < 600 ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (messageCounts[index % messageCounts.length] > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: screenWidth < 600 ? 20 : 22,
                      height: screenWidth < 600 ? 20 : 22,
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${messageCounts[index % messageCounts.length]}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth < 600 ? 9 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              'User ${index + 1}',
              style: TextStyle(
                fontSize: screenWidth < 600 ? 12 : 14,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}