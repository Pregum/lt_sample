import 'package:flutter/material.dart';
import '../models/user_context.dart';
import '../models/ai_suggestion.dart';
import '../services/ai_service.dart';
import '../services/personalization_service.dart';
import '../widgets/ai_chat_widget.dart';
import '../widgets/ai_suggestion_chip.dart';

class AIDemoScreen extends StatefulWidget {
  const AIDemoScreen({super.key});

  @override
  State<AIDemoScreen> createState() => _AIDemoScreenState();
}

class _AIDemoScreenState extends State<AIDemoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserContext _userContext = PersonalizationService.getCurrentContext();
  List<AIChatMessage> _chatMessages = [];
  bool _isTyping = false;
  bool _aiEnabled = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeChat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    setState(() {
      _chatMessages = [
        AIChatMessage.assistant(
          'こんにちは！AI アシスタントです。何でもお気軽にお尋ねください。',
        ),
      ];
    });
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _chatMessages.add(AIChatMessage.user(message));
      _isTyping = true;
    });

    final response = await AIService.generateChatResponse(message, _userContext);

    setState(() {
      _isTyping = false;
      _chatMessages.add(AIChatMessage.assistant(response));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Integration Demo'),
        actions: [
          Switch(
            value: _aiEnabled,
            onChanged: (value) {
              setState(() {
                _aiEnabled = value;
              });
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _userContext = PersonalizationService.generateDemoContext(value);
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'beginner',
                child: Text('Beginner User'),
              ),
              const PopupMenuItem(
                value: 'intermediate',
                child: Text('Intermediate User'),
              ),
              const PopupMenuItem(
                value: 'advanced',
                child: Text('Advanced User'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Blank'),
            Tab(text: 'Loading'),
            Tab(text: 'Error'),
            Tab(text: 'Partial'),
            Tab(text: 'Ideal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBlankStateTab(),
          _buildLoadingStateTab(),
          _buildErrorStateTab(),
          _buildPartialStateTab(),
          _buildIdealStateTab(),
        ],
      ),
    );
  }

  Widget _buildBlankStateTab() {
    return FutureBuilder<List<AISuggestion>>(
      future: AIService.generateOnboardingSuggestions(_userContext),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final suggestions = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Blank State with AI',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'AI がユーザーのコンテキストに基づいて、パーソナライズされた初期体験を提供します。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ユーザーコンテキスト',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('レベル: ${_userContext.experienceLevel}'),
                    Text(
                        '初回ユーザー: ${_userContext.isFirstTimeUser ? "はい" : "いいえ"}'),
                    if (_userContext.interests.isNotEmpty)
                      Text('興味: ${_userContext.interests.join(", ")}'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AI による提案',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (suggestions.isEmpty)
                const Text('このユーザーに対する提案はありません')
              else
                ...suggestions.map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AISuggestionCard(
                      suggestion: suggestion,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('「${suggestion.title}」をタップしました'),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingStateTab() {
    return FutureBuilder<List<String>>(
      future: AIService.predictNextActions(_userContext),
      builder: (context, snapshot) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loading State with AI',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'AI が次のアクションを予測し、プリフェッチやスマートなメッセージを表示します。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      FutureBuilder<String>(
                        future: AIService.generateLoadingMessage(_userContext, 50),
                        builder: (context, messageSnapshot) {
                          return Text(
                            messageSnapshot.data ?? 'データを読み込んでいます...',
                            style: Theme.of(context).textTheme.titleMedium,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '予測された次のアクション',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (snapshot.hasData)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: snapshot.data!.map((action) {
                    return Chip(
                      avatar: const Icon(Icons.auto_awesome, size: 16),
                      label: Text(action),
                    );
                  }).toList(),
                )
              else
                const CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorStateTab() {
    return FutureBuilder<String>(
      future: AIService.generateContextualErrorMessage('network', _userContext),
      builder: (context, messageSnapshot) {
        return FutureBuilder<List<String>>(
          future: AIService.suggestErrorResolutions('network'),
          builder: (context, resolutionsSnapshot) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error State with AI',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI がコンテキストを理解して、具体的な解決策を提示します。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color:
                                    Theme.of(context).colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ネットワークエラー',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            messageSnapshot.data ?? '読み込み中...',
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'AI による解決策',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (resolutionsSnapshot.hasData)
                    ...resolutionsSnapshot.data!.asMap().entries.map((entry) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${entry.key + 1}'),
                        ),
                        title: Text(entry.value),
                        trailing: const Icon(Icons.arrow_forward),
                      );
                    })
                  else
                    const CircularProgressIndicator(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPartialStateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Partial State with AI',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'AI が入力を補完し、不足している情報を提案します。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: '検索',
              hintText: 'キーワードを入力...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) async {
              if (value.isNotEmpty) {
                final suggestions =
                    await AIService.generateAutoCompletions(value, _userContext);
                // 実際にはここでサジェストを表示
                print('Suggestions: $suggestions');
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            'AI による自動補完候補',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Technology', 'Fashion', 'Books', 'Sports'].map((tag) {
              return ActionChip(
                avatar: const Icon(Icons.auto_awesome, size: 16),
                label: Text(tag),
                onPressed: () {},
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIdealStateTab() {
    return Column(
      children: [
        Expanded(
          child: AIChatWidget(
            messages: _chatMessages,
            onSendMessage: _sendChatMessage,
            isTyping: _isTyping,
          ),
        ),
      ],
    );
  }
}
