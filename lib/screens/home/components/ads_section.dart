import 'package:flutter/material.dart';

class _Deal {
  final String image;
  final String buttonLabel;
  const _Deal({required this.image, required this.buttonLabel});
}

class AdsSection extends StatelessWidget {
  final VoidCallback? onTap;

  const AdsSection({Key? key, this.onTap}) : super(key: key);

  static const List<_Deal> _deals = [
    _Deal(image: 'assets/images/image1.png', buttonLabel: 'RÉSERVER'),
    _Deal(image: 'assets/images/image3.png', buttonLabel: 'RÉSERVER'),
    _Deal(image: 'assets/images/image5.png', buttonLabel: 'PROFITER'),
  ];

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.05),
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Troov. ',
                  style: TextStyle(
                    fontSize: sw < 600 ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                TextSpan(
                  text: 'les meilleurs plans de divertissement sur Dakar',
                  style: TextStyle(
                    fontSize: sw < 600 ? 13 : 15,
                    color: Colors.grey.shade500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: sw * 0.05, right: sw * 0.01),
            itemCount: _deals.length,
            itemBuilder: (ctx, i) => _buildDealCard(_deals[i], sw),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDealCard(_Deal deal, double sw) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The poster image with 36px circular radius
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Image.asset(
                  deal.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // The bottom details row with grey capsule button
            Row(
              children: [
                // Pill button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F9394), // Mockup grey
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    deal.buttonLabel,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Text details on the right
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Plus de 2 places dispo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        "L'ardoise et +",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 7.5,
                          color: Colors.grey,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
