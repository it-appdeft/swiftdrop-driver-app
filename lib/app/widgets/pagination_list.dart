import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import 'app_loader.dart';
import 'empty_state_widget.dart';
import 'error_state_widget.dart';

class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool hasError;
  final String? errorMessage;
  final Widget? emptyState;
  final Widget? shimmerWidget;
  final int shimmerCount;
  final EdgeInsets? padding;
  final Widget? header;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.hasError = false,
    this.errorMessage,
    this.emptyState,
    this.shimmerWidget,
    this.shimmerCount = 6,
    this.padding,
    this.header,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    final threshold = maxScroll * 0.85;

    if (current >= threshold &&
        !widget.isLoadingMore &&
        widget.hasMore &&
        !widget.isLoading) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return widget.shimmerWidget != null
          ? ListView.builder(
              itemCount: widget.shimmerCount,
              itemBuilder: (context, index) => widget.shimmerWidget!,
            )
          : AppLoader.page();
    }

    if (widget.hasError && widget.items.isEmpty) {
      return ErrorStateWidget.server(onRetry: widget.onRefresh);
    }

    if (widget.items.isEmpty) {
      return widget.emptyState ?? EmptyStateWidget.orders(onRefresh: widget.onRefresh);
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding ?? const EdgeInsets.only(bottom: AppDimensions.paddingXl),
        itemCount: widget.items.length + (widget.header != null ? 1 : 0) + 1,
        itemBuilder: (context, index) {
          if (widget.header != null && index == 0) {
            return widget.header!;
          }

          final dataIndex = widget.header != null ? index - 1 : index;

          if (dataIndex == widget.items.length) {
            if (widget.isLoadingMore) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingLg),
                child: Center(child: AppLoader()),
              );
            }
            if (!widget.hasMore) return const SizedBox(height: AppDimensions.gapLg);
            return const SizedBox.shrink();
          }

          return widget.itemBuilder(context, widget.items[dataIndex], dataIndex);
        },
      ),
    );
  }
}
