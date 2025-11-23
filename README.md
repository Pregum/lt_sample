# The Five UI States - Flutter Demo App

FlutterでThe Five UI Statesパターンを実装したデモアプリケーションです。すべての画面が5つの異なる状態を持つべきという考え方を示しています。

## The Five UI Statesとは

Scott Hurffが提唱した、すべてのUI画面が持つべき5つの状態パターンです：

1. **Blank State (空の状態)** - データがない初回起動時や、データを全削除した時の状態
2. **Loading State (読み込み中)** - データ取得中やネットワーク通信中の状態
3. **Error State (エラー状態)** - エラーが発生した時の状態
4. **Partial State (部分的な状態)** - データが少ない、または未完成の状態
5. **Ideal State (理想的な状態)** - すべてのデータが揃った、理想的な状態

参考: [The Five UI States](https://www.scotthurff.com/posts/why-your-user-interface-is-awkward-youre-ignoring-the-ui-stack/)

## プロジェクト構成

```
lib/
├── models/                     # データモデル
│   ├── product.dart           # 商品モデル
│   ├── user_profile.dart      # ユーザープロフィールモデル
│   └── ui_state.dart          # UI状態管理用のEnum
│
├── providers/                  # 状態管理 (Riverpod)
│   ├── product_provider.dart  # 商品リストの状態管理
│   ├── user_profile_provider.dart  # プロフィールの状態管理
│   └── search_provider.dart   # 検索の状態管理
│
├── services/                   # サービス層
│   └── mock_data_service.dart # モックデータ生成サービス
│
├── widgets/                    # 共通ウィジェット
│   ├── state_wrapper.dart     # 5つの状態を管理するラッパー
│   ├── empty_state_widget.dart    # 空の状態用ウィジェット
│   ├── loading_state_widget.dart  # ローディング状態用ウィジェット
│   ├── error_state_widget.dart    # エラー状態用ウィジェット
│   └── partial_state_widget.dart  # 部分的な状態用ウィジェット
│
├── screens/                    # 画面
│   ├── product_list_screen.dart      # 商品リスト画面
│   ├── user_profile_screen.dart      # ユーザープロフィール画面
│   ├── search_screen.dart            # 検索画面
│   └── ui_state_catalog_screen.dart  # UIステートカタログ画面
│
└── main.dart                   # メインアプリ
```

## 画面ごとの説明

### 1. ホーム画面 (HomeScreen)

**場所**: `lib/main.dart`

The Five UI Statesの概要を説明する画面です。

**主な機能**:
- 5つのUI状態の説明カード
- 使い方ガイド
- UIステートカタログへのアクセスボタン

**実装のポイント**:
```dart
// Material Design 3のグラデーションカードを使用
Card(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryContainer, secondaryContainer],
      ),
    ),
  ),
)
```

---

### 2. 商品リスト画面 (ProductListScreen)

**場所**: `lib/screens/product_list_screen.dart`

商品リストを表示する画面で、5つすべての状態を実装しています。

#### Blank State
- アイコン: `Icons.inbox_outlined`
- メッセージ: "No products available"
- アクション: "Add Products"ボタンで商品を読み込み

#### Loading State
- Shimmerエフェクトによるスケルトンスクリーン
- リストアイテムの形状を模したローディング表示

#### Error State
- エラーメッセージの表示
- "Try Again"ボタンでリトライ可能
- シミュレート: メニューから"Simulate Error"

#### Partial State
- 1〜2個の商品のみ表示
- 画面下部に「もっと追加」を促すバナー
- 完了度に応じた状態遷移

#### Ideal State
- 3個以上の商品を表示
- 通常のリストビュー
- 削除、追加機能付き

**実装のポイント**:
```dart
// StateWrapperで5つの状態を一元管理
StateWrapper<List<Product>>(
  uiStateData: uiState,
  idealBuilder: (products) => _buildProductList(products),
  emptyMessage: 'No products available',
  onRetry: () => notifier.loadProducts(count: 10),
)

// 状態切り替えチップ
FilterChip(
  label: Text('Empty'),
  selected: currentState == UIState.empty,
  onSelected: (_) => notifier.setDemoState(UIState.empty),
)
```

**Provider実装**:
```dart
// 商品数に応じた自動状態遷移
if (products.isEmpty) {
  state = UIStateData(state: UIState.empty);
} else if (products.length <= 2) {
  state = UIStateData(state: UIState.partial);
} else {
  state = UIStateData(state: UIState.ideal);
}
```

---

### 3. ユーザープロフィール画面 (UserProfileScreen)

**場所**: `lib/screens/user_profile_screen.dart`

ユーザープロフィールの表示・編集画面で、完成度に応じた状態遷移を実装しています。

#### Blank State
- 新規ユーザー向けの表示
- "Create Profile"ボタン
- プロフィール作成を促すメッセージ

#### Loading State
- プロフィール読み込み中
- データ保存中の表示

#### Error State
- プロフィール保存失敗
- ネットワークエラー
- リトライ機能

#### Partial State
- プロフィール未完成（完成度 < 60%）
- 完成度バーの表示
- "Complete Your Profile"バナー
- 不足している項目のハイライト

#### Ideal State
- 完全なプロフィール（完成度 100%）
- すべての情報が入力済み
- アバター、名前、メール、自己紹介、興味など

**実装のポイント**:
```dart
// 完成度の自動計算
int get completionPercentage {
  int filledFields = 0;
  const int totalFields = 7;

  if (name != null && name!.isNotEmpty) filledFields++;
  if (email != null && email!.isNotEmpty) filledFields++;
  // ... 他のフィールドチェック

  return ((filledFields / totalFields) * 100).round();
}

// 完成度に応じた状態遷移
if (profile.completionPercentage == 0) {
  state = UIStateData(state: UIState.empty);
} else if (profile.completionPercentage < 60) {
  state = UIStateData(state: UIState.partial);
} else {
  state = UIStateData(state: UIState.ideal);
}
```

**Partial Stateのバナー**:
```dart
PartialStateBanner(
  title: 'Complete Your Profile',
  description: 'Add more information to unlock all features',
  completionPercentage: profile.completionPercentage,
  onComplete: () => _showProfileEditor(context),
)
```

---

### 4. 検索画面 (SearchScreen)

**場所**: `lib/screens/search_screen.dart`

検索機能を持つ画面で、検索結果の状態を管理しています。

#### Blank State
- 検索前: "Start searching"メッセージと検索候補チップ
- 検索結果なし: "No results found"メッセージと検索のヒント

#### Loading State
- 検索中のローディング表示
- リアルタイム検索のデバウンス処理

#### Error State
- 検索APIのエラー
- ネットワーク接続エラー
- リトライ機能

#### Partial State
- 検索結果が1〜2件のみ
- "Few results found"の情報カード
- より広い検索を促すメッセージ

#### Ideal State
- 3件以上の検索結果
- 検索ワードのハイライト表示
- カテゴリ別アイコン表示

**実装のポイント**:
```dart
// リアルタイム検索
TextField(
  onChanged: (value) {
    if (value.isNotEmpty) {
      notifier.search(value);
    } else {
      notifier.clearSearch();
    }
  },
)

// 検索ワードのハイライト
List<TextSpan> _highlightSearchTerm(String text, String searchTerm) {
  // 検索ワードを太字＋背景色でハイライト
  return spans;
}

// カテゴリ別アイコン
IconData _getIconForCategory(String category) {
  switch (category.toLowerCase()) {
    case 'electronics': return Icons.devices;
    case 'clothing': return Icons.checkroom;
    case 'books': return Icons.book;
    // ...
  }
}
```

**検索候補チップ**:
```dart
ActionChip(
  label: Text('Electronics'),
  onPressed: () {
    _searchController.text = 'Electronics';
    notifier.search('Electronics');
  },
)
```

---

### 5. UIステートカタログ画面 (UIStateCatalogScreen)

**場所**: `lib/screens/ui_state_catalog_screen.dart`

すべてのUI状態を一覧表示する、Storybook的なカタログ画面です。

**主な機能**:
- 全5つのUI状態のサンプル表示
- スクリーンショット撮影に最適化されたレイアウト
- 各状態の説明とユースケース

**表示内容**:
1. Blank State - アイコンとCTAボタン
2. Loading State - Shimmerスケルトンスクリーン（3アイテム）
3. Error State - エラー詳細とリトライボタン
4. Partial State - バナー型とボトムバー型
5. Ideal State - 商品リスト（5アイテム）
6. Ideal State - ユーザープロフィール（完全版）
7. Search Blank - 検索候補付き
8. Search Partial - 少ない検索結果

**実装のポイント**:
```dart
// 状態カードの統一レイアウト
Widget _buildStateCard(
  BuildContext context,
  String title,
  String description,
  Widget child,
) {
  return Card(
    child: Column(
      children: [
        // ヘッダー（タイトルと説明）
        Container(
          color: primaryContainer,
          child: Column(
            children: [
              Text(title, style: titleMedium),
              Text(description, style: bodySmall),
            ],
          ),
        ),
        // 状態のサンプル表示
        SizedBox(height: 400, child: child),
      ],
    ),
  );
}
```

---

## コアコンポーネントの説明

### StateWrapper

**場所**: `lib/widgets/state_wrapper.dart`

5つのUI状態を一元管理する汎用ウィジェットです。

**使い方**:
```dart
StateWrapper<List<Product>>(
  uiStateData: uiState,
  idealBuilder: (data) => _buildProductList(data),
  emptyMessage: 'No products available',
  emptyButtonText: 'Add Products',
  onEmptyAction: () => loadProducts(),
  partialMessage: 'Add more products',
  onPartialAction: () => addMore(),
  onRetry: () => retry(),
)
```

**機能**:
- 状態に応じた自動UI切り替え
- カスタマイズ可能な各状態のウィジェット
- 統一されたエラーハンドリング

---

### UIStateData

**場所**: `lib/models/ui_state.dart`

UI状態とデータを保持するデータクラスです。

```dart
enum UIState {
  empty,    // 空
  loading,  // 読み込み中
  error,    // エラー
  partial,  // 部分的
  ideal,    // 理想的
}

class UIStateData<T> {
  final UIState state;
  final T? data;
  final String? errorMessage;
  final int? itemCount;

  bool get isEmpty => state == UIState.empty;
  bool get isLoading => state == UIState.loading;
  bool get hasError => state == UIState.error;
  bool get isPartial => state == UIState.partial;
  bool get isIdeal => state == UIState.ideal;
}
```

---

### MockDataService

**場所**: `lib/services/mock_data_service.dart`

モックデータの生成とネットワーク遅延のシミュレーションを行うサービスです。

**機能**:
```dart
// 商品データの生成
List<Product> generateProducts(int count);

// ユーザープロフィールの生成
UserProfile generateUserProfile({
  required String userId,
  bool isEmpty = false,
  bool isPartial = false,
  bool isComplete = false,
});

// ネットワーク遅延のシミュレート
Future<T> simulateNetworkDelay<T>(
  T data, {
  Duration delay = const Duration(seconds: 2),
  bool shouldFail = false,
  String? errorMessage,
});

// 検索機能
List<Product> searchProducts(List<Product> products, String query);
```

---

## 技術スタック

- **Flutter**: 3.38.0-stable
- **Dart**: 3.10.0-290.4.beta
- **状態管理**: flutter_riverpod ^2.6.1
- **HTTPクライアント**: dio ^5.9.0
- **ローディングアニメーション**: shimmer ^3.0.0
- **値の等価性**: equatable ^2.0.7

---

## セットアップと実行

### 必要要件
- Flutter SDK 3.10以上
- Dart SDK 3.10以上

### インストール
```bash
# 依存関係のインストール
flutter pub get

# アプリの実行（Chrome）
flutter run -d chrome

# アプリの実行（モバイルデバイス）
flutter run
```

---

## デモの使い方

1. **ホーム画面**: The Five UI Statesの概要を確認
2. **商品リスト**: 画面上部のチップで状態を切り替え
3. **プロフィール**: メニューから各状態を読み込み
4. **検索**: キーワードを入力して検索結果の状態を確認
5. **カタログ**: ホーム画面の「Open UI State Catalog」から全状態を一覧表示

---

## スクリーンショット撮影

UIステートカタログ画面を使用すると、すべての状態を効率的にキャプチャできます。

```bash
# モバイルサイズでChromeを起動
flutter run -d chrome --web-browser-flag="--window-size=414,896"
```

---

## デザインパターンの適用例

### 状態遷移の自動化
```dart
// データ量に応じて自動的に状態を変更
if (items.isEmpty) {
  state = UIStateData(state: UIState.empty);
} else if (items.length <= threshold) {
  state = UIStateData(state: UIState.partial);
} else {
  state = UIStateData(state: UIState.ideal);
}
```

### エラーハンドリング
```dart
try {
  final data = await fetchData();
  state = UIStateData(state: UIState.ideal, data: data);
} catch (e) {
  state = UIStateData(
    state: UIState.error,
    errorMessage: e.toString(),
  );
}
```

### ローディング表示
```dart
// リクエスト開始時
state = state.copyWith(state: UIState.loading);

// データ取得後
state = UIStateData(state: UIState.ideal, data: result);
```

---

## ベストプラクティス

1. **すべての画面で5つの状態を考慮する**
   - 空の状態を放置しない
   - ローディング中のUXを改善
   - エラー時にリトライ機能を提供

2. **状態遷移をスムーズにする**
   - データ量の閾値を適切に設定
   - アニメーションで状態変化を分かりやすく

3. **ユーザーを導く**
   - Blank Stateで次のアクションを明確に
   - Partial Stateで完了を促す

4. **一貫性を保つ**
   - StateWrapperで統一されたUI
   - 共通のエラーメッセージ形式

---

## 参考資料

- [The Five UI States - Scott Hurff](https://www.scotthurff.com/posts/why-your-user-interface-is-awkward-youre-ignoring-the-ui-stack/)
- [Designing Products People Love - O'Reilly](https://www.oreilly.com/library/view/designing-products-people/9781491923689/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)

---

## ライセンス

このプロジェクトはLT（ライトニングトーク）用のサンプルプロジェクトです。

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
