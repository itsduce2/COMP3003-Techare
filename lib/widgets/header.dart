import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String userName;
  final String subtitle;

  const AppHeader({
    super.key,
    required this.userName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $userName 👋',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          Row(
            children: const [
              Icon(Icons.notifications_none, size: 28),
              SizedBox(width: 16),
              Icon(Icons.account_circle, size: 40),
            ],
          ),
        ],
      ),
    );
  }
}
