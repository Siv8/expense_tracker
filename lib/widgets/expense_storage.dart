

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:expense/models/expense.dart';

class ExpenseStorage {
  static const _key = 'expenses';

  static Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => Expense.fromJson(e)).toList();
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(expenses.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<void> addExpense(Expense expense) async {
    final current = await loadExpenses();
    current.add(expense);
    await saveExpenses(current);
  }
}