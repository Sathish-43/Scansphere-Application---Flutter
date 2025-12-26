// lib/features/home/profile_page.dart
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final VoidCallback? onSignOut;

  const ProfilePage({super.key, required this.name, this.onSignOut});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // controllers for editable fields
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final _formKey = GlobalKey<FormState>();

  bool _editing = false;

  @override
  void initState() {
    super.initState();
    // default values — you can load from storage / profile service later
    _emailCtrl = TextEditingController(text: '');
    _phoneCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _enterEdit() {
    setState(() => _editing = true);
  }

  void _cancelEdit() {
    // discard changes: currently will clear to previous saved values (we don't persist here)
    setState(() => _editing = false);
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    // Save to local storage / backend as needed (not implemented here)
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  String _initialLetter() => widget.name.isNotEmpty ? widget.name[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context) {
    // Colors consistent with your app
    final primaryRed = const Color(0xFFe53935);
    //final headerYellow = const Color(0xFFFFC107);

    return SafeArea(
      child: Column(
        children: [
          // Yellow in-body header with Profile title + edit button on right
          Container(
            width: double.infinity,
            color: Colors.amberAccent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                const Spacer(),
                const Expanded(
                  flex: 8,
                  child: Center(
                    child: Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Spacer(),
                // Edit icon at far right (small hit area)
                // IconButton(
                //   tooltip: _editing ? 'Save changes' : 'Edit profile',
                //   icon: Icon(_editing ? Icons.check : Icons.edit, color: Colors.black87),
                //   onPressed: () {
                //     if (_editing) {
                //       _saveProfile();
                //     } else {
                //       _enterEdit();
                //     }
                //   },
                // ),
              ],
            ),
          ),

          // Body content — allow scrolling if small screens
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar + name
                    Center(
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(48),
                            onTap: () {
                              // optional: implement image pick logic later
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Change avatar not implemented')));
                            },
                            child: CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.red.shade50,
                              child: Text(_initialLetter(), style: const TextStyle(fontSize: 36, color: Colors.black87)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(widget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text('Member since: June 2025', style: TextStyle(color: Colors.black54)),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Email / Phone area:
                    // When not editing: show as ListTile-like readonly rows.
                    // When editing: show TextFormField for each field.
                    if (!_editing) ...[
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(_emailCtrl.text.isEmpty ? 'Not set' : _emailCtrl.text),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            setState(() => _editing = true);
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text('Phone'),
                        subtitle: Text(_phoneCtrl.text.isEmpty ? 'Not set' : _phoneCtrl.text),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            setState(() => _editing = true);
                          },
                        ),
                      ),
                    ] else ...[
                      // Editing mode: show fields
                      const Text('Contact details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter your email';
                          final emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                          if (!RegExp(emailPattern).hasMatch(v)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter phone number';
                          final digits = v.replaceAll(RegExp(r'\D'), '');
                          if (digits.length < 7) return 'Enter valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Save & Cancel actions while editing
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                              child: const Text('Save',style: TextStyle(color: Colors.white),),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _cancelEdit,
                              child: const Text('Cancel'),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Other fields you may want later (address, preferences) can go here.

                    const SizedBox(height: 40),

                    // Sign out button aligned bottom. Keep it as full-width.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (widget.onSignOut != null) widget.onSignOut!();
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text('Sign out', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
