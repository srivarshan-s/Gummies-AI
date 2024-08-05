import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';

class CustomerFormPage extends StatefulWidget {
  @override
  _CustomerFormPageState createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  int _riskLevel = 1;
  List<String> _selectedDomains = [];
  List<String> _selectedCompanies = [];

  TextEditingController _typeAheadController = TextEditingController();

  Future<List<Suggestion>> _fetchCompanies(String pattern) async {
    if (pattern == null || pattern.isEmpty) {
      print('Filter is empty'); // Debug statement
      return [];
    }

    print('Filter value: $pattern'); // Debug statement
    final url =
        'http://10.0.2.2:5000/autocomplete?query=$pattern'; // Use 10.0.2.2 for Android emulator
    print('Fetching companies with URL: $url'); // Debug statement
    final response = await http.get(Uri.parse(url));

    print('HTTP status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['result'];
      print('Parsed data: $data');
      return List<Suggestion>.from(
          data.map((item) => Suggestion.fromJson(item)));
    } else {
      print('Error fetching companies: ${response.body}');
      throw Exception('Failed to fetch search results: ${response.body}');
    }
  }

  final List<String> _businessDomains = [
    'Accounting and Finance',
    'Education and Training',
    'Information Technology and Services',
    'Sales and Marketing',
    'Healthcare and Medical Services',
    'Manufacturing and Production',
    'Retail and Consumer Goods',
    'Hospitality and Tourism',
    'Transportation and Logistics',
    'Real Estate and Property Management',
    'Legal Services',
    'Human Resources and Recruitment',
    'Media and Entertainment',
    'Telecommunications',
    'Construction and Engineering',
    'Energy and Utilities',
    'Agriculture and Farming',
    'Consulting and Professional Services',
    'Nonprofit and Social Services',
    'Banking and Financial Services',
    'Insurance',
    'Public Relations and Communications',
    'Research and Development',
    'Government and Public Administration',
    'Sports and Recreation',
  ];

  final List<String> _companies = [
    'Google',
    'Apple',
    'Microsoft',
    'Amazon',
    'Facebook',
    'Tesla',
    'IBM',
    'Intel',
    'Samsung',
    'Adobe',
    'Netflix',
    'Salesforce',
    'Oracle',
    'Twitter',
    'LinkedIn',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Survey'),
        actions: [
          TextButton(
            onPressed: () {
              // Save functionality
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF131314),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'We want to know more about you',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              const Text(
                'How much of a risk taker are you?',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Slider(
                value: _riskLevel.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: _riskLevel.toString(),
                activeColor: Color.fromRGBO(182, 109, 164, 1),
                inactiveColor: Colors.white60,
                onChanged: (value) {
                  setState(() {
                    _riskLevel = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>.multiSelection(
                items: _businessDomains,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Which business domains are you interested in?',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF1e1f20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                  ),
                ),
                popupProps: PopupPropsMultiSelection.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF1e1f20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                    ),
                  ),
                  itemBuilder: (context, item, isSelected) {
                    return Container(
                      color:
                          isSelected ? Color.fromRGBO(182, 109, 164, 1) : null,
                      child: ListTile(
                        title:
                            Text(item, style: TextStyle(color: Colors.white)),
                        selected: isSelected,
                      ),
                    );
                  },
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedDomains = value;
                  });
                },
                selectedItems: _selectedDomains,
                dropdownButtonProps: const DropdownButtonProps(
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>.multiSelection(
                items: _companies,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: 'Companies you are interested in',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xFF1e1f20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white60),
                    ),
                  ),
                ),
                popupProps: PopupPropsMultiSelection.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF1e1f20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white60),
                      ),
                    ),
                  ),
                  itemBuilder: (context, item, isSelected) {
                    return Container(
                      color:
                          isSelected ? Color.fromRGBO(182, 109, 164, 1) : null,
                      child: ListTile(
                        title:
                            Text(item, style: TextStyle(color: Colors.white)),
                        selected: isSelected,
                      ),
                    );
                  },
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedCompanies = value;
                  });
                },
                selectedItems: _selectedCompanies,
                dropdownButtonProps: const DropdownButtonProps(
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
              Card(
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF131314),
                  ),
                  child: TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: this._typeAheadController,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.edit),
                        labelText: 'Companies you are interested in',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Color(0xFF1e1f20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white60),
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) {
                      return _fetchCompanies(pattern);
                    },
                    itemBuilder: (context, Suggestion suggestion) {
                      return ListTile(
                        title: Text(suggestion.description),
                        subtitle: Text(suggestion.symbol),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (Suggestion suggestion) {
                      this._typeAheadController.text = suggestion.description;
                      setState(() {
                        _selectedCompanies.add(suggestion.description);
                      });
                    },
                    onSaved: (value) {
                      // Save functionality
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Watchlist',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Wrap(
                spacing: 8.0,
                children: _selectedCompanies
                    .map((company) => Chip(
                          label: Text(company),
                          deleteIcon: Icon(Icons.close),
                          onDeleted: () {
                            setState(() {
                              _selectedCompanies.remove(company);
                            });
                          },
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Suggestion {
  final String description;
  final String symbol;

  Suggestion({required this.description, required this.symbol});

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      description: json['description'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
    );
  }
}
