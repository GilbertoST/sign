import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sign.dart';
import '../../services/auth_provider.dart';

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
          // Barre de recherche et filtres
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher une lettre...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Tous'),
                        selected: _selectedDifficulty == 0,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDifficulty = 0;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Facile'),
                        selected: _selectedDifficulty == 1,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDifficulty = selected ? 1 : 0;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Moyen'),
                        selected: _selectedDifficulty == 2,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDifficulty = selected ? 2 : 0;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Difficile'),
                        selected: _selectedDifficulty == 3,
                        onSelected: (selected) {
                          setState(() {
                            _selectedDifficulty = selected ? 3 : 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des signes
            Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSigns.isEmpty
                    ? const Center(
                        child: Text('Aucun signe trouvé'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width < 360 ? 3 : 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
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

class _SignCard extends StatelessWidget {
  final Sign sign;
  final VoidCallback onTap;

  const _SignCard({
    required this.sign,
    required this.onTap,
  });

  Color _getDifficultyColor() {
    switch (sign.difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    sign.letter,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _getDifficultyColor().withOpacity(0.2),
              ),
              child: Text(
                sign.difficultyLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getDifficultyColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
