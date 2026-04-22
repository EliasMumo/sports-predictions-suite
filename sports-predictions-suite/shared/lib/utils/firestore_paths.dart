import '../constants/categories.dart';

class FirestorePaths {
  FirestorePaths._();

  static const String predictionsRoot = 'predictions';
  static const String historyRoot = 'history';
  static const String matchesCollection = 'matches';

  static String categoryDocumentPath(PredictionCategory category) {
    final root = category.collectionType == CategoryCollectionType.predictions ? predictionsRoot : historyRoot;
    return '$root/${category.id}';
  }

  static String matchesPath(PredictionCategory category) {
    return '${categoryDocumentPath(category)}/$matchesCollection';
  }
}
