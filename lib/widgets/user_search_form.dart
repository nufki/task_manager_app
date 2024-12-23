import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class UserSearchModal extends StatefulWidget {
  final Function(String) onUserSelected;
  final String? assignedUser; // Add assignedUser as a parameter

  const UserSearchModal(
      {required this.onUserSelected, this.assignedUser, super.key});

  @override
  _UserSearchModalState createState() => _UserSearchModalState();
}

class _UserSearchModalState extends State<UserSearchModal> {
  String? _selectedUser;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print(widget.assignedUser);
    // Initialize _selectedUser with assignedUser if it's passed
    if (widget.assignedUser != null) {
      _searchController.text = widget.assignedUser!;
      _selectedUser = widget.assignedUser;
    }

    // Listen for changes in the search query
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final query = _searchController.text;
    print('Search query: $query'); // Debugging

    // Trigger search only if length >= 2
    if (query.length >= 2) {
      Provider.of<UserProvider>(context, listen: false).loadUsers(query: query);
    } else if (query.isEmpty || query.length < 2) {
      Provider.of<UserProvider>(context, listen: false)
          .clearUsers(); // Clear users if input length < 2
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Print the users list length whenever the Consumer rebuilds
        print('Users length: ${userProvider.users.length}');

        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height *
              0.5, // Modal height is 50% of the screen height
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField for user search
              TextField(
                controller: _searchController,
                decoration:
                    const InputDecoration(labelText: 'Search username...'),
                autofocus:
                    true, // Ensure the input field is focused when the modal opens
              ),
              const SizedBox(height: 8),
              if (userProvider.loading) const CircularProgressIndicator(),

              // Display users with radio buttons for selection
              Expanded(
                child: ListView.builder(
                  itemCount:
                      userProvider.users.length, // Will update dynamically
                  itemBuilder: (context, index) {
                    final user = userProvider.users[index];
                    return ListTile(
                      title: Text(user),
                      leading: Radio<String>(
                        value: user,
                        groupValue: _selectedUser,
                        onChanged: (value) {
                          setState(() {
                            _selectedUser = value;
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _selectedUser = user;
                        });
                      },
                    );
                  },
                ),
              ),
              if (_selectedUser != null)
                ElevatedButton(
                  onPressed: () {
                    widget.onUserSelected(
                        _selectedUser!); // Notify parent widget of selection
                    Navigator.of(context).pop(); // Close the modal
                  },
                  child: const Text('Select User'),
                ),
            ],
          ),
        );
      },
    );
  }
}
