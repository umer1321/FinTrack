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
  final _currencyFormat = NumberFormat.currency(symbol: 'ر.س ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Financial Analytics',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is TransactionLoaded) {
            final transactions = state.transactions;
            final filteredData = _filterData(transactions, _filter);

            // Calculate summary data
            final totalExpenses = _calculateTotal(filteredData['expenses']!);
            final totalIncome = _calculateTotal(filteredData['income']!);
            final totalSavings = _calculateTotal(filteredData['savings']!);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSummaryCards(totalIncome, totalExpenses, totalSavings),
                  _buildFilterCard(),
                  _buildChartSection(filteredData),
                ],
              ),
            );
          } else if (state is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart_rounded,
                    size: 64,
                    color: Theme.of(context).primaryColor.withOpacity(0.5)
                ),
                const SizedBox(height: 16),
                const Text(
                  'No transactions found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add transactions to see your financial analytics',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Financial Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track your financial journey with detailed analytics',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expenses, double savings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A3C34),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Income',
                  income,
                  Icons.arrow_upward_rounded,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Expenses',
                  expenses,
                  Icons.arrow_downward_rounded,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Savings',
            savings,
            Icons.account_balance_wallet_rounded,
            Colors.blue,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Time Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A3C34),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF7ED),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: _filter,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4CAF50)),
              underline: const SizedBox(),
              borderRadius: BorderRadius.circular(12),
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
              style: const TextStyle(
                color: Color(0xFF1A3C34),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(Map<String, List<FlSpot>> filteredData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Financial Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          _buildChart('Income', filteredData['income']!, Colors.green, _filter),
          _buildDivider(),
          _buildChart('Expenses', filteredData['expenses']!, Colors.red, _filter),
          _buildDivider(),
          _buildChart('Savings', filteredData['savings']!, Colors.blue, _filter),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildChart(String title, List<FlSpot> data, Color color, String filter) {
    // Check if all y-values are 0 (no meaningful data to plot)
    final hasData = data.any((spot) => spot.y != 0);

    if (!hasData) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'No data to display',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Calculate horizontal interval, ensuring it's never 0
    final maxY = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) * 1.2;
    final double horizontalInterval = (maxY / 4) > 0 ? (maxY / 4) : 200;

    // Get the max value for the label
    final maxValue = data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              Text(
                'Max: ${_currencyFormat.format(maxValue)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: horizontalInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  drawVerticalLine: false,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            NumberFormat.compact().format(value),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        // Only show labels for specific points to avoid overcrowding
                        if ((filter == 'month' && value % 5 != 0) ||
                            (filter != 'month' && value % 2 != 0)) {
                          return const SizedBox.shrink();
                        }

                        if (filter == 'month') {
                          final date = DateTime.now().subtract(Duration(days: (30 - value.toInt())));
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              DateFormat('d').format(date),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          );
                        } else if (filter == 'three_months') {
                          final date = DateTime.now().subtract(Duration(days: (90 - value.toInt() * 30)));
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              DateFormat('MMM').format(date),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          );
                        } else {
                          final date = DateTime.now().subtract(Duration(days: (365 - value.toInt() * 30)));
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              DateFormat('MMM').format(date),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
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
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: color,
                        );
                      },
                      checkToShowDot: (spot, barData) {
                        // Only show dots for every 5th point in month view
                        // and for every 1st point in other views
                        if (filter == 'month') {
                          return spot.x % 5 == 0;
                        } else {
                          return spot.x % 1 == 0;
                        }
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.3),
                          color.withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxY > 0 ? maxY : 1000,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    //tooltipBgColor: Colors.blueGrey.shade800,
                   //tooltipBorder: Colors.blueGrey.shade800,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          _currencyFormat.format(touchedSpot.y),
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal(List<FlSpot> data) {
    return data.fold(0, (sum, spot) => sum + spot.y);
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