enum UIState {
  empty,
  loading,
  error,
  partial,
  ideal,
}

class UIStateData<T> {
  final UIState state;
  final T? data;
  final String? errorMessage;
  final int? itemCount;

  const UIStateData({
    required this.state,
    this.data,
    this.errorMessage,
    this.itemCount,
  });

  UIStateData<T> copyWith({
    UIState? state,
    T? data,
    String? errorMessage,
    int? itemCount,
  }) {
    return UIStateData(
      state: state ?? this.state,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  bool get isEmpty => state == UIState.empty;
  bool get isLoading => state == UIState.loading;
  bool get hasError => state == UIState.error;
  bool get isPartial => state == UIState.partial;
  bool get isIdeal => state == UIState.ideal;
}