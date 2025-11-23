import 'package:flutter/material.dart';
import '../models/ai_suggestion.dart';

class AISuggestionChip extends StatelessWidget {
  final AISuggestion suggestion;
  final VoidCallback? onTap;

  const AISuggestionChip({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        _getIconForType(suggestion.type),
        size: 18,
      ),
      label: Text(suggestion.title),
      onPressed: onTap,
      tooltip: suggestion.description,
    );
  }

  IconData _getIconForType(SuggestionType type) {
    switch (type) {
      case SuggestionType.onboarding:
        return Icons.school;
      case SuggestionType.search:
        return Icons.search;
      case SuggestionType.completion:
        return Icons.auto_awesome;
      case SuggestionType.recommendation:
        return Icons.recommend;
      case SuggestionType.errorResolution:
        return Icons.build;
      case SuggestionType.nextAction:
        return Icons.arrow_forward;
    }
  }
}

class AISuggestionCard extends StatelessWidget {
  final AISuggestion suggestion;
  final VoidCallback? onTap;

  const AISuggestionCard({
    super.key,
    required this.suggestion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForType(suggestion.type),
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            suggestion.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (suggestion.confidence > 0.8)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(suggestion.confidence * 100).toInt()}%',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestion.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(SuggestionType type) {
    switch (type) {
      case SuggestionType.onboarding:
        return Icons.school;
      case SuggestionType.search:
        return Icons.search;
      case SuggestionType.completion:
        return Icons.auto_awesome;
      case SuggestionType.recommendation:
        return Icons.recommend;
      case SuggestionType.errorResolution:
        return Icons.build;
      case SuggestionType.nextAction:
        return Icons.arrow_forward;
    }
  }
}
