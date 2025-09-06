import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';

  // сохр транзакции в SharedPreferences
  Future<void> saveTransactions(List<Transaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList =
          transactions.map((tx) => jsonEncode(tx.toJson())).toList();
      await prefs.setStringList(_transactionsKey, jsonList);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving transactions: $e');
      }
      // переход к работе только в памяти в случае ошибки
    }
  }

  // загружаем транзакции из SharedPreferences
  Future<List<Transaction>> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(_transactionsKey);

      if (jsonList == null || jsonList.isEmpty) {
        return [];
      }

      return jsonList.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return Transaction.fromJson(json);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading transactions: $e');
      }
      // возвращаем пустой список в случае ошибки
      return [];
    }
  }
}
