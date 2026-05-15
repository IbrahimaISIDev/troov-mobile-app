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
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Troov. ',
                  style: TextStyle(
                    fontSize: sw < 600 ? 15 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: 'le meilleur des plans, deals et divertissements',
                  style: TextStyle(
                    fontSize: sw < 600 ? 13 : 15,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: sw * 0.05),
            itemCount: _deals.length,
            itemBuilder: (ctx, i) => _buildDealCard(_deals[i], sw),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDealCard(_Deal deal, double sw) {
    return Container(
      width: sw * 0.55,
      margin: const EdgeInsets.only(right: 14, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
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
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFF215E8C), width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    deal.buttonLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF215E8C),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
