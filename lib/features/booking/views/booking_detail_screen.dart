import 'package:app_template/core/extensions/context_extensions.dart';
import 'package:app_template/core/l10n/l10n.dart';
import 'package:app_template/core/theme/app_dimensions.dart';
import 'package:app_template/core/utils/date_utils.dart';
import 'package:app_template/core/utils/formatters.dart';
import 'package:app_template/core/widgets/app_error_widget.dart';
import 'package:app_template/core/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controllers/booking_bloc.dart';
import '../controllers/booking_event.dart';
import '../controllers/booking_state.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.id});

  final String id;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(LoadBookingDetailsRequested(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingDetailsTitle)),
      body: SafeArea(
        child: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingFailure) {
              context.showSnackBar(state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is BookingLoading) {
              return AppLoader(message: l10n.bookingDetailsLoading);
            }

            if (state is BookingFailure) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<BookingBloc>().add(
                    LoadBookingDetailsRequested(widget.id),
                  );
                },
              );
            }

            if (state is BookingDetailSuccess) {
              final booking = state.booking;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.spacingLg),
                    child: Card(
                      elevation: AppDimensions.elevationLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.spacingLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    booking.title,
                                    style: context.textTheme.headlineMedium,
                                  ),
                                ),
                                Chip(label: Text(booking.status.toUpperCase())),
                              ],
                            ),
                            const Divider(height: AppDimensions.spacingXl),
                            Text(
                              l10n.bookingDescription,
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppDimensions.spacingSm),
                            Text(
                              booking.description.isNotEmpty
                                  ? booking.description
                                  : l10n.bookingNoDescription,
                              style: context.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppDimensions.spacingLg),
                            Text(
                              l10n.bookingDate,
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppDimensions.spacingSm),
                            Text(
                              AppDateUtils.formatDateTime(booking.bookingDate),
                              style: context.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppDimensions.spacingLg),
                            Text(
                              l10n.bookingTotalPrice,
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppDimensions.spacingSm),
                            Text(
                              AppFormatters.currency(booking.price),
                              style: context.textTheme.headlineMedium?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
