import 'package:flutter/material.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/presentation/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Menu',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 56,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Account
            _buildSectionHeader('Account'),
            _buildSectionCard(
              children: [
                _buildTile(
                  icon: Icons.person_outline,
                  iconColor: AppColors.primary,
                  title: 'Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.card_membership,
                  iconColor: Colors.blue,
                  title: 'Manage Subscription',
                  onTap: () {},
                ),
              ],
            ),

            // Support
            _buildSectionHeader('Support'),
            _buildSectionCard(
              children: [
                _buildTile(
                  icon: Icons.feedback_outlined,
                  iconColor: Colors.orange,
                  title: 'Send Feedback',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.headset_mic_outlined,
                  iconColor: Colors.teal,
                  title: 'Contact Support',
                  onTap: () {},
                ),
              ],
            ),

            // About
            _buildSectionHeader('About'),
            _buildSectionCard(
              children: [
                _buildTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.indigo,
                  title: 'About',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.purple,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildTile(
                  icon: Icons.description_outlined,
                  iconColor: Colors.brown,
                  title: 'Terms & Conditions',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[200],
      indent: 64,
    );
  }
}
