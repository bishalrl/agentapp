import 'package:equatable/equatable.dart';

/// Granular loading states instead of simple boolean
/// Allows partial loading while keeping previous data visible
class LoadingState extends Equatable {
  final bool isLoading;
  final bool isRefreshing; // Background refresh
  final bool isInitialLoad; // First load
  final Set<String> loadingItems; // Specific items being loaded
  
  const LoadingState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isInitialLoad = false,
    this.loadingItems = const {},
  });
  
  LoadingState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isInitialLoad,
    Set<String>? loadingItems,
    bool clearLoadingItems = false,
  }) {
    return LoadingState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isInitialLoad: isInitialLoad ?? this.isInitialLoad,
      loadingItems: clearLoadingItems 
          ? const {} 
          : (loadingItems ?? this.loadingItems),
    );
  }
  
  /// Check if specific item is loading
  bool isItemLoading(String itemId) => loadingItems.contains(itemId);
  
  /// Add loading item
  LoadingState addLoadingItem(String itemId) {
    return copyWith(
      loadingItems: {...loadingItems, itemId},
    );
  }
  
  /// Remove loading item
  LoadingState removeLoadingItem(String itemId) {
    return copyWith(
      loadingItems: loadingItems..remove(itemId),
    );
  }
  
  @override
  List<Object?> get props => [isLoading, isRefreshing, isInitialLoad, loadingItems];
}
