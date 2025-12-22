import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_navigation.dart';

class SuggestionsScreen extends StatelessWidget {
  const SuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final loc = appState.loc;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      loc.savingSuggestions,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        Text(
                          loc.deviceBasedSuggestions,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 24),

                        // Öneri listesi
                        ...appState.suggestions.asMap().entries.map((entry) {
                          final index = entry.key;
                          final suggestion = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildSuggestionCard(
                              context,
                              suggestion,
                              index,
                              appState,
                            ),
                          );
                        }),

                        const SizedBox(
                            height: 100), // Bottom navigation için boşluk
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const CustomBottomNavigation(),
        );
      },
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context,
    SavingSuggestion suggestion,
    int index,
    AppState appState,
  ) {
    final loc = appState.loc;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: suggestion.isApplied
            ? AppTheme.primaryColor.withOpacity( 0.03)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: suggestion.isApplied
              ? AppTheme.primaryColor.withOpacity( 0.3)
              : Colors.grey[200]!,
          width: suggestion.isApplied ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: suggestion.isApplied
                ? AppTheme.primaryColor.withOpacity( 0.1)
                : Colors.black.withOpacity( 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cihaz ikonu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              suggestion.icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Öneri içeriği
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestion.deviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  suggestion.suggestion,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(text: '${loc.estimatedSaving}: '),
                      TextSpan(
                        text:
                            '₺${suggestion.monthlySaving.toStringAsFixed(0)}${loc.perMonth}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Durum butonu
          _buildActionButton(context, suggestion, index, appState),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, SavingSuggestion suggestion,
      int index, AppState appState) {
    final loc = appState.loc;

    return GestureDetector(
      onTap: () {
        appState.applySuggestion(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              suggestion.isApplied
                  ? '${suggestion.deviceName} ${loc.suggestionRemoved}'
                  : '${suggestion.deviceName} ${loc.suggestionApplied}',
            ),
            backgroundColor:
                suggestion.isApplied ? Colors.orange : AppTheme.primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: suggestion.isApplied
              ? AppTheme.primaryColor.withOpacity( 0.1)
              : Colors.white,
          border: Border.all(
            color: suggestion.isApplied
                ? AppTheme.primaryColor
                : Colors.grey[400]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              suggestion.isApplied
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: suggestion.isApplied
                  ? AppTheme.primaryColor
                  : Colors.grey[500],
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              suggestion.isApplied ? loc.applied : loc.apply,
              style: TextStyle(
                color: suggestion.isApplied
                    ? AppTheme.primaryColor
                    : Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
