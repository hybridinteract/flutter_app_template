import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/routes/route_names.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:app_template/core/utils/date_utils.dart';
import 'package:app_template/core/utils/formatters.dart';
import 'package:app_template/core/widgets/app_empty_widget.dart';
import 'package:app_template/core/widgets/app_error_widget.dart';
import 'package:app_template/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../controllers/booking_bloc.dart';
import '../controllers/booking_event.dart';
import '../controllers/booking_state.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(const LoadBookingsRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingTitle)),
      body: SafeArea(
        child: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingFailure) {
              context.showSnackBar(state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is BookingLoading) {
              return AppLoader(message: l10n.bookingLoading);
            }

            if (state is BookingFailure) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<BookingBloc>().add(
                    const LoadBookingsRequested(),
                  );
                },
              );
            }

            if (state is BookingSuccess) {
              if (state.bookings.isEmpty) {
                return AppEmptyWidget(
                  title: l10n.bookingEmptyTitle,
                  message: l10n.bookingEmptyMessage,
                  actionText: l10n.commonRefresh,
                  onAction: () {
                    context.read<BookingBloc>().add(
                      const LoadBookingsRequested(),
                    );
                  },
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    itemCount: state.bookings.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppDimensions.spacingMd),
                    itemBuilder: (context, index) {
                      final booking = state.bookings[index];
                      return Card(
                        elevation: AppDimensions.elevationLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(
                            AppDimensions.spacingMd,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: context.colorScheme.primary
                                .withValues(alpha: 0.1),
                            child: Icon(
                              Icons.calendar_today_outlined,
                              color: context.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            booking.title,
                            style: context.textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppDimensions.spacingXs),
                              Text(booking.description),
                              const SizedBox(height: AppDimensions.spacingXs),
                              Text(
                                AppDateUtils.formatDisplayDate(
                                  booking.bookingDate,
                                ),
                                style: context.textTheme.bodySmall,
                              ),
                              const SizedBox(height: AppDimensions.spacingXs),
                              Chip(
                                label: Text(
                                  booking.status.toUpperCase(),
                                  style: context.textTheme.labelSmall,
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                          // ListTile caps trailing height; keep it one line.
                          trailing: Text(
                            AppFormatters.currency(booking.price),
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            context.push(
                              RouteNames.bookingDetailsPath(booking.id),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
