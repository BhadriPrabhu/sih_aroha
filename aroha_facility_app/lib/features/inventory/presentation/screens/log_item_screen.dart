// lib/features/inventory/presentation/screens/log_item_screen.dart
import 'package:aroha_facility_app/core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class LogItemScreen extends StatefulWidget {
  const LogItemScreen({super.key});

  @override
  State<LogItemScreen> createState() => _LogItemScreenState();
}

class _LogItemScreenState extends State<LogItemScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  final String _stationId = 'stn-maitri';
  String? _selectedCategory;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  final List<String> _dropdownCategories = [
    'Fuel', 'Food', 'Medical', 'Spares', 
    'Survivals', 'Machineries', 'Scientific', 'Others'
  ];

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
            const SnackBar(content: Text('Item successfully logged!'), backgroundColor: AppColors.statusNominal),
          );
          context.pop(true);
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.statusCritical),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC THEME AWARENESS ---
    final isLight = Theme.of(context).brightness == Brightness.light;
    final primaryText = Theme.of(context).textTheme.titleLarge?.color ?? AppColors.textPrimary;
    final secondaryText = Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final surfaceColor = Theme.of(context).cardTheme.color ?? AppColors.surfaceObsidian;
    final borderColor = Theme.of(context).dividerTheme.color ?? AppColors.cardBorder;

    // Local function to generate theme-aware input decorations
    InputDecoration buildInputDecoration({required String hint, required String label, required IconData icon}) {
      return InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: TextStyle(color: secondaryText.withOpacity(0.5)),
        labelStyle: TextStyle(color: secondaryText, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: secondaryText),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor, width: isLight ? 2 : 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.polarCyan, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.statusCritical, width: 2)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => context.pop(),
        ),
        title: Text("Log Supply Entry", style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.polarCyan))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("STATION CONFIGURATION", style: TextStyle(color: secondaryText, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor, width: isLight ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hub_outlined, color: AppColors.polarCyan, size: 20),
                        const SizedBox(width: 12),
                        Text(_stationId, style: AppTypography.telemetry.copyWith(color: primaryText, fontSize: 16, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.statusNominal.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                          child: const Text("ACTIVE", style: TextStyle(color: AppColors.statusNominal, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text("ITEM DETAILS", style: TextStyle(color: secondaryText, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: primaryText, fontWeight: FontWeight.w600),
                    decoration: buildInputDecoration(hint: "e.g., Oxygen Cylinder", label: "Item Name", icon: Icons.inventory_2_outlined),
                    validator: (value) => value == null || value.isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    dropdownColor: surfaceColor,
                    icon: Icon(Icons.keyboard_arrow_down, color: secondaryText),
                    style: TextStyle(color: primaryText, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: AppTypography.primaryFont),
                    decoration: buildInputDecoration(hint: "Select Category", label: "Category", icon: Icons.category_outlined),
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
                    style: AppTypography.telemetry.copyWith(color: primaryText, fontSize: 16),
                    decoration: buildInputDecoration(hint: "e.g., 10.0", label: "Initial Stock Available", icon: Icons.numbers_rounded),
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Stock quantity is required";
                      if (double.tryParse(value) == null) return "Must be a valid number";
                      return null;
                    },
                  ),
                  const SizedBox(height: 48),

                  // Human Factors: 60px Height constraint for gloved tap target
                  SizedBox(
                    width: double.infinity,
                    height: 60, 
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLight ? Colors.black : AppColors.polarCyan,
                        foregroundColor: isLight ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("LOG ITEM TO DATABASE", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}