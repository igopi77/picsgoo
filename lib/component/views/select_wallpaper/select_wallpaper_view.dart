import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/root_bloc/root_bloc.dart';

class SelectWallpaperView extends StatefulWidget {
  const SelectWallpaperView({super.key});

  @override
  State<SelectWallpaperView> createState() => _SelectWallpaperViewState();
}

class _SelectWallpaperViewState extends State<SelectWallpaperView>
    with TickerProviderStateMixin {
  String selectedWallpaper = 'assets/wallpapers/1.jpg';
  List<String> availableWallpapers = [];
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Generate wallpaper paths
    availableWallpapers = List.generate(12, (index) => 'assets/wallpapers/${index + 1}.jpg');

    // Get current wallpaper from bloc and set as selected
    final bloc = context.read<RootBloc>();
    selectedWallpaper = bloc.currentWallpaper.isNotEmpty
        ? bloc.currentWallpaper
        : availableWallpapers.first;

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RootBloc, RootState>(
      listener: (context, state) {
        // Handle state changes here (like showing success messages)
        if (state is WallpaperLoadedState) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Wallpaper Applied Successfully!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Your new wallpaper is now active',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );

          // Auto-close after setting wallpaper
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            // Animated background using BlocBuilder
            BlocBuilder<RootBloc, RootState>(
              builder: (context, state) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(selectedWallpaper),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.4),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Glassmorphism overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: bodyPartOfSelectWallpaper(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
      ),
      title: const Text(
        'Wallpaper Gallery',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget bodyPartOfSelectWallpaper() {
    return Column(
      children: [
        const SizedBox(height: 120), // Account for app bar
        const SizedBox(height: 20),

        // Wallpapers grid with better styling
        Expanded(child: _buildWallpaperGrid()),

        // Enhanced action button
        _buildActionButton(),
      ],
    );
  }

  Widget _buildWallpaperGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Text(
                'Choose Wallpaper',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(
                  '${availableWallpapers.length} items',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Grid with BlocBuilder
          Expanded(
            child: BlocBuilder<RootBloc, RootState>(
              builder: (context, state) {
                final bloc = context.read<RootBloc>();
                final currentWallpaper = bloc.currentWallpaper;

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: availableWallpapers.length,
                  itemBuilder: (context, index) {
                    final wallpaperPath = availableWallpapers[index];
                    final isSelected = selectedWallpaper == wallpaperPath;
                    final isCurrent = currentWallpaper == wallpaperPath;

                    return _buildWallpaperCard(wallpaperPath, index, isSelected, isCurrent);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard(String wallpaperPath, int index, bool isSelected, bool isCurrent) {
    return GestureDetector(
      onTap: () {
        // Only update selectedWallpaper, no setState needed!
        selectedWallpaper = wallpaperPath;
        // Trigger a rebuild by dispatching a light event or just rebuild the affected parts
        // For now, we'll use a minimal setState just for selectedWallpaper
        if (mounted) {
          setState(() {}); // Only rebuilds this widget, not the whole tree
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 3,
                offset: const Offset(0, 8),
              )
            else if (isCurrent)
              BoxShadow(
                color: Colors.green.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper image
              Image.asset(
                wallpaperPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade800,
                          Colors.grey.shade900,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white.withOpacity(0.6),
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Gradient overlay for better text visibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              // Selection/Current border
              if (isSelected || isCurrent)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.green,
                      width: 4,
                    ),
                  ),
                ),

              // Selection overlay
              if (isSelected || isCurrent)
                Container(
                  decoration: BoxDecoration(
                    color: (isSelected ? Colors.blue : Colors.green).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

              // Status indicators
              Positioned(
                top: 12,
                right: 12,
                child: AnimatedScale(
                  scale: (isSelected || isCurrent) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected ? Colors.blue : Colors.green).withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      isCurrent ? Icons.check : Icons.radio_button_checked,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Wallpaper number
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return BlocBuilder<RootBloc, RootState>(
      builder: (context, state) {
        final bloc = context.read<RootBloc>();
        final currentWallpaper = bloc.currentWallpaper;
        final isCurrentWallpaper = selectedWallpaper == currentWallpaper;

        return Container(
          padding: const EdgeInsets.all(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isCurrentWallpaper ? Colors.grey : Colors.blue,
              boxShadow: [
                if (!isCurrentWallpaper)
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: isCurrentWallpaper ? null : _setWallpaper,
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCurrentWallpaper ? Icons.check_circle : Icons.wallpaper,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isCurrentWallpaper ? "Currently Active" : "Set as Wallpaper",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _setWallpaper() {
    context.read<RootBloc>().add(
      SetWallpaperEvent(wallpaperPath: selectedWallpaper),
    );
  }
}