import 'package:flutter/material.dart';

class StoryStatusAvatar extends StatelessWidget {
  final String? imageUrl;
  final Widget? child;
  final double radius;
  final bool hasStory;
  final bool isRead;
  final bool isSponsored;
  final VoidCallback? onTap;
  final double borderWidth;
  final double padding;

  const StoryStatusAvatar({
    Key? key,
    this.imageUrl,
    this.child,
    this.radius = 30, // Default to 60px diameter
    this.hasStory = false,
    this.isRead = false,
    this.isSponsored = false,
    this.onTap,
    this.borderWidth = 2.0,
    this.padding = 3.0,
  })  : assert(imageUrl != null || child != null,
            'Either imageUrl or child must be provided'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (child != null) {
      avatar = SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: child,
      );
    } else {
      avatar = Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              Colors.grey[200], // Background for transparent images or fallback
        ),
        child: ClipOval(
          child: _buildImage(),
        ),
      );
    }

    if (hasStory) {
      Color borderColor;
      if (isSponsored) {
        borderColor = Colors.orange;
      } else if (isRead) {
        borderColor = Colors.grey;
      } else {
        borderColor = Colors.green;
      }

      avatar = Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Icon(Icons.person, color: Colors.grey[400]);
    }

    if (imageUrl!.startsWith('http')) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        width: radius * 2,
        height: radius * 2,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, color: Colors.grey[400]);
        },
      );
    }

    // Asset
    return Image.asset(
      imageUrl!,
      fit: BoxFit.cover,
      width: radius * 2,
      height: radius * 2,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.person, color: Colors.grey[400]);
      },
    );
  }
}
