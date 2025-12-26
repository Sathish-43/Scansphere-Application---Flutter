// lib/features/auth/registration_page.dart
import 'package:flutter/material.dart';
import '../home/home_page.dart';
import '../admin/admin_page.dart';
import '../events/events_list_page.dart';
// removed: import '../home/bottom_nav_shell.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  String? _SelectedRole; // NOT used but kept intentionally if needed later
  String? _selectedRole; // 'User' or 'Admin'
  String _selectedLocation = 'Salem';

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  static const String adminPassword = 'Admin@123';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String text, {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: duration));
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;

    if (!form.validate()) {
      _showSnack('Please fix errors in the form.');
      return;
    }

    if (_selectedRole == null) {
      _showSnack('Please select a role.');
      return;
    }

    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final name = _nameCtrl.text.trim();
    final role = _selectedRole!;
    final location = _selectedLocation;
    final password = _passwordCtrl.text;

    if (role.toLowerCase() == 'admin') {
      if (password != adminPassword) {
        setState(() => _submitting = false);
        _showSnack('Invalid admin password. Use the admin credentials.');
        return;
      }

      // Navigate to Admin console
      Navigator.of(context).pushReplacementNamed(
        AdminPage.routeName,
        arguments: {'name': name, 'location': location, 'role': role},
      );

      setState(() => _submitting = false);
      return;
    } else {
      // Normal user -> navigate to HomePage (which contains your bottom nav)
      Navigator.of(context).pushReplacementNamed(
        HomePage.routeName,
        arguments: {'name': name, 'location': location, 'role': role},
      );

      setState(() => _submitting = false);
      return;
    }
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Enter your full name';
    if (v.trim().length < 3) return 'Name too short';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter password';
    if (_selectedRole == 'Admin') {
      if (v.length < 6) return 'Admin password must be at least 6 chars';
      return null;
    }
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0), // Add padding around the logo
          child: Image.asset(
            'assets/images/ScanphereLogo.png',
            fit: BoxFit.contain, // Adjust the fit as needed
          ),
        ),
        title: const Text('ScanSphere Registration', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400)),
        backgroundColor: Colors.amberAccent,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(children: [
              const SizedBox(height: 8),
              Text('Create an account', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Full name', hintText: 'e.g., Priya R', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
                validator: _validateName,
              ),
              const SizedBox(height: 12),

              InputDecorator(
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    hint: const Text('Select role'),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'User', child: Text('User')),
                      DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    ],
                    onChanged: (v) => setState(() => _selectedRole = v),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              InputDecorator(
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLocation,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'Salem', child: Text('Salem')),
                      DropdownMenuItem(value: 'Chennai', child: Text('Chennai')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedLocation = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                ),
                validator: _validateConfirm,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting ? const SizedBox.shrink() : const Icon(Icons.login),
                  label: _submitting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Register & Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ),
    );
  }
}
