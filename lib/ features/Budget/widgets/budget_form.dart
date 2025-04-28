import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintrack/core/models/budget_model.dart';

class BudgetForm extends StatefulWidget {
  final Budget? budget;
  final Function(Map<String, dynamic>) onSubmit;

  const BudgetForm({super.key, this.budget, required this.onSubmit});

  @override
  State<BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  String _month = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _categoryController.text = widget.budget!.category;
      _amountController.text = widget.budget!.amount.toString();
      _month = widget.budget!.month;
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A3C34),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _month = DateFormat('yyyy-MM').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a category';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount (ر.س)'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null || double.parse(value) <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          ListTile(
            title: Text('Month: $_month'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectMonth(context),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit({
                  'category': _categoryController.text,
                  'amount': _amountController.text,
                  'month': _month,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: Text(widget.budget == null ? 'Add Budget' : 'Update Budget'),
          ),
        ],
      ),
    );
  }
}