import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/snackbar_service.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../auth/models/app_user.dart';
import '../../jobs/state/marketplace_controller.dart';
import '../state/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(marketplaceControllerProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    Future.microtask(_loadProfile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = await ref.read(profileApiProvider).fetchProfile();
      if (!mounted) {
        return;
      }
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber ?? '';
      _addressController.text = user.address ?? '';
    } catch (error) {
      if (mounted) {
        SnackbarService.show(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _saving = true);
    try {
      final user = await ref.read(profileApiProvider).updateProfile(
            name: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
            address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          );
      final controller = ref.read(marketplaceControllerProvider.notifier);
      controller.state = controller.state.copyWith(user: user, clearErrorMessage: true);
      if (mounted) {
        SnackbarService.show(context, 'Profile updated');
      }
    } catch (error) {
      if (mounted) {
        SnackbarService.show(context, error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(marketplaceControllerProvider).user;
    if (_loading) {
      return const Scaffold(body: LoadingOverlay(message: 'Loading profile'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text((user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?'),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: _required),
                  const SizedBox(height: 12),
                  TextFormField(initialValue: user?.email ?? '', enabled: false, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextFormField(initialValue: user?.role.displayName ?? '', enabled: false, decoration: const InputDecoration(labelText: 'Role')),
                  const SizedBox(height: 12),
                  TextFormField(initialValue: user?.createdAt?.toIso8601String() ?? '', enabled: false, decoration: const InputDecoration(labelText: 'Account Created')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
                  const SizedBox(height: 12),
                  TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address'), maxLines: 3),
                  const SizedBox(height: 20),
                  LoadingButton(label: 'Save Changes', isLoading: _saving, onPressed: _save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
}