import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final primaryColor = theme.primaryColor;

    return AppBar(
      elevation: 0,
      shadowColor: colors.shadow,
      shape: Border(
        bottom: BorderSide(
          color: colors.outlineVariant,
          width: 1,
        ) as BorderSide,
      ),
      title: Text(
        'RideLink',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: primaryColor,
        ),
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_none_rounded,
                size: 30,
                color: colors.onSurface,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.surface,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.primary,
              width: 2,
            ),
          ),
          child: const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/300',
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}
