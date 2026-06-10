import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// BLoC & Services
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../services/weather_service.dart';

// UI Constants
// NOTE: In a larger app, these should be part of a centralized AppTheme.
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color cardColor = Color(0xFF112240);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;
const Color warningColor = Colors.orangeAccent;
const Color successColor = Colors.greenAccent;

/// Entry point for the Weather feature.
/// 
/// This widget acts as a Dependency Injection container, providing the 
/// [WeatherBloc] and its required [WeatherService] to the widget tree.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(service: RepositoryProvider.of<WeatherService>(context),),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers the BLoC search event and dismisses the keyboard for better UX.
  void _search() {
    if (_controller.text.isNotEmpty) {
      FocusScope.of(context).unfocus(); 
      context.read<WeatherBloc>().add(WeatherSearchRequested(_controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inherits transparent background to overlay correctly on the Home TabView
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Search Bar Section ---
            TextField(
              controller: _controller,
              style: const TextStyle(color: textColor),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Zona de buceo (ej: Cabo de Palos)',
                hintStyle: const TextStyle(color: hintColor),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: accentColor),
                  onPressed: _search,
                ),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: accentColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Reactive Content Section ---
            Expanded(
              child: BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  // State 1: Initial (Prompt user)
                  if (state.status == WeatherStatus.initial) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.travel_explore, size: 80, color: Colors.white10),
                          SizedBox(height: 16),
                          Text(
                            'Introduce una localización para\nver el estado del viento y temperatura.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: hintColor, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  // State 2: Loading
                  if (state.status == WeatherStatus.loading) {
                    return const Center(child: CircularProgressIndicator(color: accentColor));
                  }

                  // State 3: Failure
                  if (state.status == WeatherStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(
                            'Ups, algo falló:\n${state.errorMessage}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    );
                  }

                  // State 4: Success (Render Data)
                  if (state.status == WeatherStatus.success && state.weather != null) {
                    final w = state.weather!;
                    
                    // Domain Logic:
                    // Determine if conditions are safe for diving.
                    // Threshold: Wind speed > 20 km/h is considered risky/choppy.
                    bool isWindy = w.windSpeed > 20.0;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // Location Header
                          Text(
                            w.cityName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: textColor, 
                              fontSize: 32, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Dynamic Icon based on WMO code
                          Icon(w.icon, size: 80, color: w.iconColor),
                          const SizedBox(height: 8),
                            Text(
                              w.description.toUpperCase(), 
                              style: TextStyle(
                                color: w.iconColor, 
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                letterSpacing: 1.2
                              )
                            ),
                          const Text(
                            'CONDICIONES ACTUALES',
                            style: TextStyle(color: accentColor, fontSize: 12, letterSpacing: 2),
                          ),
                          const SizedBox(height: 30),
                          
                          // Main Data Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isWindy ? warningColor : accentColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    // Column: Temperature
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          child: const Icon(Icons.thermostat, color: Colors.orangeAccent, size: 32),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '${w.temperature.toStringAsFixed(1)}°C', 
                                          style: const TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)
                                        ),
                                        const Text('Aire', style: TextStyle(color: hintColor)),
                                      ],
                                    ),
                                    
                                    // Vertical Divider
                                    Container(width: 1, height: 60, color: hintColor.withOpacity(0.2)),

                                    // Column: Wind
                                    Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius: BorderRadius.circular(50),
                                          ),
                                          child: const Icon(Icons.air, color: Colors.lightBlueAccent, size: 32),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          '${w.windSpeed.toStringAsFixed(1)} km/h', 
                                          style: const TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold)
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.explore, size: 14, color: hintColor),
                                            const SizedBox(width: 4),
                                            Text(w.windDirection, style: const TextStyle(color: hintColor)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                // Extra Data: Humidity
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Humedad Relativa: ${w.humidity}%', 
                                    style: const TextStyle(color: hintColor, fontSize: 14)
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Safety Advisory Banner
                                if (isWindy)
                                  _buildAdvisoryBanner(
                                    icon: Icons.warning_amber_rounded,
                                    color: warningColor,
                                    text: 'Atención: Viento considerable.\nEl mar podría estar picado.',
                                  )
                                else
                                  _buildAdvisoryBanner(
                                    icon: Icons.check_circle_outline_rounded,
                                    color: successColor,
                                    text: 'Viento suave.\nBuenas condiciones en superficie.',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build the bottom advisory banner inside the card
  Widget _buildAdvisoryBanner({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}