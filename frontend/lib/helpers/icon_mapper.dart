import 'package:flutter/material.dart';

class IconMapper {
  static IconData getIcon(String? key) {
    if (key == null) return Icons.circle;
    switch (key) {
      case 'engineering':
      case 'construction':
        return Icons.construction;
      case 'payment':
      case 'receipt_long':
        return Icons.receipt_long;
      case 'attach_money':
        return Icons.attach_money;
      case 'build':
        return Icons.build;
      case 'handyman':
        return Icons.handyman;
      case 'gavel':
        return Icons.gavel;
      case 'person':
        return Icons.person;
      case 'account_box':
        return Icons.account_box;
      case 'lock':
        return Icons.lock;
      case 'manage_accounts':
        return Icons.manage_accounts;
      case 'notifications_active':
        return Icons.notifications_active;
      case 'notifications':
        return Icons.notifications;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'logout':
        return Icons.logout;
      default:
        return Icons.help_outline;
    }
  }
}
