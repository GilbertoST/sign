import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sign.dart';
import '../../services/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_surface.dart';

class SignsListScreen extends StatefulWidget {
  const SignsListScreen({super.key});

  @override
  State<SignsListScreen> createState() => _SignsListScreenState();
}

class _SignsListScreenState extends State<SignsListScreen> {
  List<Sign> _signs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedDifficulty = 0; // 0 = tous, 1, 2, 3

  @override
  void initState() {
    super.initState();
    _loadSigns();
  }

  Future<void> _loadSigns() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final signs = await authProvider.apiService.getSigns();
      setState(() {
        _signs = signs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  List<Sign> get _filteredSigns {
    return _signs.where((sign) {
      final matchesSearch = _searchQuery.isEmpty ||
          sign.letter.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDifficulty =
          _selectedDifficulty == 0 || sign.difficulty == _selectedDifficulty;
      return matchesSearch && matchesDifficulty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet des Signes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSigns,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.page,
              AppTheme.spaceXs,
              AppTheme.page,
              AppTheme.spaceXs,
            ),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une lettre...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.spaceSm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _DifficultyChip(
                        label: 'Tous',
                        color: AppTheme.primaryColor,
                        selected: _selectedDifficulty == 0,
                        onSelected: () {
                          setState(() => _selectedDifficulty = 0);
                        },
                      ),
                      const SizedBox(width: AppTheme.spaceXs),
                      _DifficultyChip(
                        label: 'Facile',
                        color: AppTheme.successColor,
                        selected: _selectedDifficulty == 1,
                        onSelected: () {
                          setState(() {
                            _selectedDifficulty = _selectedDifficulty == 1 ? 0 : 1;
                          });
                        },
                      ),
                      const SizedBox(width: AppTheme.spaceXs),
                      _DifficultyChip(
                        label: 'Moyen',
                        color: AppTheme.secondaryColor,
                        selected: _selectedDifficulty == 2,
                        onSelected: () {
                          setState(() {
                            _selectedDifficulty = _selectedDifficulty == 2 ? 0 : 2;
                          });
                        },
                      ),
                      const SizedBox(width: AppTheme.spaceXs),
                      _DifficultyChip(
                        label: 'Difficile',
                        color: AppTheme.errorColor,
                        selected: _selectedDifficulty == 3,
                        onSelected: () {
                          setState(() {
                            _selectedDifficulty = _selectedDifficulty == 3 ? 0 : 3;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSigns.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun signe trouvé',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.page,
                          AppTheme.spaceXs,
                          AppTheme.page,
                          AppTheme.page,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width < 360 ? 3 : 4,
                          crossAxisSpacing: AppTheme.spaceSm,
                          mainAxisSpacing: AppTheme.spaceSm,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: _filteredSigns.length,
                        itemBuilder: (context, index) {
                          final sign = _filteredSigns[index];
                          return _SignCard(
                            sign: sign,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/sign-detail',
                                arguments: sign,
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onSelected;

  const _DifficultyChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: color.withValues(alpha: 0.14),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: selected ? color : Theme.of(context).colorScheme.onSurface,
      ),
      side: BorderSide(
        color: selected ? color.withValues(alpha: 0.55) : AppTheme.line(context),
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _SignCard extends StatelessWidget {
  final Sign sign;
  final VoidCallback onTap;

  const _SignCard({
    required this.sign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.difficultyColor(sign.difficulty);

    return AppSurface(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                sign.letter,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 1,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            color: color.withValues(alpha: 0.12),
            child: Text(
              sign.difficultyLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
