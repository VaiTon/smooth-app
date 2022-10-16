import 'package:flutter/foundation.dart';
import 'package:openfoodfacts/model/RobotoffQuestion.dart';
import 'package:smooth_app/database/dao_string_list_map.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_questions_query.dart';

class RobotoffInsightHelper {
  const RobotoffInsightHelper(this._localDatabase);
  final LocalDatabase _localDatabase;

  Future<void> cacheInsightAnnotationVoted(
    String barcode,
    String insightId,
  ) async {
    await DaoStringListMap(_localDatabase).add(barcode, insightId);
  }

  Future<bool> areQuestionsAlreadyVoted(
    Set<RobotoffQuestion> questionSet,
  ) async {
    final Map<String, List<String>> votedHist =
        await DaoStringListMap(_localDatabase).getAll();

    final Set<String> newIdsSet = questionSet
        .map((RobotoffQuestion e) => e.insightId)
        .whereType<String>()
        .toSet();

    final Iterable<List<String>> dbInsights = votedHist.values;

    return dbInsights
        .any((List<String> votedIds) => setEquals(newIdsSet, votedIds.toSet()));
  }

  Future<void> removeInsightAnnotationsSavedForProdcut(String barcode) async {
    await DaoStringListMap(_localDatabase).removeKey(barcode);
  }

  Future<void> clearInsightAnnotationsSaved() async {
    final Map<String, List<String>> records =
        await DaoStringListMap(_localDatabase).getAll();
    for (final String barcode in records.keys) {
      final Set<RobotoffQuestion> questions =
          await ProductQuestionsQuery(barcode)
              .getQuestions();
      if (questions.isEmpty) {
        await DaoStringListMap(_localDatabase).removeKey(barcode);
      }
    }
  }
}
