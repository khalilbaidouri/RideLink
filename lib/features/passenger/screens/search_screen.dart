import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ride_link/features/passenger/providers/search_results_provider.dart';
import 'package:ride_link/features/passenger/widgets/search/search_app_bar.dart';
import 'package:ride_link/features/passenger/widgets/search/search_result_card.dart';
import 'package:ride_link/features/passenger/widgets/search/no_rides_found.dart';
import 'package:ride_link/features/passenger/providers/search_ride_notifier.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final resultsAsync = ref.watch(searchResultsProvider);
    return Scaffold(
      appBar: SearchAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchFilterHeaderDelegate(
              child: Container(
                color: colors.surface,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: const _SearchFilterRow(),
              ),
            ),
          ),
          ...resultsAsync.when(
            data: (results) {
              return [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '${results.length} rides found',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                if (results.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: NoRidesFound(
                      onClearFilters: () {
                        // Reset tout : villes, date, tri
                        ref.read(searchRideProvider.notifier).reset();
                        ref.read(searchSortProvider.notifier).state =
                            const SearchSortState(
                                orderBy: SearchOrderBy.time, ascending: true);
                      },
                      onSearchAgain: () =>
                          ref.invalidate(searchResultsProvider),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index.isOdd) {
                            return const SizedBox(height: 12);
                          }
                          final itemIndex = index ~/ 2;
                          final result = results[itemIndex];
                          return SearchResultCard(
                            result: result,
                            onTap: () => context.push(
                              '/passenger/ride/${result.id}',
                              extra: result,
                            ),
                          );
                        },
                        childCount:
                            results.isEmpty ? 0 : (results.length * 2 - 1),
                      ),
                    ),
                  ),
              ];
            },
            loading: () => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colors.primary,
                  ),
                ),
              ),
            ],
            error: (_, __) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Unable to load rides right now.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchFilterRow extends ConsumerWidget {
  const _SearchFilterRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final sort = ref.watch(searchSortProvider);

    void updateSort(SearchOrderBy orderBy) {
      final current = ref.read(searchSortProvider);
      if (current.orderBy == orderBy) {
        ref.read(searchSortProvider.notifier).state = current.copyWith(
          ascending: !current.ascending,
        );
      } else {
        ref.read(searchSortProvider.notifier).state = current.copyWith(
          orderBy: orderBy,
          ascending: true,
        );
      }
    }

    return Row(
      children: [
        _FilterChip(
          label: 'Price',
          isActive: sort.orderBy == SearchOrderBy.price,
          isAscending: sort.ascending,
          onTap: () => updateSort(SearchOrderBy.price),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Time',
          isActive: sort.orderBy == SearchOrderBy.time,
          isAscending: sort.ascending,
          onTap: () => updateSort(SearchOrderBy.time),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Rating',
          isActive: sort.orderBy == SearchOrderBy.rating,
          isAscending: sort.ascending,
          onTap: () => updateSort(SearchOrderBy.rating),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.tune,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.isAscending,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final bool isAscending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background =
        isActive ? colors.primary : colors.surfaceContainerHighest;
    final foreground = isActive ? colors.onPrimary : colors.onSurface;
    final border = isActive ? colors.primary : colors.outlineVariant;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: foreground,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SearchFilterHeaderDelegate({required this.child});

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SearchFilterHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
