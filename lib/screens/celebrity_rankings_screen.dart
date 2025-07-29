import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CelebrityRankingsScreen extends StatelessWidget {
  const CelebrityRankingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    // Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.orange, Color(0xFFD6AF0C)],
                      ).createShader(bounds),
                      child: const Text(
                        'Celebrity Rankings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    const Text(
                      'Discover the most influential celebrities ranked by popularity, achievements, and impact.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Navigation Cards
              Expanded(
                child: Column(
                  children: [
                    // Global Leaderboard Card
                    _buildRankingCard(
                      context: context,
                      title: 'Global Leaderboard',
                      description: 'See the current rankings of the most influential celebrities worldwide',
                      icon: Icons.emoji_events,
                      iconColor: Colors.amber,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A1B9A), Color(0xFF4527A0)],
                      ),
                      onTap: () {
                        // Navigate to global leaderboard
                        context.pushNamed('award');
                        print('Navigate to Global Leaderboard');
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Hall of Fame Card
                    _buildRankingCard(
                      context: context,
                      title: 'Hall of Fame',
                      description: 'Legendary celebrities who have made a lasting impact on culture and society',
                      icon: Icons.star_outline,
                      iconColor: Colors.amber,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8D6E63), Color(0xFFD84315)],
                      ),
                      onTap: () {
                        // Navigate to hall of fame
                        context.pushNamed('hallOfFame');
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Rising Stars Card
                    _buildRankingCard(
                      context: context,
                      title: 'Rising Stars',
                      description: 'Up-and-coming celebrities quickly gaining popularity and influence',
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFF00BCD4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                      ),
                      onTap: () {
                        // Navigate to rising stars
                        print('Navigate to Rising Stars');
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Category Rankings Card
                    _buildRankingCard(
                      context: context,
                      title: 'Category Rankings',
                      description: 'Browse celebrities by category: Music, Acting, Sports, and Business',
                      icon: Icons.category,
                      iconColor: Colors.green,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
                      ),
                      onTap: () {
                        // Navigate to category rankings
                        print('Navigate to Category Rankings');
                      },
                    ),
                  ],
                ),
              ),
              
              // Footer Disclaimer
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Rankings updated daily based on social media influence, public appearances, and media coverage.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankingCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation Arrow
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
} 