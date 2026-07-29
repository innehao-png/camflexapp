import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/user_subscription.dart';
import '../../providers/profile_provider.dart';
import '../../services/auth_service.dart';
import '../../services/subscription_service.dart';
import '../../widgets/state_widgets.dart';
import '../favorite_screen.dart';
import '../login_screen.dart';
import '../profile_screen.dart';
import '../subscription/subscription_screen.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  UserSubscription? _userSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        context.read<ProfileProvider>().fetchProfile(),
        SubscriptionService.getCurrentSubscription().then((sub) {
          if (mounted) {
            setState(() => _userSubscription = sub);
          }
        }),
      ]);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        title: const Text("ចាកចេញ (Logout)",
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          "តើអ្នកប្រាកដជាចង់ចាកចេញឬ?\nAre you sure you want to logout?",
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("បោះបង់",
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("ចាកចេញ",
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    // Profile is already up-to-date via ProfileProvider; no extra fetch needed.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          "គណនីរបស់ខ្ញុំ (My Account)",
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            tooltip: 'Edit Profile',
            onPressed: _navigateToEditProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const AppLoading()
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.primary,
              backgroundColor: AppColors.background,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Profile Card — driven by ProfileProvider
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  // VIP Subscription Banner
                  _buildVipBanner(),
                  const SizedBox(height: 24),
                  // Settings section label
                  const Text(
                    "ការកំណត់ (Settings)",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildListTile(
                    Icons.person_outline,
                    "កែប្រែប្រវត្តិ (Edit Profile)",
                    _navigateToEditProfile,
                  ),
                  _buildListTile(
                    Icons.favorite_outline,
                    "រឿងដែលពេញចិត្ត (Favorites)",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FavoriteScreen()),
                    ),
                  ),
                  _buildListTile(
                      Icons.history, "ប្រវត្តិទស្សនា (Watch History)", () {}),
                  _buildListTile(
                      Icons.language, "ភាសា (Language)", () {}),
                  _buildListTile(Icons.lock_outline,
                      "ប្តូរពាក្យសម្ងាត់ (Change Password)", () {}),
                  const SizedBox(height: 16),
                  // Logout Button
                  ElevatedButton.icon(
                    onPressed: _showLogoutDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: AppColors.error,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text("ចាកចេញពីគណនី (Logout)"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final name = profile?.name ?? 'User Account';
        final email = profile?.email ?? '';
        final avatarUrl = profile?.avatarUrl;
        final initials = profile?.initials ?? 'U';
        final isVip = _userSubscription?.isActive == true;

        return GestureDetector(
          onTap: _navigateToEditProfile,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.15),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _initialsWidget(initials, 22),
                          )
                        : _initialsWidget(initials, 22),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVip) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "VIP",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _initialsWidget(String initials, double fontSize) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVipBanner() {
    final isVip = _userSubscription?.isActive == true;
    final expiresAt = _userSubscription?.expiresAt;

    return GestureDetector(
      onTap: () async {
        final updated = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SubscriptionScreen(),
          ),
        );
        if (updated == true) {
          _loadData();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isVip
                ? [const Color(0xFF00B4D8), const Color(0xFF007791)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium,
                color: AppColors.textPrimary, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isVip
                        ? "សមាជិក VIP (Active Subscription)"
                        : "កញ្ចប់ VIP (SASTRA VIP)",
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isVip
                        ? (expiresAt != null
                            ? "ផុតកំណត់ត្រឹម: $expiresAt"
                            : "គម្រោងកំពុងដំណើរការ (Active)")
                        : "មើលរឿងបានមិនកម្រិត • ជាវឥឡូវនេះ",
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: AppColors.cardBg,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
