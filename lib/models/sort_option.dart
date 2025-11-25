// lib/models/sort_option.dart
import 'package:flutter/material.dart';

enum SortOption {
  popularity,  // berdasarkan download terbanyak (default API)
  titleAZ,     // judul A-Z
  titleZA,     // judul Z-A
  newest,      // rilis terbaru
  oldest,      // rilis terlama
}

extension SortOptionExtension on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.popularity:
        return 'Download Terbanyak';
      case SortOption.titleAZ:
        return 'Judul A-Z';
      case SortOption.titleZA:
        return 'Judul Z-A';
      case SortOption.newest:
        return 'Rilis Terbaru';
      case SortOption.oldest:
        return 'Rilis Terlama';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.popularity:
        return Icons.trending_up_rounded;
      case SortOption.titleAZ:
        return Icons.sort_by_alpha_rounded;
      case SortOption.titleZA:
        return Icons.sort_by_alpha_rounded;
      case SortOption.newest:
        return Icons.schedule_rounded;
      case SortOption.oldest:
        return Icons.history_rounded;
    }
  }

  String get apiSortParam {
    switch (this) {
      case SortOption.popularity:
        return 'popular';    // default Gutendex
      case SortOption.titleAZ:
        return 'ascending';  // berdasarkan ID (aproksimasi)
      case SortOption.titleZA:
        return 'descending'; // berdasarkan ID (aproksimasi)
      case SortOption.newest:
        return 'descending'; // ID tinggi = buku baru
      case SortOption.oldest:
        return 'ascending';  // ID rendah = buku lama
    }
  }
}

enum RatingFilter {
  all,     // semua rating
  rating5, // 5 keatas
  rating4, // 4 keatas
  rating3, // 3 keatas
  rating2, // 2 keatas
  rating1, // 1 keatas
}

extension RatingFilterExtension on RatingFilter {
  String get displayName {
    switch (this) {
      case RatingFilter.all:
        return 'Semua Rating';
      case RatingFilter.rating5:
        return '5⭐ ke atas';
      case RatingFilter.rating4:
        return '4⭐ ke atas';
      case RatingFilter.rating3:
        return '3⭐ ke atas';
      case RatingFilter.rating2:
        return '2⭐ ke atas';
      case RatingFilter.rating1:
        return '1⭐ ke atas';
    }
  }

  int get minimumRating {
    switch (this) {
      case RatingFilter.all:
        return 0;
      case RatingFilter.rating1:
        return 1;
      case RatingFilter.rating2:
        return 2;
      case RatingFilter.rating3:
        return 3;
      case RatingFilter.rating4:
        return 4;
      case RatingFilter.rating5:
        return 5;
    }
  }

  IconData get icon {
    switch (this) {
      case RatingFilter.all:
        return Icons.star_border_rounded;
      case RatingFilter.rating1:
      case RatingFilter.rating2:
      case RatingFilter.rating3:
      case RatingFilter.rating4:
      case RatingFilter.rating5:
        return Icons.star_rounded;
    }
  }
}