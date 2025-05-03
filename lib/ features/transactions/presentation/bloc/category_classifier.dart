class CategoryClassifier {
  // Predefined keyword-to-category mappings
  static const Map<String, String> _categoryRules = {
    'starbucks': 'Food',
    'restaurant': 'Food',
    'cafe': 'Food',
    'uber': 'Transport',
    'taxi': 'Transport',
    'fuel': 'Transport',
    'cinema': 'Entertainment',
    'movie': 'Entertainment',
    'concert': 'Entertainment',
    'grocery': 'Groceries',
    'supermarket': 'Groceries',
    'rent': 'Housing',
    'electricity': 'Utilities',
    'water': 'Utilities',
    'internet': 'Utilities',
  };

  static String classify(String description) {
    final lowerDescription = description.toLowerCase();
    for (final entry in _categoryRules.entries) {
      if (lowerDescription.contains(entry.key)) {
        return entry.value;
      }
    }
    return 'Uncategorized';
  }
}