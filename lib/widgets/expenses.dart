import 'package:expense/widgets/expenses_list/expenses_list.dart';
import 'package:expense/models/expense.dart';
import 'package:expense/widgets/new_expense.dart';
import 'package:flutter/material.dart';
import 'package:expense/widgets/chart/chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() {
    return _ExpensesState();
  }
}

class _ExpensesState extends State<Expenses> {
  // FIXED: Removed "final" to allow reassignment after loading
  List<Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses(); // Load saved data on start
  }

  void _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expenseList = _registeredExpenses.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(expenseList);
    await prefs.setString('expenses', jsonString);
  }

 void _loadExpenses() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('expenses');


  if (data != null && _registeredExpenses.isEmpty) {
    final List decoded = jsonDecode(data);
    final loadedExpenses =
        decoded.map((item) => Expense.fromJson(item)).toList();

    setState(() {
      _registeredExpenses = loadedExpenses;
    });

  }
}

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

void _addExpense(Expense expense) {
  setState(() {
    _registeredExpenses.add(expense);
  });
  _saveExpenses(); // Make sure this is called ONCE
}

  void _removeExpense(Expense expense) {
    final expenseIndex = _registeredExpenses.indexOf(expense);
    setState(() {
      _registeredExpenses.remove(expense);
    });
    _saveExpenses(); // Save after removing

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: const Text('Deleted expense'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
            _saveExpenses(); // Save after undo
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    Widget mainContent = const Center(
      child: Text('No Expenses found. Start adding some!'),
    );
    if (_registeredExpenses.isNotEmpty) {
      mainContent = ExpensesList(
        expenses: _registeredExpenses,
        onRemoveExpense: _removeExpense,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ExpenseTracker'),
        actions: [
          IconButton(
            onPressed: _openAddExpenseOverlay,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: width < 600
          ? Column(
              children: [
                Chart(expenses: _registeredExpenses),
                Expanded(child: mainContent),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Chart(expenses: _registeredExpenses),
                ),
                Expanded(child: mainContent),
              ],
            ),
    );
  }
}