import '../models/transaction.dart';

class DateHelper {
  static String getDateGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Сегодня';
    } else if (transactionDate == yesterday) {
      return 'Вчера';
    } else if (transactionDate.isAfter(startOfWeek) &&
        transactionDate.isBefore(today)) {
      return 'На этой неделе';
    } else if (transactionDate.year == now.year &&
        transactionDate.month == now.month) {
      return 'В этом месяце';
    } else if (transactionDate.year == now.year) {
      return _getMonthName(transactionDate.month);
    } else {
      return '${transactionDate.year} год';
    }
  }

  static String _getMonthName(int month) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];
    return months[month - 1];
  }

  static Map<String, List<Transaction>> groupTransactionsByDate(
      List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};

    for (final transaction in transactions) {
      final groupLabel = getDateGroupLabel(transaction.date);
      if (!grouped.containsKey(groupLabel)) {
        grouped[groupLabel] = [];
      }
      grouped[groupLabel]!.add(transaction);
    }

    // Сортируем группы по приоритету
    final sortedGroups = <String, List<Transaction>>{};
    final groupOrder = [
      'Сегодня',
      'Вчера',
      'На этой неделе',
      'В этом месяце',
    ];

    // Добавляем группы в правильном порядке
    for (final group in groupOrder) {
      if (grouped.containsKey(group)) {
        sortedGroups[group] = grouped[group]!;
        grouped.remove(group);
      }
    }

    // Добавляем оставшиеся группы (месяцы и годы)
    final remainingKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final key in remainingKeys) {
      sortedGroups[key] = grouped[key]!;
    }

    // Сортируем транзакции внутри каждой группы по дате (новые сверху)
    for (final group in sortedGroups.values) {
      group.sort((a, b) => b.date.compareTo(a.date));
    }

    return sortedGroups;
  }
}
