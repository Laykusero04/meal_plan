import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _username;
  String? _email;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _email = user.email;
        });

        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!mounted) return;
        if (userDoc.exists) {
          setState(() {
            _username = userDoc.data()?['username'] ?? 'User';
            _isLoading = false;
          });
        } else {
          setState(() {
            _username = user.email?.split('@')[0] ?? 'User';
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      backgroundColor: const Color(0xFFE8F8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        title: const Text(
          'Profile',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Main Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Info Section
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2ECC71),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _username?.substring(0, 1).toUpperCase() ?? 'U',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Name and Email
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _username ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (_email != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.email_outlined,
                                            size: 14,
                                            color: Color(0xFF666666),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _email!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Divider
                          Divider(
                            color: Colors.grey[200],
                            height: 1,
                          ),
                          const SizedBox(height: 20),
                          // Current Preferences Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Current Preferences',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  // TODO: Implement edit preferences
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Color(0xFF2ECC71),
                                ),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF2ECC71),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Meal Goal
                          _buildPreferenceRow(
                            label: 'Meal Goal',
                            value: 'Weekly meals',
                          ),
                          const SizedBox(height: 16),
                          // Ingredients
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ingredients',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildIngredientTag('Chicken'),
                                  _buildIngredientTag('Fish'),
                                  _buildIngredientTag('Vegetables'),
                                  _buildIngredientTag('Egg'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Diet Type
                          _buildPreferenceRow(
                            label: 'Diet Type',
                            value: 'None',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Edit Preferences Card
                    _buildActionCard(
                      icon: Icons.settings,
                      iconColor: const Color(0xFF2ECC71),
                      title: 'Edit Preferences',
                      subtitle: 'Change your meal preferences',
                      onTap: () {
                        // TODO: Navigate to edit preferences
                      },
                    ),
                    const SizedBox(height: 12),
                    // Manage Subscription Card
                    _buildActionCard(
                      icon: Icons.card_membership,
                      iconColor: Colors.blue,
                      title: 'Manage Subscription',
                      subtitle: 'Coming soon',
                      onTap: () {
                        // TODO: Navigate to subscription
                      },
                    ),
                    const SizedBox(height: 24),
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(
                          Icons.arrow_forward,
                          size: 18,
                        ),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPreferenceRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientTag(String ingredient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2ECC71).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        ingredient,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2ECC71),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF999999),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
