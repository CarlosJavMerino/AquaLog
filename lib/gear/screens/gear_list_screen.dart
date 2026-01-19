import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/gear_list_bloc.dart';
import '../bloc/gear_list_event.dart';
import '../bloc/gear_list_state.dart';
import '../repository/gear_repository.dart';
import '../models/gear_model.dart';
import 'add_gear_screen.dart';

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color cardColor = Color(0xFF112240);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;
const Color warningColor = Colors.orangeAccent;

class GearListScreen extends StatelessWidget {
  const GearListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection:
    // We create the GearListBloc here and immediately request the data subscription.
    // This creates a scoped BLoC that will be disposed of automatically when the screen is closed.
    return BlocProvider(
      create: (context) => GearListBloc(gearRepository: GearRepository())
        ..add(const GearListSubscriptionRequested()),
      child: const GearListView(),
    );
  }
}

class GearListView extends StatelessWidget {
  const GearListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: primaryColor),
        onPressed: () {
          Navigator.of(context).push(AddGearScreen.route());
        },
      ),
      body: BlocBuilder<GearListBloc, GearListState>(
        builder: (context, state) {
          if (state.status == GearListStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: accentColor));
          }
          
          if (state.items.isEmpty) {
            return const Center(
              child: Text(
                'Your gear locker is empty.\nAdd your equipment!',
                textAlign: TextAlign.center,
                style: TextStyle(color: hintColor, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _GearCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _GearCard extends StatelessWidget {
  final GearItem item;
  const _GearCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Maintenance Logic:
    // Check if the item requires service based on the last service date.
    final bool needsService = item.needsService;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        // Trigger deletion event in the BLoC
        context.read<GearListBloc>().add(GearListDeleted(item.id));
      },
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.only(bottom: 12),
        // Visual indicator: Orange border if service is needed
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: needsService 
              ? const BorderSide(color: warningColor, width: 2) 
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Product Image (Web URL or Fallback Icon)
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: primaryColor,
                ),
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!, 
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: accentColor.withOpacity(0.5)),
                        ),
                      )
                    : Icon(Icons.scuba_diving, color: accentColor.withOpacity(0.5), size: 40),
              ),
              const SizedBox(width: 16),
              
              // Item Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.model,
                      style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      item.brand,
                      style: const TextStyle(color: accentColor, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    
                    // Service Status Indicator
                    if (item.lastServiceDate != null)
                      Row(
                        children: [
                          Icon(
                            needsService ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            size: 14,
                            color: needsService ? warningColor : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Service: ${DateFormat('MM/yy').format(item.lastServiceDate!)}',
                            style: TextStyle(
                              color: needsService ? warningColor : hintColor,
                              fontSize: 12,
                              fontWeight: needsService ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}