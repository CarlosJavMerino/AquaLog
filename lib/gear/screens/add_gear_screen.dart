import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// BLoC & Repositories
import '../repository/gear_repository.dart';
import '../services/gear_search_service.dart';
import '../bloc/add_gear_bloc.dart';
import '../bloc/add_gear_event.dart';
import '../bloc/add_gear_state.dart';
import '../bloc/gear_search_bloc.dart';
import '../bloc/gear_search_event.dart';
import '../bloc/gear_search_state.dart';
import '../models/gear_model.dart';

// UI Constants
const Color primaryColor = Color(0xFF0A192F);
const Color accentColor = Color(0xFF48E3D4);
const Color cardColor = Color(0xFF112240);
const Color textColor = Colors.white;
const Color hintColor = Colors.white54;

class AddGearScreen extends StatelessWidget {
  const AddGearScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const AddGearScreen());
  }

  @override
  Widget build(BuildContext context) {
    // DEPENDENCY INJECTION:
    // This screen requires two distinct BLoCs:
    // 1. GearSearchBloc: Handles external API calls (Google Search).
    // 2. AddGearBloc: Handles the local form state and Firestore submission.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GearSearchBloc(
            searchService: RepositoryProvider.of<GearSearchService>(context),
          ),
        ),
        BlocProvider(
          create: (context) => AddGearBloc(
            gearRepository: RepositoryProvider.of<GearRepository>(context),
          ),
        ),
      ],
      child: const _AddGearView(),
    );
  }
}

class _AddGearView extends StatelessWidget {
  const _AddGearView();

