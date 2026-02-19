extension StringExt on String {
  /// Capitalize first letter
  /// Example: "hello".capitalize => "Hello"
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  /// Example: "hello world".capitalizeWords => "Hello World"
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Get initials dari nama
  /// Example: "John Doe".initials => "JD"
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return words
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
  }

  /// Format nomor telepon Indonesia
  /// Example: "081234567890".formatPhone => "0812-3456-7890"
  String get formatPhone {
    final cleaned = replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10) return this;

    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 11) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 12) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    } else if (cleaned.length == 13) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    }
    return this;
  }

  /// Check apakah string adalah email valid
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Check apakah string adalah nomor telepon valid
  bool get isValidPhone {
    final cleaned = replaceAll(RegExp(r'[^\d]'), '');
    return cleaned.length >= 10 && cleaned.length <= 13;
  }

  /// Truncate string dengan ellipsis
  /// Example: "Hello World".truncate(8) => "Hello..."
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }
}
