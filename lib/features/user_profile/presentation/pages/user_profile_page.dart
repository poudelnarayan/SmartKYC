import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Profile'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const _ProfileHeader(),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Personal Information',
                    items: const [
                      _ProfileItem(
                          label: 'Email', value: 'poudelnarayan434@gmail.com'),
                      _ProfileItem(label: 'Phone', value: '+9779867513539'),
                      _ProfileItem(
                          label: 'Location', value: 'Dhapakhel,Lalitpur'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Documents',
                    items: const [
                      _ProfileItem(
                        label: 'License No.',
                        value: 'DL-123456789',
                      ),
                      _ProfileItem(
                        label: 'Passport No.',
                        value: 'P-987654321',
                      ),
                      _ProfileItem(
                        label: 'ID Card',
                        value: 'ID-456789123',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    context,
                    title: 'Verification Status',
                    items: const [
                      _ProfileItem(
                        label: 'Identity',
                        value: 'Verified',
                        isVerified: true,
                      ),
                      _ProfileItem(
                        label: 'Documents',
                        value: 'Verified',
                        isVerified: true,
                      ),
                      _ProfileItem(
                        label: 'Liveness',
                        value: 'Verified',
                        isVerified: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const Divider(),
          ...items,
        ],
      ),
    ).animate().fadeIn().slideX();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              'NP',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ).animate().scale(),
        const SizedBox(height: 16),
        Text(
          'Narayan Poudel',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ).animate().fadeIn(),
        const SizedBox(height: 8),
        Text(
          'Premium Member',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ).animate().fadeIn(),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isVerified;

  const _ProfileItem({
    required this.label,
    required this.value,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          Row(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (isVerified) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.verified,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