  @override
  Widget build(BuildContext context) {
    // LISTENER: Handles side effects like Navigation and Snackbars
    return BlocListener<AddGearBloc, AddGearState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == GearFormStatus.submissionSuccess) {
          Navigator.of(context).pop();
        }
        if (state.status == GearFormStatus.submissionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.errorMessage}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: cardColor,
          title: const Text('Add New Gear', style: TextStyle(color: textColor)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION 1: AUTO-FILL SEARCH
              const Text('Quick Search (Auto-fill)', 
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const _WebSearchSection(), 
              
              const Divider(color: hintColor, height: 40),

              // SECTION 2: GEAR DETAILS
              const Text('Gear Details', 
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const _GearImagePreview(),
              const SizedBox(height: 16),
              const _BrandInput(),
              const SizedBox(height: 16),
              const _ModelInput(),
              const SizedBox(height: 16),
              const _CategoryDropdown(),
              
              const SizedBox(height: 24),
              const Text('Maintenance Schedule', 
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Row(
                children: const [
                   Expanded(child: _PurchaseDateInput()),
                   SizedBox(width: 12),
                   Expanded(child: _ServiceDateInput()),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION 3: ACTION
              const _SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SUB-WIDGETS ---

class _WebSearchSection extends StatelessWidget {
  const _WebSearchSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input
        TextField(
          style: const TextStyle(color: textColor),
          decoration: _inputDeco('e.g. Mares Puck Pro, Apeks XTX50...').copyWith(
             suffixIcon: const Icon(Icons.search, color: accentColor),
          ),
          onChanged: (value) {
            // Trigger search only if length > 3 to save API calls
            if (value.length > 3) {
               context.read<GearSearchBloc>().add(GearSearchQueryChanged(value));
            } else if (value.isEmpty) {
               context.read<GearSearchBloc>().add(GearSearchClear());
            }
          },
        ),
        const SizedBox(height: 8),

        // Horizontal Results List
        BlocBuilder<GearSearchBloc, GearSearchState>(
          builder: (context, state) {
            if (state.status == SearchStatus.loading) {
              return const LinearProgressIndicator(color: accentColor);
            }
            if (state.results.isNotEmpty) {
              return Container(
                height: 140,
                margin: const EdgeInsets.only(top: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.results.length,
                  itemBuilder: (context, index) {
                    final result = state.results[index];
                    return GestureDetector(
                      onTap: () {
                        // CROSS-BLOC COMMUNICATION:
                        // Selecting a search result triggers an event in the Form BLoC (AddGearBloc)
                        // to auto-populate the fields.
                        context.read<AddGearBloc>().add(AddGearAutoFilled(result));
                        
                        // Clear search results after selection
                        context.read<GearSearchBloc>().add(GearSearchClear());
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: hintColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: result.imageUrl != null 
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                    child: Image.network(result.imageUrl!, fit: BoxFit.cover, width: double.infinity),
                                  )
                                : const Icon(Icons.image_not_supported, color: hintColor, size: 40),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                result.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: textColor, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }
}

class _GearImagePreview extends StatelessWidget {
  const _GearImagePreview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddGearBloc, AddGearState>(
      builder: (context, state) {
        if (state.imageUrl.isEmpty) return const SizedBox.shrink();
        
        return Center(
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(state.imageUrl, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }
}

class _BrandInput extends StatefulWidget {
  const _BrandInput();

  @override
  State<_BrandInput> createState() => _BrandInputState();
}

class _BrandInputState extends State<_BrandInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<AddGearBloc>().state.brand,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // REACTIVE FORM SYNC:
    // We listen to the state changes (e.g., from auto-fill).
    // We update the controller ONLY if the value is different to avoid
    // resetting the cursor position while the user is typing.
    return BlocListener<AddGearBloc, AddGearState>(
      listenWhen: (previous, current) => previous.brand != current.brand,
      listener: (context, state) {
        if (_controller.text != state.brand) {
          _controller.text = state.brand;
          _controller.selection = TextSelection.fromPosition(
             TextPosition(offset: _controller.text.length),
          );
        }
      },
      child: TextFormField(
        controller: _controller,
        onChanged: (v) => context.read<AddGearBloc>().add(AddGearBrandChanged(v)),
        style: const TextStyle(color: textColor),
        decoration: _inputDeco('Brand (e.g., Mares)'),
      ),
    );
  }
}

class _ModelInput extends StatefulWidget {
  const _ModelInput();

  @override
  State<_ModelInput> createState() => _ModelInputState();
}

class _ModelInputState extends State<_ModelInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<AddGearBloc>().state.model,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddGearBloc, AddGearState>(
      listenWhen: (previous, current) => previous.model != current.model,
      listener: (context, state) {
        if (_controller.text != state.model) {
          _controller.text = state.model;
          _controller.selection = TextSelection.fromPosition(
             TextPosition(offset: _controller.text.length),
          );
        }
      },
      child: TextFormField(
        controller: _controller,
        onChanged: (v) => context.read<AddGearBloc>().add(AddGearModelChanged(v)),
        style: const TextStyle(color: textColor),
        decoration: _inputDeco('Model'),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddGearBloc, AddGearState>(
      builder: (context, state) {
        return DropdownButtonFormField<GearCategory>(
          value: state.category,
          dropdownColor: cardColor,
          style: const TextStyle(color: textColor),
          decoration: _inputDeco('Category'),
          items: GearCategory.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(cat.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (cat) {
            if (cat != null) context.read<AddGearBloc>().add(AddGearCategoryChanged(cat));
          },
        );
      },
    );
  }
}

class _PurchaseDateInput extends StatelessWidget {
  const _PurchaseDateInput();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddGearBloc, AddGearState>(
      builder: (context, state) {
        return _DateButton(
          label: 'Purchase Date',
          date: state.purchaseDate,
          onPressed: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (d != null) {
              context.read<AddGearBloc>().add(AddGearPurchaseDateChanged(d));
            }
          },
        );
      },
    );
  }
}

class _ServiceDateInput extends StatelessWidget {
  const _ServiceDateInput();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddGearBloc, AddGearState>(
      builder: (context, state) {
        return _DateButton(
          label: 'Last Service',
          date: state.lastServiceDate,
          onPressed: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (d != null) {
              context.read<AddGearBloc>().add(AddGearServiceDateChanged(d));
            }
          },
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddGearBloc, AddGearState>(
      builder: (context, state) {
        if (state.status == GearFormStatus.submissionInProgress) {
          return const Center(child: CircularProgressIndicator(color: accentColor));
        }
        return ElevatedButton(
          onPressed: () => context.read<AddGearBloc>().add(const AddGearSubmitted()),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Add to Closet', 
              style: TextStyle(color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
        );
      },
    );
  }
}

// --- VISUAL HELPERS ---

InputDecoration _inputDeco(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: hintColor),
    filled: true,
    fillColor: cardColor,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: hintColor)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: accentColor)),
  );
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPressed;
  const _DateButton({required this.label, this.date, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          border: Border.all(color: hintColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: hintColor, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              date != null ? DateFormat('MM/dd/yy').format(date!) : '-',
              style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}