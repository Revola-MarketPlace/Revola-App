import 'package:intl/intl.dart';

class Formatters {
  static String formatEtb(num? amount) {
    if (amount == null) return '0.00 ETB';
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${formatter.format(amount)} ETB';
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDistance(double? km) {
    if (km == null) return 'Nearby';
    if (km < 1.0) {
      return '${(km * 1000).round()} m away';
    }
    return '${km.toStringAsFixed(1)} km away';
  }
}
