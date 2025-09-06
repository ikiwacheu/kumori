import 'package:flutter/material.dart';

class AddTransactionButton extends StatelessWidget {
  final Function(String title, double amount, bool isIncome, String? notes)
      addTransaction;

  const AddTransactionButton({super.key, required this.addTransaction});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 64,
      height: 64,
      child: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    bool isIncome = false;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Новая транзакция',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Название',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.description,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                controller: titleController,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Сумма (Ӓ)',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Заметки',
                  labelStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.comment,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                controller: notesController,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Тип транзакции:',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.arrow_downward,
                            size: 18,
                            color: !isIncome ? Colors.orange : null,
                          ),
                          label: Text(
                            'Расход',
                            style: TextStyle(
                              color: !isIncome ? Colors.orange : null,
                              fontWeight: !isIncome
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isIncome = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isIncome
                                ? Colors.orange.withValues(alpha: 0.2)
                                : null,
                            elevation: !isIncome ? 2 : 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.arrow_upward,
                            size: 18,
                            color: isIncome ? colorScheme.primary : null,
                          ),
                          label: Text(
                            'Доход',
                            style: TextStyle(
                              color: isIncome ? colorScheme.primary : null,
                              fontWeight: isIncome
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isIncome = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isIncome ? colorScheme.primaryContainer : null,
                            elevation: isIncome ? 2 : 0,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amountText = amountController.text.trim();
                    final notes = notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Пожалуйста, введите название транзакции'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (amountText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Пожалуйста, введите сумму'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Пожалуйста, введите корректную положительную сумму'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (amount > 999999999) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Сумма слишком большая. Максимум: 999,999,999'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    addTransaction(title, amount, isIncome, notes);
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                  child: const Text(
                    'Добавить',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
