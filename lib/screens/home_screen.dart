import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/budget_card.dart';
import '../widgets/transaction_list.dart';
import '../widgets/add_transaction_button.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Transaction> _transactions = [];
  String _searchQuery = '';
  bool _isSearching = false;
  final StorageService _storageService = StorageService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    try {
      final loadedTransactions = await _storageService.loadTransactions();
      if (mounted) {
        setState(() {
          _transactions.clear();
          _transactions.addAll(loadedTransactions);
          _transactions.sort((a, b) => b.date.compareTo(a.date));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка загрузки данных'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveTransactions() async {
    try {
      await _storageService.saveTransactions(_transactions);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка сохранения данных'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Transaction> get _filteredTransactions {
    if (_searchQuery.isEmpty) {
      return List.from(_transactions)..sort((a, b) => b.date.compareTo(a.date));
    }

    final query = _searchQuery.toLowerCase();
    return _transactions.where((tx) {
      return tx.title.toLowerCase().contains(query) ||
          tx.amount.toString().contains(query);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void _addTransaction(
      String title, double amount, bool isIncome, String? notes) {
    final newTransaction = Transaction(
      id: '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      title: title,
      amount: amount,
      date: DateTime.now(),
      isIncome: isIncome,
      notes: notes,
    );

    setState(() {
      _transactions.add(newTransaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    });

    _saveTransactions();
  }

  void _editTransaction(
      String id, String title, double amount, bool isIncome, String? notes) {
    setState(() {
      final index = _transactions.indexWhere((tx) => tx.id == id);
      if (index != -1) {
        _transactions[index] = Transaction(
          id: id,
          title: title,
          amount: amount,
          date: _transactions[index].date,
          isIncome: isIncome,
          notes: notes,
        );
        _transactions.sort((a, b) => b.date.compareTo(a.date));
      }
    });

    _saveTransactions();
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tx) => tx.id == id);
    });

    _saveTransactions();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  double get _totalIncome {
    return _transactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _totalExpense {
    return _transactions
        .where((tx) => !tx.isIncome)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _isSearching
                  ? _buildSearchBar()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kumori',
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: colorScheme.onSurface,
                            size: 28,
                          ),
                          onPressed: _toggleSearch,
                        ),
                      ],
                    ),
            ),
            BudgetCard(
              income: _totalIncome,
              expense: _totalExpense,
            ),
            Expanded(
              child: TransactionList(
                transactions: _filteredTransactions,
                onEdit: _showEditTransactionModal,
                onDelete: _deleteTransaction,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          AddTransactionButton(addTransaction: _addTransaction),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Поиск транзакций...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        suffixIcon: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
          onPressed: _toggleSearch,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      onChanged: _updateSearchQuery,
    );
  }

  void _showEditTransactionModal(Transaction transaction) {
    final titleController = TextEditingController(text: transaction.title);
    final amountController =
        TextEditingController(text: transaction.amount.toString());
    final notesController =
        TextEditingController(text: transaction.notes ?? '');
    bool isIncome = transaction.isIncome;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;

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
                    'Редактировать транзакцию',
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
                  Row(
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
                            setModalState(() {
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
                            setModalState(() {
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
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                                color: isIncome
                                    ? colorScheme.primary
                                    : Colors.orange),
                            foregroundColor:
                                isIncome ? colorScheme.primary : Colors.orange,
                          ),
                          child: const Text('Отмена'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
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
                                  content: Text(
                                      'Пожалуйста, введите название транзакции'),
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

                            _editTransaction(
                                transaction.id, title, amount, isIncome, notes);
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: isIncome
                                ? colorScheme.primaryContainer
                                : Colors.orange.withValues(alpha: 0.2),
                            foregroundColor: isIncome
                                ? colorScheme.onPrimaryContainer
                                : Colors.black,
                          ),
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
