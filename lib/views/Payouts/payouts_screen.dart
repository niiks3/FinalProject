import 'package:flutter/material.dart';

class PayoutsScreen extends StatefulWidget {
  const PayoutsScreen({super.key});

  @override
  _PayoutsScreenState createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends State<PayoutsScreen> {
  // List to store payout accounts
  List<Map<String, String>> payoutAccounts = [];

  // Controllers for text inputs
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  String? selectedAccountType;
  String? selectedMomoNetwork;

  // Function to handle adding a new account
  void _addAccount() {
    if (_accountNumberController.text.isNotEmpty && selectedAccountType != null) {
      setState(() {
        Map<String, String> newAccount = {
          'accountNumber': _accountNumberController.text,
          'accountType': selectedAccountType!,
        };
        if (selectedAccountType == 'BANK' && _bankNameController.text.isNotEmpty) {
          newAccount['bankName'] = _bankNameController.text;
        } else if (selectedAccountType == 'MOMO' && selectedMomoNetwork != null) {
          newAccount['momoNetwork'] = selectedMomoNetwork!;
        }

        payoutAccounts.add(newAccount);
      });
      _accountNumberController.clear();
      _bankNameController.clear();
      selectedAccountType = null;
      selectedMomoNetwork = null;
      Navigator.pop(context); // Close the dialog
    }
  }

  // Function to delete an account
  void _deleteAccount(int index) {
    setState(() {
      payoutAccounts.removeAt(index);
    });
  }

  // Function to open a dialog for adding a new account
  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Payout Account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Account Number / Mobile Money Number',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedAccountType,
                    items: const [
                      DropdownMenuItem(value: 'MOMO', child: Text('MOMO')),
                      DropdownMenuItem(value: 'BANK', child: Text('BANK')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedAccountType = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Account Type',
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (selectedAccountType == 'BANK')
                    TextField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bank Name',
                      ),
                    ),
                  if (selectedAccountType == 'MOMO')
                    DropdownButtonFormField<String>(
                      value: selectedMomoNetwork,
                      items: const [
                        DropdownMenuItem(value: 'AT', child: Text('AT')),
                        DropdownMenuItem(value: 'MTN', child: Text('MTN')),
                        DropdownMenuItem(value: 'Telecel', child: Text('Telecel')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedMomoNetwork = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Mobile Network',
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _addAccount,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xf95C3F1FF), Color(0xff2575fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                AppBar(
                  title: const Text('Manage Payout Accounts'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: payoutAccounts.length,
                    itemBuilder: (context, index) {
                      final account = payoutAccounts[index];
                      return ListTile(
                        title: Text(account['accountNumber']!),
                        subtitle: Text(account['accountType']! +
                            (account['bankName'] != null ? ' - ${account['bankName']}' : '') +
                            (account['momoNetwork'] != null ? ' - ${account['momoNetwork']}' : '')),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAccount(index),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _showAddAccountDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Account'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'NB: There is a 5% commission on the total ticket sales fee for each event.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
