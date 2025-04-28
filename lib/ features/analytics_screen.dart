import 'package:fintrack/%20features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:fintrack/%20features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:fintrack/core/models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _filter = 'month'; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Analytics'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionLoaded) {
            final transactions = state.transactions;
            final filteredData = _filterData(transactions, _filter);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterDropdown(),
                    const SizedBox(height: 16),
                    _buildChart(
                      'Expenses (ر.س)',
                      filteredData['expenses']!,
                      Colors.red,
                      _filter,
                    ),
                    const SizedBox(height: 32),
                    _buildChart(
                      'Income (ر.س)',
                      filteredData['income']!,
                      Colors.green,
                      _filter,
                    ),
                    const SizedBox(height: 32),
                    _buildChart(
                      'Savings (ر.س)',
                      filteredData['savings']!,
                      Colors.blue,
                      _filter,
                    ),
                  ],
                ),
              ),
            );
          } else if (state is TransactionError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No transactions found'));
        },
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        DropdownButton<String>(
          value: _filter,
          items: const [
            DropdownMenuItem(value: 'month', child: Text('Last Month')),
            DropdownMenuItem(value: 'three_months', child: Text('Last 3 Months')),
            DropdownMenuItem(value: 'year', child: Text('Last Year')),
          ],
          onChanged: (value) {
            setState(() {
              _filter = value!;
            });
          },
          style: const TextStyle(color: Color(0xFF1A3C34), fontSize: 16),
          underline: Container(height: 2, color: const Color(0xFF4CAF50)),
        ),
      ],
    );
  }

  Widget _buildChart(String title, List<FlSpot> data, Color color, String filter) {
    // Check if all y-values are 0 (no meaningful data to plot)
    final hasData = data.any((spot) => spot.y != 0);

    if (!hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C34),
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No data to display',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    // Calculate horizontal interval, ensuring it's never 0
    final maxY = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2;
    final double horizontalInterval = (maxY / 5) > 0 ? (maxY / 5) : 200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3C34),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: horizontalInterval,
                drawVerticalLine: false,
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (filter == 'month') {
                        final date = DateTime.now().subtract(Duration(days: (30 - value.toInt())));
                        return Text(
                          DateFormat('d').format(date),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      } else if (filter == 'three_months') {
                        final date = DateTime.now().subtract(Duration(days: (90 - value.toInt() * 30)));
                        return Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      } else {
                        final date = DateTime.now().subtract(Duration(days: (365 - value.toInt() * 30)));
                        return Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        );
                      }
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: true,
                  color: color,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              minY: 0,
              maxY: maxY > 0 ? maxY : 1000,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, List<FlSpot>> _filterData(List<Transaction> transactions, String filter) {
    final now = DateTime.now();
    DateTime startDate;
    int intervals;

    if (filter == 'month') {
      startDate = now.subtract(const Duration(days: 30));
      intervals = 30; // Daily data for 30 days
    } else if (filter == 'three_months') {
      startDate = now.subtract(const Duration(days: 90));
      intervals = 3; // Monthly data for 3 months
    } else {
      startDate = now.subtract(const Duration(days: 365));
      intervals = 12; // Monthly data for 12 months
    }

    // Initialize data points
    List<double> expenses = List.filled(intervals, 0.0);
    List<double> income = List.filled(intervals, 0.0);
    List<double> savings = List.filled(intervals, 0.0);

    // Process transactions
    for (var transaction in transactions) {
      if (transaction.date.isBefore(startDate) || transaction.date.isAfter(now)) continue;

      int index;
      if (filter == 'month') {
        index = now.difference(transaction.date).inDays;
      } else {
        final monthsDiff = (now.year - transaction.date.year) * 12 + now.month - transaction.date.month;
        index = filter == 'three_months' ? monthsDiff : monthsDiff ~/ 4; // Adjust for year filter
        if (index >= intervals) continue;
      }

      if (transaction.type == 'expense') {
        expenses[index] += transaction.amount;
      } else if (transaction.type == 'income') {
        income[index] += transaction.amount;
      }
    }

    // Calculate savings (income - expenses)
    for (int i = 0; i < intervals; i++) {
      savings[i] = income[i] - expenses[i];
    }

    // Convert to FlSpot for charts
    List<FlSpot> expenseSpots = [];
    List<FlSpot> incomeSpots = [];
    List<FlSpot> savingsSpots = [];

    for (int i = 0; i < intervals; i++) {
      final x = (filter == 'month') ? i.toDouble() : (intervals - 1 - i).toDouble();
      expenseSpots.add(FlSpot(x, expenses[i]));
      incomeSpots.add(FlSpot(x, income[i]));
      savingsSpots.add(FlSpot(x, savings[i]));
    }

    return {
      'expenses': expenseSpots,
      'income': incomeSpots,
      'savings': savingsSpots,
    };
  }
}