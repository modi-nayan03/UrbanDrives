import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminUserScreen extends StatefulWidget {

  final VoidCallback? onUsersChanged;  // ADD:  Callback function to update Dashboard

  AdminUserScreen({Key? key, this.onUsersChanged}) : super(key: key);  // ADD onUserChanged constructor
  
  @override
  _AdminUserScreenState createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  int _currentPage = 1; // Initialize current page
  int _usersPerPage = 10; // Users per page
  String _searchQuery = '';
  String _selectedUserType = 'All User';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get(Uri.parse('http://localhost:5000/users-data'));

    if (response.statusCode == 200) {
      setState(() {
        _users = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      print('Failed to load users: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users. Please try again.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

    Future<void> _deleteUser(String userId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this user and all related data? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      final response = await http
          .delete(Uri.parse('http://localhost:5000/delete-user/$userId')); // Make API request here.

      if (response.statusCode == 200) {
        print('User and related data deleted successfully');
        _fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User and related data deleted successfully.')),
        );
      } else {
        print('Failed to delete user: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user. Please try again.')),
        );
      }
    } else {
      print('Deletion cancelled by user.');
    }
  }

  Future<void> _editUser(dynamic user) async {
    final updatedUser = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserDialog(user: user);
      },
    );

    if (updatedUser != null) {
      final response = await http.put(
        Uri.parse('http://localhost:5000/update-user/${user['_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedUser),
      );

      if (response.statusCode == 200) {
        print('User updated successfully');
        _fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User updated successfully.')),
        );
      } else {
        print('Failed to update user: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user. Please try again.')),
        );
      }
    }
  }

  Future<void> _addUser(dynamic newUser) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/add-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(newUser),
    );

    if (response.statusCode == 201) {
      print('User added successfully');
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User added successfully.')),
      );
      _selectUserType('All User');
    } else {
      print('Failed to add user: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user. Please try again.')),
      );
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1; // Reset to first page when search changes
    });
  }

  List<dynamic> getFilteredUsers() {
    List<dynamic> usersToPaginate = List.from(_users);

    // Apply User Type Filter
    if (_selectedUserType == 'Active User') {
      usersToPaginate = usersToPaginate
          .where((user) => user['role'] == 'user')
          .toList();
    } else if (_selectedUserType == 'Host') {
      usersToPaginate = usersToPaginate
          .where((user) => user['role'] == 'host')
          .toList();
    }

    // Apply Search Filter
    if (_searchQuery.isNotEmpty) {
      usersToPaginate = usersToPaginate.where((user) {
        final name = user['userName']?.toLowerCase() ?? '';
        final email = user['email']?.toLowerCase() ?? '';
        final phone = user['phone']?.toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase()) ||
            email.contains(_searchQuery.toLowerCase()) ||
            phone.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply Pagination
    final startIndex = (_currentPage - 1) * _usersPerPage;
    final endIndex = (startIndex + _usersPerPage).clamp(0, usersToPaginate.length);
    return usersToPaginate.sublist(startIndex, endIndex);
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _selectUserType(String userType) {
    setState(() {
      _selectedUserType = userType;
      _currentPage = 1;
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final paginatedUsers = getFilteredUsers();
    final totalPages = ((_getFilteredUserCount()) / _usersPerPage).ceil();
    final totalUsers = _users.length;

    final allUsersCount = _users.length;
    final activeUsersCount =
        _users.where((user) => user['role'] == 'user').length;
    final hostUsersCount = _users.where((user) => user['role'] == 'host').length;

    return Scaffold(
      backgroundColor: Color(0xFFF8F8FF),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(  // Changed to Column to Stack UserMainContent and Pagination
          children: [
            Expanded(
              child: UserMainContent(
                users: paginatedUsers,
                onDelete: _deleteUser,
                onEdit: _editUser,
                onAdd: _addUser,
                currentPage: _currentPage,
                totalPages: totalPages,
                totalUsers: totalUsers,
                allUsersCount: allUsersCount,
                activeUsersCount: activeUsersCount,
                hostUsersCount: hostUsersCount,
                onPageChanged: _goToPage,
                onSearchChanged: _filterUsers,
                searchQuery: _searchQuery,
                selectedUserType: _selectedUserType,
                onUserTypeSelected: _selectUserType,
              ),
            ),
            if (totalPages > 1)
              Container(  // Sticky Pagination Container
                color: Colors.white, // or any other color
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Pagination(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPageChanged: _goToPage,
                ),
              ),
          ],
        ),
    );
  }

   int _getFilteredUserCount() {
    List<dynamic> usersToCount = List.from(_users);

    // Apply User Type Filter
    if (_selectedUserType == 'Active User') {
      usersToCount = usersToCount
          .where((user) => user['role'] == 'user')
          .toList();
    } else if (_selectedUserType == 'Host') {
      usersToCount = usersToCount
          .where((user) => user['role'] == 'host')
          .toList();
    }

    // Apply Search Filter
    if (_searchQuery.isNotEmpty) {
      usersToCount = usersToCount.where((user) {
        final name = user['userName']?.toLowerCase() ?? '';
        final email = user['email']?.toLowerCase() ?? '';
        final phone = user['phone']?.toLowerCase() ?? '';
        return name.contains(_searchQuery.toLowerCase()) ||
            email.contains(_searchQuery.toLowerCase()) ||
            phone.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return usersToCount.length;
  }
}

class UserMainContent extends StatelessWidget {
  final List<dynamic> users;
  final Function(String) onDelete;
  final Function(dynamic) onEdit;
  final Function(dynamic) onAdd;
  final int currentPage;
  final int totalPages;
  final int totalUsers;
  final int allUsersCount;
  final int activeUsersCount;
  final int hostUsersCount;
  final Function(int) onPageChanged;
  final Function(String) onSearchChanged;
  final String searchQuery;
  final String selectedUserType;
  final Function(String) onUserTypeSelected;

  UserMainContent({
    required this.users,
    required this.onDelete,
    required this.onEdit,
    required this.onAdd,
    required this.currentPage,
    required this.totalPages,
    required this.totalUsers,
    required this.allUsersCount,
    required this.activeUsersCount,
    required this.hostUsersCount,
    required this.onPageChanged,
    required this.onSearchChanged,
    required this.searchQuery,
    required this.selectedUserType,
    required this.onUserTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Users',
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  FloatingActionButton(
                    onPressed: () async {
                      final newUser = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddUserDialog();
                        },
                      );

                      if (newUser != null) {
                        onAdd(newUser);
                      }
                    },
                    child: Icon(Icons.add),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => onUserTypeSelected('All User'),
                        child: UserSummaryCard(
                          value: allUsersCount.toString(),
                          percentageChange: '',
                          title: 'All User',
                          isSelected: selectedUserType == 'All User',
                          selectedColor: Color(0xFFA8D5FF),
                          iconData: Icons.group,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: InkWell(
                        onTap: () => onUserTypeSelected('Active User'),
                        child: UserSummaryCard(
                          value: activeUsersCount.toString(),
                          percentageChange: '',
                          title: 'Active User',
                          isSelected: selectedUserType == 'Active User',
                          selectedColor: Color(0xFFA8D5FF),
                          iconData: Icons.person,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: InkWell(
                        onTap: () => onUserTypeSelected('Host'),
                        child: UserSummaryCard(
                          value: hostUsersCount.toString(),
                          percentageChange: '',
                          title: 'Host',
                          isSelected: selectedUserType == 'Host',
                          selectedColor: Color(0xFFA8D5FF),
                          iconData: Icons.manage_accounts,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [],
                        ),
                        SizedBox(height: 10.0),
                        AllCustomersSection(
                          isDesktop: isDesktop,
                          users: users, // Pass paginated users
                          onDelete: onDelete,
                          onEdit: onEdit,
                          onSearchChanged: onSearchChanged,
                          searchQuery: searchQuery,
                          selectedUserType: selectedUserType,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AllCustomersSection extends StatelessWidget {
  final bool isDesktop;
  final List<dynamic> users;
  final Function(String) onDelete;
  final Function(dynamic) onEdit;
  final Function(String) onSearchChanged;
  final String searchQuery;
  final String selectedUserType;

  AllCustomersSection({
    required this.isDesktop,
    required this.users,
    required this.onDelete,
    required this.onEdit,
    required this.onSearchChanged,
    required this.searchQuery,
    required this.selectedUserType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Active Members",
          style: TextStyle(color: Colors.lightGreen),
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: onSearchChanged,
              ),
            ),
            SizedBox(width: 10.0),
          ],
        ),
        SizedBox(height: 20.0),
        if (users.isEmpty && searchQuery.isNotEmpty)
          Center(child: Text('No users found matching "$searchQuery"'))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 3.0,
            ),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return UserCard(
                user: user,
                onDelete: onDelete,
                onEdit: onEdit,
              );
            },
          ),
      ],
    );
  }
}

class UserCard extends StatelessWidget {
  final dynamic user;
  final Function(String) onDelete;
  final Function(dynamic) onEdit;

  UserCard({required this.user, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    String profileImage = user['profileImage'] ?? '';

    if (profileImage.isNotEmpty) {
      if (profileImage.startsWith('http')) {
        imageProvider = NetworkImage(profileImage);
      } else {
        try {
          imageProvider = MemoryImage(base64Decode(profileImage));
        } catch (e) {
          print('Error decoding base64 image: $e');
          imageProvider = AssetImage('assets/default_profile.png');
        }
      }
    } else {
      imageProvider = AssetImage('assets/default_profile.png');
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: imageProvider,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['userName'] ?? 'N/A',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Email: ${user['email'] ?? 'N/A'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Phone: ${user['phone'] ?? 'N/A'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Gender: ${user['gender'] ?? 'N/A'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Role: ${user['role'] ?? 'N/A'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => onEdit(user),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete(user['_id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserSummaryCard extends StatelessWidget {
  final String value;
  final String percentageChange;
  final String title;
  final bool isSelected;
  final Color selectedColor;
  final IconData iconData;

  UserSummaryCard({
    required this.value,
    required this.percentageChange,
    required this.title,
    this.isSelected = false,
    this.selectedColor = const Color(0xFFA8D5FF),
    this.iconData = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? selectedColor : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightGreen[50],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Icon(iconData, size: 30.0, color: Colors.green),
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 14.0,
                        color: isSelected ? Colors.black54 : Colors.black54),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.black87 : Colors.black87),
                  ),
                  Text(percentageChange,
                      style: TextStyle(color: Colors.red[700])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditUserDialog extends StatefulWidget {
  final dynamic user;

  EditUserDialog({required this.user});

  @override
  _EditUserDialogState createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _selectedGender;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _userNameController =
        TextEditingController(text: widget.user['userName'] ?? '');
    _emailController = TextEditingController(text: widget.user['email'] ?? '');
    _phoneController = TextEditingController(text: widget.user['phone'] ?? '');
    _selectedGender = widget.user['gender'];
    _selectedRole = widget.user['role'] ?? 'user';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'User Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Gender'),
              value: _selectedGender,
              items: <String>['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Role'),
              value: _selectedRole,
              items: <String>[
                'user',
                'host',
                'admin',
                'Sub-Admin',
                'Vendor',
                'Sub-Vendor'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedUser = {
              'userName': _userNameController.text,
              'email': _emailController.text,
              'phone': _phoneController.text,
              'gender': _selectedGender,
              'role': _selectedRole,
            };
            Navigator.of(context).pop(updatedUser);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class AddUserDialog extends StatefulWidget {
  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedGender;
  String? _selectedRole = 'user';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add User'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'User Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Gender'),
              value: _selectedGender,
              items: <String>['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Role'),
              value: _selectedRole,
              items: <String>[
                'user',
                'host',
                'admin',
                'Sub-Admin',
                'Vendor',
                'Sub-Vendor'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newUser = {
              'userName': _userNameController.text,
              'email': _emailController.text,
              'phone': _phoneController.text,
              'gender': _selectedGender,
              'role': _selectedRole,
              'password': _passwordController.text,
            };
            Navigator.of(context).pop(newUser);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
       List<int> pagesToShow = [];

        if (totalPages <= 1) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Color(0xFF3F51B5), // set the colour the same way
                            borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                            '1',
                            style: TextStyle(color: Colors.white),
                        ),
                    ),
                ],
            );
        }

    if (totalPages <= 7) {
      // Show all pages if totalPages is 7 or less
      pagesToShow = List.generate(totalPages, (index) => index + 1);
    } else {
      // Start with current page
      pagesToShow.add(currentPage);

      // Add pages before current page, up to 2
      for (int i = 1; i <= 2 && currentPage - i > 0; i++) {
        pagesToShow.insert(0, currentPage - i);
      }

      // Add pages after current page, up to 2
      for (int i = 1; i <= 2 && currentPage + i <= totalPages; i++) {
        pagesToShow.add(currentPage + i);
      }

      // Add first page if not already present
      if (!pagesToShow.contains(1)) {
        if (pagesToShow.length > 0 && pagesToShow[0] != 2) {
          pagesToShow.insert(0, 1);
        }
      }

      // Add last page if not already present
      if (!pagesToShow.contains(totalPages)) {
        if (pagesToShow.length > 0 && pagesToShow.last != totalPages - 1) {
          pagesToShow.add(totalPages);
        }
      }

      // Add ellipsis (...) if there are more pages to show
      if (pagesToShow[0] != 1) {
        pagesToShow.insert(1, -1); // Use -1 to represent ellipsis
      }

      if (pagesToShow.last != totalPages) {
        pagesToShow.insert(pagesToShow.length - 1, -1); // Use -1 to represent ellipsis
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
          disabledColor: Colors.grey,
        ),
        for (int i in pagesToShow)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: i == -1 ? null : () => onPageChanged(i),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: currentPage == i ? Color(0xFF3F51B5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '$i',
                  style: TextStyle(
                      color: currentPage == i ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
           disabledColor: Colors.grey,
        ),
      ],
    );
  }
}


























