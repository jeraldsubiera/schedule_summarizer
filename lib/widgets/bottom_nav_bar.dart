import 'package:flutter/material.dart';
import '../theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShuttleTheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: ShuttleTheme.neonPink.withOpacity(0.2), width: 1.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today,
              label: 'Schedule',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              label: 'Results',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.help_outline_outlined,
              activeIcon: Icons.help_outline,
              label: 'Info',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20.0 : 12.0,
          vertical: 6.0,
        ),
        decoration: BoxDecoration(
          color: isActive 
              ? ShuttleTheme.neonPink 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
          boxShadow: isActive ? [
            BoxShadow(
              color: ShuttleTheme.neonPink.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive 
                  ? Colors.white 
                  : ShuttleTheme.secondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: ShuttleTheme.labelCaps.copyWith(
                color: isActive 
                    ? Colors.white 
                    : ShuttleTheme.secondary,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
