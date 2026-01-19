import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoC & Repositories
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../dives/bloc/logbook_bloc.dart';
import '../dives/bloc/logbook_event.dart';
import '../dives/bloc/logbook_state.dart';
import '../dives/repository/dive_repository.dart';
import '../dives/models/dive_model.dart';

// Screens
import 'add_dive_screen.dart';
import 'dive_detail_screen.dart';
import 'global_map_screen.dart';
import '../gear/screens/gear_list_screen.dart';
import '../weather/screens/weather_screen.dart';

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color cardColor = Color(0xFF112240);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    // Dependency Injection:
    // Providing LogbookBloc here ensures both the Map and the List 
    // share the exact same state and data source.
    return BlocProvider(
      create: (context) => LogbookBloc(
        diveRepository: RepositoryProvider.of<DiveRepository>(context),
      )..add(const LogbookSubscriptionRequested()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text(
          _getTitle(_currentIndex),
          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: accentColor),
            // Triggers the Logout event handled by AuthBloc (Global Scope)
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      
      // ARCHITECTURAL NOTE: 
      // Using IndexedStack preserves the state of the pages (especially the Map).
      // If we used a simple switch, the map would reload (costing API quota) every tab switch.
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _GlobalMapWrapper(), // Tab 0: Map
          _DiveLogbookContent(), // Tab 1: List (Logbook)
          GearListScreen(),      // Tab 2: Gear
          WeatherScreen(),       // Tab 3: Weather
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed, // Required for 4+ items
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Logbook'),
          BottomNavigationBarItem(icon: Icon(Icons.scuba_diving), label: 'Gear'),
          BottomNavigationBarItem(icon: Icon(Icons.sunny), label: 'Weather'),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Global Map';
      case 1: return 'My Logbook';
      case 2: return 'My Gear';
      case 3: return 'Conditions';
      default: return 'AquaLog';
    }
  }
}

// --- SUB-WIDGETS (Private implementation for this screen) ---

/// Wrapper to connect the Map Screen with the BLoC State
class _GlobalMapWrapper extends StatelessWidget {
  const _GlobalMapWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogbookBloc, LogbookState>(
      builder: (context, state) {
        // The GlobalMapScreen receives the list of dives directly from the BLoC
        return GlobalMapScreen(dives: state.dives);
      },
    );
  }
}

/// The main content of the "Logbook" tab (List View)
class _DiveLogbookContent extends StatelessWidget {
  const _DiveLogbookContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits from parent
      floatingActionButton: FloatingActionButton(
        heroTag: 'addDiveBtn',
        backgroundColor: accentColor,
        child: const Icon(Icons.add, color: primaryColor),
        onPressed: () => Navigator.of(context).push(AddDiveScreen.route()),
      ),
      body: BlocBuilder<LogbookBloc, LogbookState>(
        builder: (context, state) {
          if (state.status == LogbookStatus.loading || state.status == LogbookStatus.initial) {
            return const Center(child: CircularProgressIndicator(color: accentColor));
          }
          
          if (state.dives.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.waves, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    'No dives recorded yet.\nTap + to add your first immersion!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: hintColor, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.dives.length,
            itemBuilder: (context, index) {
              final dive = state.dives[index];
              return _DiveCard(dive: dive);
            },
          );
        },
      ),
    );
  }
}

/// A card representing a single dive in the list
class _DiveCard extends StatelessWidget {
  final Dive dive;
  const _DiveCard({required this.dive});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('MMM dd, yyyy').format(dive.date);

    return Dismissible(
      key: Key('dive_${dive.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        // Simple confirmation logic could be added here (Dialog)
        return true; 
      },
      onDismissed: (_) {
        // Trigger the BLoC event to delete the dive from Firestore
        context.read<LogbookBloc>().add(LogbookDiveDeleted(dive.id));
      },
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(DiveDetailScreen.route(dive)),
        child: Card(
          color: cardColor,
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Leading Icon (Visual indicator)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.scuba_diving, color: accentColor),
                ),
                const SizedBox(width: 16),
                
                // Dive Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dive.place, 
                        style: const TextStyle(
                          color: textColor, 
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 14, color: accentColor.withOpacity(0.7)),
                          Text(' ${dive.depth}m  ', style: const TextStyle(color: hintColor, fontSize: 13)),
                          Icon(Icons.timer, size: 14, color: accentColor.withOpacity(0.7)),
                          Text(' ${dive.time}min', style: const TextStyle(color: hintColor, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Date & Location Indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(dateFormatted, style: const TextStyle(color: hintColor, fontSize: 12)),
                    const SizedBox(height: 8),
                    if (dive.latitude != null) 
                      const Icon(Icons.location_pin, size: 16, color: Colors.redAccent)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}