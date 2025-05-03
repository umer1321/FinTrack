import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/budget_model.dart';
import 'package:intl/intl.dart';

import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Curved background
        Container(
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        // Budget list
        RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<BudgetBloc>(context).add(const LoadBudgetsEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: const Color(0xFF4CAF50),
          backgroundColor: Colors.white,
          child: BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, state) {
              if (state is BudgetLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4CAF50),
                  ),
                );
              } else if (state is BudgetLoaded) {
                if (state.budgets.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                  itemCount: state.budgets.length,
                  itemBuilder: (context, index) {
                    final budget = state.budgets[index];
                    return _buildBudgetCard(context, budget);
                  },
                );
              } else if (state is BudgetError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          BlocProvider.of<BudgetBloc>(context)
                              .add(const LoadBudgetsEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }
              return _buildEmptyState(context);
            },
          ),
        ),

        // Floating Action Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/budget-form');
            },
            backgroundColor: const Color(0xFF4CAF50),
            icon: const Icon(Icons.add),
            label: const Text('Add Budget'),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(BuildContext context, Budget budget) {
    // Calculate progress percentage
    final double progress = budget.amount > 0 ? 0.65 : 0; // Example value, replace with actual calculation
    final bool isExceeded = progress > 1.0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/budget-form',
            arguments: budget,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category icon and name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(budget.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getCategoryIcon(budget.category),
                          color: _getCategoryColor(budget.category),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatMonth(budget.month),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Options menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          '/budget-form',
                          arguments: budget,
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmDialog(context, budget);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Budget amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget Amount:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'ر.س${budget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress bar
              LinearProgressIndicator(
                value: progress > 1.0 ? 1.0 : progress,
                backgroundColor: Colors.grey[200],
                color: isExceeded ? Colors.red : const Color(0xFF4CAF50),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),

              // Spent amount and remaining
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ر.س${(budget.amount * progress).toStringAsFixed(2)} spent',
                    style: TextStyle(
                      color: isExceeded ? Colors.red : Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    isExceeded
                        ? 'ر.س${((budget.amount * progress) - budget.amount).toStringAsFixed(2)} over budget'
                        : 'ر.س${(budget.amount - (budget.amount * progress)).toStringAsFixed(2)} remaining',
                    style: TextStyle(
                      color: isExceeded ? Colors.red : Colors.grey[700],
                      fontSize: 13,
                      fontWeight: isExceeded ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'No budgets yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a budget to help manage your expenses',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/budget-form');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete the ${budget.category} budget for ${_formatMonth(budget.month)}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              BlocProvider.of<BudgetBloc>(context).add(DeleteBudgetEvent(budget.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Budget deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  margin: EdgeInsets.all(16),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'housing':
        return Icons.home;
      case 'utilities':
        return Icons.bolt;
      case 'entertainment':
        return Icons.movie;
      case 'shopping':
        return Icons.shopping_bag;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'housing':
        return Colors.brown;
      case 'utilities':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'shopping':
        return Colors.teal;
      case 'health':
        return Colors.red;
      case 'education':
        return Colors.amber;
      case 'travel':
        return Colors.indigo;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String _formatMonth(String month) {
    // Assuming month format is 'yyyy-MM'
    try {
      final parts = month.split('-');
      if (parts.length == 2) {
        final DateTime date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        return DateFormat('MMMM yyyy').format(date);
      }
      return month;
    } catch (e) {
      return month;
    }
  }
}