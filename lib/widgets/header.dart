import 'package:flutter/material.dart';
import '../ui/theme/app_colors.dart';

class Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onLogout;

  const Header({super.key, required this.title, required this.subtitle, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: const Center(child: Text('Bb', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 22))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
            if (onLogout != null) IconButton(onPressed: onLogout, icon: const Icon(Icons.logout, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
