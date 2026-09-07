// lib/features/inventory/presentation/screens/log_item_screen.dart
import 'package:aroha_facility_app/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';

class LogItemScreen extends StatefulWidget {
  const LogItemScreen({super.key});

  @override
  State<LogItemScreen> createState() => _LogItemScreenState();
}

class _LogItemScreenState extends State<LogItemScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // API Fields
  final String _stationId = 'stn-maitri';
  String? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  final List<String> _dropdownCategories = [
    'Fuel', 'Food', 'Medical', 'Spares', 
    'Survivals', 'Machineries', 'Scientific', 'Others'
  ];

  final String apiUrl = 'http://10.40.32.155:8080/api/v1/stocks'; 

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final payload = {
        "station_id": _stationId,
        "category": _selectedCategory,
        "name": _nameController.text,
        "stock_available": double.tryParse(_stockController.text) ?? 0.0,
      };

      try {
        final dio = Dio();
        final response = await dio.post(ApiConstants.getStocks, data: payload);
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item successfully logged!'), backgroundColor: AppColors.accentMint),
          );
          context.pop(true); // Return 'true' to signal the dashboard to refresh
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.accentRed),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Log Supply Entry", style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.accentMint))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Station Configuration", style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hub_outlined, color: AppColors.accentCyan, size: 20),
                        const SizedBox(width: 12),
                        Text(_stationId, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        const Text("Active Default", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text("Item Details", style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(hint: "e.g., Oxygen Cylinder", label: "Item Name", icon: Icons.inventory_2_outlined),
                    validator: (value) => value == null || value.isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: AppColors.surfaceElevated,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: _buildInputDecoration(hint: "Select Category", label: "Category", icon: Icons.category_outlined),
                    items: _dropdownCategories.map((String category) {
                      return DropdownMenuItem<String>(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    validator: (value) => value == null ? "Category is required" : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _stockController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _buildInputDecoration(hint: "e.g., 10.0", label: "Initial Stock Available", icon: Icons.numbers_rounded),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Stock quantity is required";
                      if (double.tryParse(value) == null) return "Must be a valid number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: AppColors.accentMint,
                        foregroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text("Log Item to Database", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required String label, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentMint, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5)),
    );
  }
}