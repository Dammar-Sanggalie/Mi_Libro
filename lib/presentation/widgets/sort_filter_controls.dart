// lib/widgets/sort_filter_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/book_library_cubit.dart';
import '../../domain/entities/sort_option.dart';

class SortFilterControls extends StatelessWidget {
  const SortFilterControls({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookLibraryCubit, BookLibraryState>(
      builder: (context, state) {
        final cubit = context.read<BookLibraryCubit>();
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Sort Button
              Expanded(
                child: GestureDetector(
                  onTap: () => _showSortOptions(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cubit.currentSort.icon,
                          size: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cubit.currentSort.displayName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Rating Filter Button
              Expanded(
                child: GestureDetector(
                  onTap: () => _showRatingFilters(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cubit.currentRatingFilter.icon,
                          size: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cubit.currentRatingFilter.displayName,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Urutkan Berdasarkan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            ...SortOption.values.map((option) => _buildSortOption(context, option)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showRatingFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Filter Rating',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            ...RatingFilter.values.map((filter) => _buildRatingFilter(context, filter)),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, SortOption option) {
    return BlocBuilder<BookLibraryCubit, BookLibraryState>(
      builder: (context, state) {
        final cubit = context.read<BookLibraryCubit>();
        final isSelected = cubit.currentSort == option;
        
        return GestureDetector(
          onTap: () {
            cubit.changeSorting(option);
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Color(0xFF6366F1).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Color(0xFF6366F1).withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  option.icon,
                  size: 20,
                  color: isSelected 
                      ? Color(0xFF6366F1)
                      : Colors.white.withOpacity(0.7),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.displayName,
                    style: TextStyle(
                      color: isSelected 
                          ? Color(0xFF6366F1)
                          : Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Color(0xFF6366F1),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingFilter(BuildContext context, RatingFilter filter) {
    return BlocBuilder<BookLibraryCubit, BookLibraryState>(
      builder: (context, state) {
        final cubit = context.read<BookLibraryCubit>();
        final isSelected = cubit.currentRatingFilter == filter;
        
        return GestureDetector(
          onTap: () {
            cubit.changeRatingFilter(filter);
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Color(0xFF6366F1).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Color(0xFF6366F1).withOpacity(0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  filter.icon,
                  size: 20,
                  color: isSelected 
                      ? Color(0xFF6366F1)
                      : Colors.white.withOpacity(0.7),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    filter.displayName,
                    style: TextStyle(
                      color: isSelected 
                          ? Color(0xFF6366F1)
                          : Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Color(0xFF6366F1),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}