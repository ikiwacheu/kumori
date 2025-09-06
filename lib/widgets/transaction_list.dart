import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/date_helper.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function(Transaction) onEdit;
  final Function(String) onDelete;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Нет транзакций',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final groupedTransactions =
        DateHelper.groupTransactionsByDate(transactions);

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 80),
      itemCount: _getTotalItemCount(groupedTransactions),
      itemBuilder: (ctx, index) {
        final item = _getItemAtIndex(groupedTransactions, index);

        if (item['type'] == 'header') {
          final groupTransactions = item['transactions'] as List<Transaction>;
          return _buildDateHeader(
              context, item['title'] as String, groupTransactions);
        } else {
          final tx = item['transaction'] as Transaction;
          return _buildTransactionCard(context, tx);
        }
      },
    );
  }

  int _getTotalItemCount(Map<String, List<Transaction>> groupedTransactions) {
    int count = 0;
    for (final group in groupedTransactions.entries) {
      count += 1; // заголовок группы
      count += group.value.length; // транзакции в группе
    }
    return count;
  }

  Map<String, dynamic> _getItemAtIndex(
      Map<String, List<Transaction>> groupedTransactions, int index) {
    int currentIndex = 0;

    for (final group in groupedTransactions.entries) {
      // чекаем заголовок группы
      if (currentIndex == index) {
        return {
          'type': 'header',
          'title': group.key,
          'transactions': group.value,
        };
      }
      currentIndex++;

      // чекаем транзакции в группе
      for (final transaction in group.value) {
        if (currentIndex == index) {
          return {
            'type': 'transaction',
            'transaction': transaction,
          };
        }
        currentIndex++;
      }
    }

    throw Exception('Index out of bounds');
  }

  Widget _buildDateHeader(
      BuildContext context, String title, List<Transaction> transactions) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // подсчитываем общие суммы для группы
    double totalIncome = transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    double totalExpense = transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    double netAmount = totalIncome - totalExpense;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.8),
                      colorScheme.primary.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconForDateGroup(title),
                      color: colorScheme.onPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transactions.length.toString(),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (transactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Row(
                children: [
                  if (totalIncome > 0) ...[
                    Icon(
                      Icons.arrow_upward,
                      color: colorScheme.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${totalIncome.toStringAsFixed(0)}Ӓ',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (totalIncome > 0 && totalExpense > 0)
                    const SizedBox(width: 16),
                  if (totalExpense > 0) ...[
                    Icon(
                      Icons.arrow_downward,
                      color: colorScheme.error,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '-${totalExpense.toStringAsFixed(0)}Ӓ',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (netAmount != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (netAmount > 0
                                ? colorScheme.primary
                                : colorScheme.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (netAmount > 0
                                  ? colorScheme.primary
                                  : colorScheme.error)
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${netAmount > 0 ? '+' : ''}${netAmount.toStringAsFixed(0)}Ӓ',
                        style: textTheme.bodySmall?.copyWith(
                          color: netAmount > 0
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForDateGroup(String title) {
    switch (title) {
      case 'Сегодня':
        return Icons.today;
      case 'Вчера':
        return Icons.history;
      case 'На этой неделе':
        return Icons.date_range;
      case 'В этом месяце':
        return Icons.calendar_month;
      default:
        return Icons.folder_outlined;
    }
  }

  Widget _buildTransactionCard(BuildContext context, Transaction tx) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: Key(tx.id),
      background: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.error,
              colorScheme.error.withValues(alpha: 0.8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.error.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Удалить',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onError,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.delete_sweep,
              color: colorScheme.onError,
              size: 28,
            ),
          ],
        ),
      ),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.6,
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Подтверждение удаления',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Вы действительно хотите удалить транзакцию "${tx.title}"?',
                style: textTheme.bodyLarge,
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text('Удалить'),
                ),
              ],
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            );
          },
        );
      },
      onDismissed: (direction) {
        onDelete(tx.id);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: tx.isIncome
            ? colorScheme.secondaryContainer
            : colorScheme.secondaryContainer,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor:
                tx.isIncome ? colorScheme.primary : colorScheme.error,
            child: Icon(
              tx.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: tx.isIncome ? colorScheme.onPrimary : colorScheme.onError,
              size: 18,
            ),
          ),
          title: Text(
            tx.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontSize: 15,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('dd.MM.yyyy HH:mm').format(tx.date),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              if (tx.notes != null && tx.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    tx.notes!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tx.amount.toStringAsFixed(0)}Ӓ',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tx.isIncome ? colorScheme.primary : colorScheme.error,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.swipe_left_alt,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          onTap: () => onEdit(tx),
        ),
      ),
    );
  }
}
