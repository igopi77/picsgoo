import 'dart:async';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picsgoo/component/models/apps_model.dart';
import 'package:picsgoo/component/widgets/wallpaper_background.dart';

import '../../blocs/root_bloc/root_bloc.dart';

class AllAppsView extends StatefulWidget {
  final InitialAllAppsLoadedState state;

  const AllAppsView({super.key, required this.state});

  @override
  State<AllAppsView> createState() => _AllAppsViewState();
}

class _AllAppsViewState extends State<AllAppsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AppsModel> _filteredApps = [];
  Map<String, List<AppsModel>> _groupedApps = {};
  List<String> _availableLetters = [];
  Map<String, double> _letterPositions = {};

  bool _showingAlphabetIndex = true;
  String? _currentDragLetter;
  bool _isDraggingAlphabet = false;
  Timer? _dragEndTimer;
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    _filteredApps = widget.state.allApps;
    _searchController.addListener(_onSearchChanged);
    _groupAppsAlphabetically();
  }

  void _createSectionKeys() {
    _sectionKeys.clear();
    for (String letter in _availableLetters) {
      _sectionKeys[letter] = GlobalKey();
    }
  }


  void _groupAppsAlphabetically() {
    _groupedApps.clear();
    _availableLetters.clear();

    // Group apps by first letter with proper validation
    for (var appModel in _filteredApps) {
      final appName = appModel.app.appName.trim();
      if (appName.isEmpty) continue;

      final firstChar = appName[0].toUpperCase();

      // Only include letters A-Z, skip numbers and special characters
      if (firstChar.codeUnitAt(0) < 65 || firstChar.codeUnitAt(0) > 90) {
        const specialKey = '#';
        if (!_groupedApps.containsKey(specialKey)) {
          _groupedApps[specialKey] = [];
          _availableLetters.add(specialKey);
        }
        _groupedApps[specialKey]!.add(appModel);
      } else {
        if (!_groupedApps.containsKey(firstChar)) {
          _groupedApps[firstChar] = [];
          _availableLetters.add(firstChar);
        }
        _groupedApps[firstChar]!.add(appModel);
      }
    }

    // Sort letters (# will come first, then A-Z)
    _availableLetters.sort((a, b) {
      if (a == '#') return -1;
      if (b == '#') return 1;
      return a.compareTo(b);
    });

    // Sort apps within each group
    _groupedApps.forEach((key, value) {
      value.sort((a, b) => a.app.appName.compareTo(b.app.appName));
    });

    // Create section keys AFTER grouping
    _createSectionKeys();
  }

  void _calculateLetterPositions() {
    _letterPositions.clear();
    double currentPosition = 0;

    for (String letter in _availableLetters) {
      _letterPositions[letter] = currentPosition;

      // Validate that the group actually exists and has apps
      final appsInGroup = _groupedApps[letter];
      if (appsInGroup != null && appsInGroup.isNotEmpty) {
        // Header height (40) + apps count * item height (72) + spacing
        currentPosition += 40 + (appsInGroup.length * 72) + 8;
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredApps = widget.state.allApps;
        _showingAlphabetIndex = true;
      } else {
        _filteredApps = widget.state.allApps
            .where((appInfo) =>
            appInfo.app.appName.toLowerCase().contains(query))
            .toList();
        _showingAlphabetIndex = false;
      }
      _groupAppsAlphabetically();
      _calculateLetterPositions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _dragEndTimer?.cancel();
    super.dispose();
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WallpaperBackground(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Time + Date
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                  child: StreamBuilder<DateTime>(
                    stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                    initialData: DateTime.now(),
                    builder: (context, snapshot) {
                      final now = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getWeekday(now.weekday)}, ${now.day} ${_getMonth(now.month)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                /// Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Search apps...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                /// Apps List
                Expanded(
                  child: _showingAlphabetIndex
                      ? _buildGroupedAppsList()
                      : _buildFilteredAppsList(),
                ),
              ],
            ),

            // Alphabetical Index Sidebar
            if (_showingAlphabetIndex)
              _buildAlphabetIndex(),

            // Current letter indicator during drag
            if (_currentDragLetter != null)
              _buildCurrentLetterIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedAppsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(right: 30),
      itemCount: _availableLetters.length,
      itemBuilder: (context, index) {
        final letter = _availableLetters[index];
        final apps = _groupedApps[letter]!;

        return Column(
          key: _sectionKeys[letter], // Add key for positioning
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                letter,
                style: TextStyle(
                  color: Colors.blue.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
            ),
            // Apps in this section
            ...apps.map((appModel) {
              final app = appModel.app;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Row(
                  children: [
                    if (app is ApplicationWithIcon)
                      Image.memory(
                        app.icon,
                        width: 40,
                        height: 40,
                      ),
                    const SizedBox(width: 20),
                    Text(
                      app.appName,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
                onTap: () {
                  context.read<RootBloc>().add(
                    LaunchAppEvent(packageName: app.packageName),
                  );
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildFilteredAppsList() {
    return ListView.builder(
      itemCount: _filteredApps.length,
      itemBuilder: (context, index) {
        final app = _filteredApps[index].app;
        return ListTile(
          title: Row(
            children: [
              if (app is ApplicationWithIcon)
                Image.memory(
                  app.icon,
                  width: 40,
                  height: 40,
                ),
              const SizedBox(width: 20),
              Text(
                app.appName,
                style: const TextStyle(color: Colors.white60),
              ),
            ],
          ),
          onTap: () {
            context.read<RootBloc>().add(
              LaunchAppEvent(packageName: app.packageName),
            );
          },
        );
      },
    );
  }

  Widget _buildAlphabetIndex() {
    return Positioned(
      right: 4,
      top: MediaQuery.of(context).size.height * 0.25,
      bottom: MediaQuery.of(context).size.height * 0.1,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDraggingAlphabet = true;
          });
          _handleAlphabetInteraction(details.localPosition, isDrag: true);
          HapticFeedback.selectionClick();
        },
        onPanUpdate: (details) {
          _handleAlphabetInteraction(details.localPosition, isDrag: true);
        },
        onPanEnd: (details) {
          _dragEndTimer?.cancel();
          _dragEndTimer = Timer(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _currentDragLetter = null;
                _isDraggingAlphabet = false;
              });
            }
          });
        },
        onTapDown: (details) {
          // Handle tap immediately for better responsiveness
          _handleAlphabetInteraction(details.localPosition, isDrag: false);
        },
        child: Container(
          width: 24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _buildAlphabetItems(),
          ),
        ),
      ),
    );
  }

  // **Unified Touch Handling Method**
  void _handleAlphabetInteraction(Offset position, {required bool isDrag}) {
    final containerHeight = MediaQuery.of(context).size.height * 0.65;

    // Get all available letters in correct order (including #)
    final allLetters = ['#', ...List.generate(26, (i) => String.fromCharCode(65 + i))];

    // Find which letter was touched
    final itemHeight = containerHeight / allLetters.length;
    final tappedIndex = (position.dy / itemHeight).floor().clamp(0, allLetters.length - 1);
    final tappedLetter = allLetters[tappedIndex];

    // Only proceed if this letter has apps
    if (_availableLetters.contains(tappedLetter) &&
        _groupedApps[tappedLetter] != null &&
        _groupedApps[tappedLetter]!.isNotEmpty) {

      // Update UI state
      setState(() {
        _currentDragLetter = tappedLetter;
        if (!isDrag) {
          _isDraggingAlphabet = true;
        }
      });

      // Jump to letter
      _jumpToLetter(tappedLetter);

      // Haptic feedback
      HapticFeedback.selectionClick();

      // Auto-hide for taps
      if (!isDrag) {
        Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _currentDragLetter = null;
              _isDraggingAlphabet = false;
            });
          }
        });
      }
    }
  }

  // **Build Alphabet Items Dynamically**
  List<Widget> _buildAlphabetItems() {
    final allLetters = ['#', ...List.generate(26, (i) => String.fromCharCode(65 + i))];

    return allLetters.map((letter) {
      final isAvailable = _availableLetters.contains(letter);
      final isActive = _currentDragLetter == letter;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: isActive ? 4 : 2,
          horizontal: isActive ? 6 : 2,
        ),
        decoration: isActive ? BoxDecoration(
          color: Colors.blue.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ) : null,
        child: Text(
          letter,
          style: TextStyle(
            color: isAvailable
                ? (isActive ? Colors.white : Colors.white.withOpacity(0.7))
                : Colors.white.withOpacity(0.15),
            fontSize: isActive ? 14 : 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w300,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCurrentLetterIndicator() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      left: _isDraggingAlphabet ? 50 : MediaQuery.of(context).size.width / 2 - 40,
      top: MediaQuery.of(context).size.height / 2 - 40,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(_isDraggingAlphabet ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.95),
          borderRadius: BorderRadius.circular(_isDraggingAlphabet ? 10 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: _isDraggingAlphabet ? 15 : 20,
              spreadRadius: _isDraggingAlphabet ? 3 : 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _currentDragLetter!,
              style: TextStyle(
                color: Colors.white,
                fontSize: _isDraggingAlphabet ? 32 : 40,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (_isDraggingAlphabet) ...[
              const SizedBox(width: 8),
              Text(
                '${_groupedApps[_currentDragLetter!]?.length ?? 0}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  void _jumpToLetter(String letter) {
    final sectionKey = _sectionKeys[letter];

    // Method 1: Try Scrollable.ensureVisible (most reliable)
    if (sectionKey?.currentContext != null) {
      try {
        Scrollable.ensureVisible(
          sectionKey!.currentContext!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: 0.1, // Small offset from top
        );
        return;
      } catch (e) {
        // Fall through to backup method
      }
    }

    // Method 2: Backup using ListView index
    final letterIndex = _availableLetters.indexOf(letter);
    if (letterIndex != -1 && _scrollController.hasClients) {

      // Calculate approximate position
      double targetPosition = 0;
      for (int i = 0; i < letterIndex; i++) {
        final prevLetter = _availableLetters[i];
        final appsCount = _groupedApps[prevLetter]?.length ?? 0;
        targetPosition += 48 + (appsCount * 72) + 16; // Header + apps + spacing
      }

      final maxScroll = _scrollController.position.maxScrollExtent;
      final clampedPosition = targetPosition.clamp(0.0, maxScroll);

      _scrollController.animateTo(
        clampedPosition,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
      );
    }
  }
}
