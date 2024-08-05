import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomerFormPage extends StatefulWidget {
  @override
  _CustomerFormPageState createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  int _riskLevel = 1;
  List<String> _selectedDomains = [];

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
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF131314),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We want to know more about you',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
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
              SizedBox(height: 20),
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
                      color: isSelected ? Color.fromRGBO(182, 109, 164, 1) : null,
                      child: ListTile(
                        title: Text(item, style: TextStyle(color: Colors.white)),
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
                dropdownButtonProps: DropdownButtonProps(
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
