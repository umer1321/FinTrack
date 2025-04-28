import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import ' features/Budget/bloc/budget_bloc.dart';
import ' features/Budget/bloc/budget_event.dart';
import ' features/Budget/bloc/budget_state.dart';
import ' features/Budget/screens/budget_list_screen.dart';
import ' features/analytics_screen.dart';
import ' features/auth/presentation/bloc/auth_bloc.dart';
import ' features/auth/presentation/bloc/auth_event.dart';
import ' features/auth/presentation/bloc/auth_state.dart';
import ' features/data_export_import.dart';
import ' features/transactions/presentation/bloc/transaction_bloc.dart';
import ' features/transactions/presentation/bloc/transaction_event.dart';
import ' features/transactions/presentation/bloc/transaction_state.dart';
import ' features/transactions/presentation/screens/transaction_list_screen.dart';
import 'core/models/budget_model.dart';
import 'core/models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final DataExportImport _dataExportImport = DataExportImport();

  static const List<Widget> _screens = [
    TransactionListScreen(),
    BudgetListScreen(),
    AnalyticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load transactions and budgets when HomeScreen is first built
    context.read<TransactionBloc>().add(const LoadTransactionsEvent());
    context.read<BudgetBloc>().add(const LoadBudgetsEvent());
  }

  Future<void> _exportData() async {
    // Get transactions and budgets from the blocs
    final transactionState = context.read<TransactionBloc>().state;
    final budgetState = context.read<BudgetBloc>().state;

    if (transactionState is TransactionLoaded && budgetState is BudgetLoaded) {
      final transactions = transactionState.transactions;
      final budgets = budgetState.budgets;

      final filePath = await _dataExportImport.exportData(transactions, budgets);
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export data')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data not loaded yet')),
      );
    }
  }

  Future<void> _importData() async {
    final importedData = await _dataExportImport.importData();
    if (importedData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to import data')),
      );
      return;
    }

    // Import transactions
    final transactions = importedData['transactions'] as List<dynamic>;
    for (var transaction in transactions) {
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction as Map<String, dynamic>));
    }

    // Import budgets
    final budgets = importedData['budgets'] as List<dynamic>;
    for (var budgetData in budgets) {
      final budget = budgetData as Budget;
      context.read<BudgetBloc>().add(AddBudgetEvent({
        'category': budget.category,
        'amount': budget.amount.toString(),
        'month': budget.month,
      }));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data imported successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              _selectedIndex == 0
                  ? 'Transactions'
                  : _selectedIndex == 1
                  ? 'Budgets'
                  : 'Analytics',
            ),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    context.read<AuthBloc>().add(const SignOutEvent());
                  } else if (value == 'export') {
                    _exportData();
                  } else if (value == 'import') {
                    _importData();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Text('Export Data'),
                  ),
                  const PopupMenuItem(
                    value: 'import',
                    child: Text('Import Data'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Transactions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Budgets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF4CAF50),
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}