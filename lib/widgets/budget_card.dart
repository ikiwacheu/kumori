import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final double income;
  final double expense;

  const BudgetCard({
    super.key,
    required this.income,
    required this.expense,
  });

  double get balance => income - expense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(
        top: 4,
        left: 16,
        right: 16,
        bottom: 4,
      ),
      elevation: 0,
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Бюджет',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            _buildBudgetItem(
              context,
              'Доходы',
              income,
              colorScheme.primary,
              Icons.arrow_upward,
            ),
            const SizedBox(height: 12),
            _buildBudgetItem(
              context,
              'Расходы',
              expense,
              colorScheme.error,
              Icons.arrow_downward,
            ),
            const SizedBox(height: 12),
            _buildBudgetItem(
              context,
              'Баланс',
              balance,
              balance >= 0 ? colorScheme.primary : colorScheme.error,
              balance >= 0 ? Icons.check_circle : Icons.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetItem(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${amount.toStringAsFixed(2)} Ӓ',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
