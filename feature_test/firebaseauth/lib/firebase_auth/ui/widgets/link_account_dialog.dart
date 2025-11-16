import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/auth_constants.dart';

/// Dialog for linking/unlinking authentication providers
class LinkAccountDialog extends StatelessWidget {
  final UserModel user;
  final Function(String providerId) onLink;
  final Function(String providerId) onUnlink;

  const LinkAccountDialog({
    super.key,
    required this.user,
    required this.onLink,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Linked Accounts'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            _buildProviderTile(
              context,
              providerId: AuthConstants.emailProvider,
              name: 'Email/Password',
              icon: Icons.email,
            ),
            _buildProviderTile(
              context,
              providerId: AuthConstants.googleProvider,
              name: 'Google',
              icon: Icons.g_mobiledata,
            ),
            _buildProviderTile(
              context,
              providerId: AuthConstants.appleProvider,
              name: 'Apple',
              icon: Icons.apple,
            ),
            _buildProviderTile(
              context,
              providerId: AuthConstants.facebookProvider,
              name: 'Facebook',
              icon: Icons.facebook,
            ),
            _buildProviderTile(
              context,
              providerId: AuthConstants.phoneProvider,
              name: 'Phone',
              icon: Icons.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildProviderTile(
    BuildContext context, {
    required String providerId,
    required String name,
    required IconData icon,
  }) {
    final isLinked = user.hasProvider(providerId);
    final canUnlink = user.providerIds.length > 1;

    return ListTile(
      leading: Icon(icon, color: isLinked ? Colors.green : Colors.grey),
      title: Text(name),
      subtitle: Text(isLinked ? 'Linked' : 'Not linked'),
      trailing: isLinked
          ? (canUnlink
              ? TextButton(
                  onPressed: () {
                    _showUnlinkConfirmation(context, providerId, name);
                  },
                  child: const Text('Unlink'),
                )
              : const Chip(label: Text('Primary')))
          : ElevatedButton(
              onPressed: () {
                onLink(providerId);
              },
              child: const Text('Link'),
            ),
    );
  }

  void _showUnlinkConfirmation(
    BuildContext context,
    String providerId,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Account'),
        content: Text('Are you sure you want to unlink $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close confirmation
              onUnlink(providerId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }
}
