import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintrack/core/models/transaction_model.dart';

import '../../../auth/presentation/widgets/auth_button.dart';
import '../../../auth/presentation/widgets/auth_text_field.dart';

class TransactionForm extends StatefulWidget {
  final Transaction? transaction;
  final Function(Map<String, dynamic>) onSubmit;

  const TransactionForm({
    super.key,
    this.transaction,
    required this.onSubmit,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String _type = 'expense';
  String _category = 'Food';
  DateTime _date = DateTime.now();

  final List<String> _categories = [
    'Food',
    'Rent',
    'Entertainment',
    'Salary',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.transaction?.amount.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.transaction?.description ?? '');
    if (widget.transaction != null) {
      _type = widget.transaction!.type;
      _category = widget.transaction!.category;
      _date = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthTextField(
              controller: _amountController,
              label: 'Amount (SAR)',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Amount (SAR)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                prefixText: 'ر.س ',
                prefixStyle: const TextStyle(
                  color: Color(0xFF1A3C34),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              items: ['income', 'expense']
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type.capitalize()),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _type = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              items: _categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Date: ${DateFormat.yMMMd().format(_date)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _date = selectedDate;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            AuthButton(
              text: widget.transaction == null ? 'Add' : 'Update',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSubmit({
                    'amount': _amountController.text,
                    'type': _type,
                    'category': _category,
                    'date': _date,
                    'description': _descriptionController.text,
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}