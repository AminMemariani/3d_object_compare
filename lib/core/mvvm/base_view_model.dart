import 'package:flutter/foundation.dart';

/// Base class for ViewModels in MVVM architecture
abstract class BaseViewModel extends ChangeNotifier {
  bool _isDisposed = false;
  String? _error;
  bool _isLoading = false;

  bool get isDisposed => _isDisposed;
  String? get error => _error;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Sets the loading state
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets an error message
  void setError(String? error) {
    if (_isDisposed) return;
    _error = error;
    notifyListeners();
  }

  /// Clears the current error
  void clearError() {
    if (_isDisposed) return;
    _error = null;
    notifyListeners();
  }

  /// Safely notifies listeners
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// Executes an async operation with loading and error handling
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    bool showLoading = true,
    String? loadingMessage,
  }) async {
    try {
      if (showLoading) {
        setLoading(true);
      }
      clearError();

      final result = await operation();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      if (showLoading) {
        setLoading(false);
      }
    }
  }

  /// Executes an async operation without loading state
  Future<T?> executeSilent<T>(Future<T> Function() operation) async {
    return executeAsync(operation, showLoading: false);
  }
}

/// Mixin for ViewModels that need to handle multiple async operations
mixin AsyncOperationMixin on BaseViewModel {
  final Map<String, bool> _operationStates = {};

  /// Checks if a specific operation is running
  bool isOperationRunning(String operationId) {
    return _operationStates[operationId] ?? false;
  }

  /// Sets the state of a specific operation
  void setOperationState(String operationId, bool running) {
    if (_isDisposed) return;
    _operationStates[operationId] = running;
    notifyListeners();
  }

  /// Executes an async operation with a specific ID
  Future<T?> executeOperation<T>(
    String operationId,
    Future<T> Function() operation,
  ) async {
    try {
      setOperationState(operationId, true);
      clearError();

      final result = await operation();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setOperationState(operationId, false);
    }
  }
}

/// Mixin for ViewModels that need to handle pagination
mixin PaginationMixin on BaseViewModel {
  int _currentPage = 0;
  int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;

  void setPageSize(int size) {
    _pageSize = size;
    notifyListeners();
  }

  void resetPagination() {
    _currentPage = 0;
    _hasMoreData = true;
    _isLoadingMore = false;
    notifyListeners();
  }

  void setLoadingMore(bool loading) {
    if (_isDisposed) return;
    _isLoadingMore = loading;
    notifyListeners();
  }

  void setHasMoreData(bool hasMore) {
    if (_isDisposed) return;
    _hasMoreData = hasMore;
    notifyListeners();
  }

  void incrementPage() {
    if (_isDisposed) return;
    _currentPage++;
    notifyListeners();
  }
}

/// Mixin for ViewModels that need to handle search functionality
mixin SearchMixin on BaseViewModel {
  String _searchQuery = '';
  List<String> _searchHistory = [];
  bool _isSearching = false;

  String get searchQuery => _searchQuery;
  List<String> get searchHistory => List.unmodifiable(_searchHistory);
  bool get isSearching => _isSearching;

  void setSearchQuery(String query) {
    if (_isDisposed) return;
    _searchQuery = query;
    notifyListeners();
  }

  void setSearching(bool searching) {
    if (_isDisposed) return;
    _isSearching = searching;
    notifyListeners();
  }

  void addToSearchHistory(String query) {
    if (_isDisposed || query.trim().isEmpty) return;

    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    // Keep only last 10 searches
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }

    notifyListeners();
  }

  void clearSearchHistory() {
    if (_isDisposed) return;
    _searchHistory.clear();
    notifyListeners();
  }

  void clearSearch() {
    if (_isDisposed) return;
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }
}
