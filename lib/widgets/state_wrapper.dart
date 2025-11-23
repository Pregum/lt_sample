import 'package:flutter/material.dart';
import '../models/ui_state.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';
import 'loading_state_widget.dart';
import 'partial_state_widget.dart';

class StateWrapper<T> extends StatelessWidget {
  final UIStateData<T> uiStateData;
  final Widget Function(T data) idealBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? partialWidget;
  final VoidCallback? onRetry;
  final String? emptyMessage;
  final String? emptyButtonText;
  final VoidCallback? onEmptyAction;
  final String? partialMessage;
  final VoidCallback? onPartialAction;

  const StateWrapper({
    super.key,
    required this.uiStateData,
    required this.idealBuilder,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.partialWidget,
    this.onRetry,
    this.emptyMessage,
    this.emptyButtonText,
    this.onEmptyAction,
    this.partialMessage,
    this.onPartialAction,
  });

  @override
  Widget build(BuildContext context) {
    switch (uiStateData.state) {
      case UIState.empty:
        return emptyWidget ??
            EmptyStateWidget(
              message: emptyMessage ?? 'No data available',
              buttonText: emptyButtonText,
              onAction: onEmptyAction,
            );
      case UIState.loading:
        return loadingWidget ?? const LoadingStateWidget();
      case UIState.error:
        return errorWidget ??
            ErrorStateWidget(
              message: uiStateData.errorMessage ?? 'An error occurred',
              onRetry: onRetry,
            );
      case UIState.partial:
        if (uiStateData.data != null) {
          return Stack(
            children: [
              idealBuilder(uiStateData.data as T),
              if (partialWidget != null) partialWidget!,
              if (partialWidget == null && partialMessage != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: PartialStateWidget(
                    message: partialMessage!,
                    onAction: onPartialAction,
                  ),
                ),
            ],
          );
        } else {
          return partialWidget ??
              PartialStateWidget(
                message: partialMessage ?? 'Almost there! Add more content',
                onAction: onPartialAction,
              );
        }
      case UIState.ideal:
        if (uiStateData.data != null) {
          return idealBuilder(uiStateData.data as T);
        } else {
          return const EmptyStateWidget(
            message: 'No data to display',
          );
        }
    }
  }
}