// DEPRECATED: The old HomeScreen is no longer used in the identifier app template.
// All code below is commented out for reference.
/*
// lib/features/home/view/home_screen.dart
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ai_plant_identifier/core/theme/app_theme.dart';
import 'package:ai_plant_identifier/core/widgets/app_card.dart';
import 'package:ai_plant_identifier/core/widgets/category_card.dart';
import 'package:ai_plant_identifier/core/widgets/list_item_card.dart';
import 'package:ai_plant_identifier/core/widgets/primary_button.dart';
import 'package:ai_plant_identifier/core/widgets/secondary_button.dart';
import 'package:ai_plant_identifier/core/widgets/section_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2A2A36) : const Color(0xFFF5F5F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(HugeIcons.strokeRoundedSettings01, size: 22),
              ),
              onPressed: () {
                // Navigate to settings screen
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Featured Section - Daily Calm Card
                AppCard(
                  useGradient: false,
                  useBorder: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SECTION LABEL',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Featured Card',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is a featured card component with a clean design and rounded corners.',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          PrimaryButton(
                            onPressed: () {},
                            text: 'Action',
                            isFullWidth: false,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Subtitle',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Categories Section
                SectionHeader(
                  title: 'Category Cards',
                  actionText: 'See All',
                  onActionPressed: () {},
                ),
                const SizedBox(height: 16),

                // Category Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryCard(
                      title: 'Type 1',
                      icon: Iconsax.sun_1,
                      backgroundColor: AppTheme.focusColor,
                      onTap: () {},
                    ),
                    CategoryCard(
                      title: 'Type 2',
                      icon: Iconsax.lock_1,
                      backgroundColor: AppTheme.sleepColor,
                      onTap: () {},
                    ),
                    CategoryCard(
                      title: 'Type 3',
                      icon: Iconsax.emoji_happy,
                      backgroundColor: AppTheme.stressColor,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Recent Sessions Section
                SectionHeader(
                  title: 'List Item Cards',
                ),
                const SizedBox(height: 16),

                // List Item Card
                ListItemCard(
                  title: 'List Item Title',
                  subtitle: 'Subtitle with additional information',
                  icon: Iconsax.moon,
                  iconBackgroundColor: AppTheme.sleepColor,
                  onTap: () {},
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.play_circle),
                  ),
                ),
                const SizedBox(height: 24),

                // Button Components
                SectionHeader(
                  title: 'Button Components',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        onPressed: () {},
                        text: 'Primary',
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        onPressed: () {},
                        text: 'Secondary',
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
