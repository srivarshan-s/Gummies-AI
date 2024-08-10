import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  String _investmentExperience = '';
  String _investmentGoal = '';
  String _investmentHorizon = '';
  String _investmentType = '';
  String _financialSituation = '';

  String _selectedDomain = '';
  String _investmentStrategy = '';
  String _dividendPreference = '';
  String _geographicalPreference = '';
  String _sustainabilityPreference = '';
  String _tradingFrequency = '';

  TextEditingController _typeAheadController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  Future<List<Suggestion>> _fetchCompanies(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }

    final url = 'http://10.0.2.2:5000/autocomplete?query=$pattern';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['result'];
      return List<Suggestion>.from(
          data.map((item) => Suggestion.fromJson(item)));
    } else {
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

  final List<String> _investmentExperiences = [
    'Less than 1 year',
    '1-3 years',
    '3-5 years',
    'More than 5 years'
  ];

  final List<String> _investmentGoals = [
    'Short-term gains',
    'Long-term growth',
    'Income through dividends',
    'Preservation of capital'
  ];

  final List<String> _investmentHorizons = [
    'Less than 1 year',
    '1-3 years',
    '3-5 years',
    'More than 5 years'
  ];

  final List<String> _investmentTypes = [
    'Stocks',
    'Bonds',
    'Mutual Funds',
    'ETFs',
    'Cryptocurrencies'
  ];

  final List<String> _financialSituations = [
    'Just starting out',
    'Steady income',
    'Saving for a big purchase',
    'Preparing for retirement'
  ];

  final List<String> _investmentStrategies = [
    'Conservative (Low risk, low return)',
    'Moderate (Balanced risk and return)',
    'Aggressive (High risk, high return)'
  ];

  final List<String> _dividendPreferences = [
    'Yes',
    'No',
    'No preference'
  ];

  final List<String> _geographicalRegions = [
    'North America',
    'Europe',
    'Asia',
    'Emerging Markets',
    'No preference'
  ];

  final List<String> _sustainabilityPreferences = [
    'Very important',
    'Somewhat important',
    'Not important'
  ];

  final List<String> _tradingFrequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Rarely'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        // padding: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 80),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: _currentStep == 0 ? _buildFirstPage() : _buildSecondPage(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child : Image.asset('assets/cust_form1.png', height: 300),
        ),
        SizedBox(height: 5),
        Center(
          child: const Text(
            'We want to know more about you',
            style: TextStyle(
              color: Color.fromRGBO(182, 109, 164, 1),
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'How much of a risk taker are you?',
          style: TextStyle(color: Colors.white, fontSize: 16),
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
        _buildDropdownSingleSelection(
          items: _investmentExperiences,
          label: 'How many years of investment experience do you have?',
          value: _investmentExperience,
          onChanged: (value) {
            setState(() {
              _investmentExperience = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildDropdownSingleSelection(
          items: _investmentGoals,
          label: 'What are your primary investment goals?',
          value: _investmentGoal,
          onChanged: (value) {
            setState(() {
              _investmentGoal = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildDropdownSingleSelection(
          items: _investmentHorizons,
          label: 'What is your investment time horizon?',
          value: _investmentHorizon,
          onChanged: (value) {
            setState(() {
              _investmentHorizon = value!;
            });
          },
        ),

        const SizedBox(height: 20),
        _buildDropdownSingleSelection(
          items: _financialSituations,
          label: 'What is your current financial situation?',
          value: _financialSituation,
          onChanged: (value) {
            setState(() {
              _financialSituation = value!;
            });
          },
        ),

        const SizedBox(height: 20),
        _buildDropdownSingleSelection(
          items: _investmentStrategies,
          label: 'Which best describes your investment strategy?',
          value: _investmentStrategy,
          onChanged: (value) {
            setState(() {
              _investmentStrategy = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              backgroundColor: Color(0xFF1e1f20),
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child : Image.asset('assets/cust_form2.png', height: 300),
        ),
        const SizedBox(height: 5),
        _buildDropdownSingleSelection(
          items: _dividendPreferences,
          label: 'Do you prefer companies that pay dividends?',
          value: _dividendPreference,
          onChanged: (value) {
            setState(() {
              _dividendPreference = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildDropdownSingleSelection(
          items: _sustainabilityPreferences,
          label: 'How important is investing in sustainable companies to you?',
          value: _sustainabilityPreference,
          onChanged: (value) {
            setState(() {
              _sustainabilityPreference = value!;
            });
          },
        ),
        const SizedBox(height: 20),
        _buildDropdownSingleSelection(
          items: _tradingFrequencies,
          label: 'How often do you trade?',
          value: _tradingFrequency,
          onChanged: (value) {
            setState(() {
              _tradingFrequency = value!;
            });
          },
        ),

        const SizedBox(height: 20),
        _buildDropdownMultiSelection(
          items: _businessDomains,
          label: 'Which business domains are you interested in?',
          selectedItems: _selectedDomains,
          onChanged: (value) {
            setState(() {
              _selectedDomains = value;
            });
          },
        ),

        const SizedBox(height: 20),
        _buildDropdownMultiSelection(
          items: _companies,
          label: 'Companies you are interested in',
          selectedItems: _selectedCompanies,
          onChanged: (value) {
            setState(() {
              _selectedCompanies = value;
            });
          },
          showSearchBox: true,
        ),
        const SizedBox(height: 20),
        const Text(
          'Watchlist',
          style: TextStyle(
              color: Color.fromRGBO(182, 109, 164, 1),
              fontSize: 24,
              fontWeight: FontWeight.bold
          ),
        ),
        Wrap(
          spacing: 8.0,
          children: _selectedCompanies
              .map((company) => Chip(
            label:
            Text(company, style: TextStyle(color: Colors.white)),
            deleteIcon: Icon(Icons.close, color: Colors.white),
            backgroundColor: Color(0xFF1e1f20),
            onDeleted: () {
              setState(() {
                _selectedCompanies.remove(company);
              });
            },
          ))
              .toList(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Color(0xFF1e1f20),
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Back'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/news');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                backgroundColor: Color(0xFF1e1f20),
                foregroundColor: Colors.white,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdownMultiSelection({
    required List<String> items,
    required String label,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onChanged,
    bool showSearchBox = false,
  }) {
    return DropdownSearch<String>.multiSelection(
      items: items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Color(0xFF1e1f20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color.fromRGBO(182, 109, 164, 1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white60),
          ),
        ),
      ),
      popupProps: PopupPropsMultiSelection.menu(
        showSearchBox: showSearchBox,
        searchFieldProps: TextFieldProps(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFF1e1f20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Color.fromRGBO(182, 109, 164, 1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.white60),
            ),
          ),
        ),
        menuProps: MenuProps(
          backgroundColor: Color(0xFF131314),
        ),
        itemBuilder: (context, item, isSelected) {
          return Container(
            color: isSelected ? Color.fromRGBO(182, 109, 164, 1) : null,
            child: ListTile(
              title: Text(item, style: TextStyle(color: Colors.white)),
              selected: isSelected,
            ),
          );
        },
      ),
      onChanged: onChanged,
      selectedItems: selectedItems,
      dropdownButtonProps: const DropdownButtonProps(
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
      ),
    );
  }

  Widget _buildDropdownSingleSelection({
    required List<String> items,
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownSearch<String>(
      items: items,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: Colors.white,
          fontSize: 18),
          filled: true,
          fillColor: Color(0xFF1e1f20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color.fromRGBO(182, 109, 164, 1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.white60),
          ),
        ),
      ),
      popupProps: PopupProps.menu(
        menuProps: MenuProps(
          backgroundColor: Color(0xFF131314),
        ),
        itemBuilder: (context, item, isSelected) {
          return Container(
            color: isSelected ? Color.fromRGBO(182, 109, 164, 1) : null,
            child: ListTile(
              title: Text(item, style: TextStyle(color: Colors.white)),
              selected: isSelected,
            ),
          );
        },
      ),
      onChanged: onChanged,
      selectedItem: value,
      dropdownButtonProps: const DropdownButtonProps(
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
      ),
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem ?? '',
          style: TextStyle(color: Colors.white),
        );
      },
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
