import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';

  // Save transactions to SharedPreferences
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
      // Fallback to in-memory only in case of error
    }
  }

  // Load transactions from SharedPreferences
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
      // Return empty list in case of error
      return [];
    }
  }
}
