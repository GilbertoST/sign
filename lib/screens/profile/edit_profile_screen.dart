import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../../services/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _profilePictureUrlController;
  bool _isLoading = false;
  File? _pickedImageFile;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    _usernameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email);
    _bioController = TextEditingController(text: user.bio ?? '');
    _profilePictureUrlController = TextEditingController(text: user.profilePictureUrl ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _profilePictureUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      await authProvider.apiService.updateUserProfile(
        authProvider.currentUser!.id,
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        profilePictureUrl: _profilePictureUrlController.text.trim().isEmpty 
            ? null 
            : _profilePictureUrlController.text.trim(),
      );

      // Mettre à jour l'utilisateur dans le provider
      await authProvider.loadCurrentUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil mis à jour !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Photo de profil + bouton importer
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _pickedImageFile != null
                              ? FileImage(_pickedImageFile!)
                              : (_profilePictureUrlController.text.isNotEmpty && 
                                 _profilePictureUrlController.text.startsWith('/') &&
                                 File(_profilePictureUrlController.text).existsSync()
                                  ? FileImage(File(_profilePictureUrlController.text)) as ImageProvider
                                  : (user.profilePictureUrl != null && 
                                     user.profilePictureUrl!.startsWith('/') &&
                                     File(user.profilePictureUrl!).existsSync()
                                      ? FileImage(File(user.profilePictureUrl!)) as ImageProvider
                                      : (user.profilePictureUrl != null && 
                                         user.profilePictureUrl!.startsWith('http')
                                          ? NetworkImage(user.profilePictureUrl!) as ImageProvider
                                          : null))),
                          child: _pickedImageFile == null &&
                                  (_profilePictureUrlController.text.isEmpty || 
                                   !_profilePictureUrlController.text.startsWith('/') ||
                                   !File(_profilePictureUrlController.text).existsSync()) &&
                                  (user.profilePictureUrl == null ||
                                   (!user.profilePictureUrl!.startsWith('/') && 
                                    !user.profilePictureUrl!.startsWith('http')))
                              ? Text(
                                  user.username[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 40),
                                )
                              : null,
                        ),
                        FloatingActionButton.small(
                          heroTag: 'pick_profile_image',
                          onPressed: () async {
                            try {
                              // Sur Android 13+, image_picker gère les permissions automatiquement
                              // On ne demande permission que pour Android < 13 (storage)
                              if (Theme.of(context).platform == TargetPlatform.android) {
                                // Pour Android < 13, demander permission storage
                                // Pour Android 13+, image_picker le fait automatiquement
                                final storageStatus = await Permission.storage.status;
                                if (storageStatus.isDenied) {
                                  final result = await Permission.storage.request();
                                  if (result.isDenied || result.isPermanentlyDenied) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Permission nécessaire pour accéder aux fichiers'),
                                          backgroundColor: Colors.orange,
                                          action: SnackBarAction(
                                            label: 'Paramètres',
                                            onPressed: openAppSettings,
                                          ),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                }
                              } else {
                                // Pour iOS, vérifier et demander si nécessaire
                                final photosStatus = await Permission.photos.status;
                                if (photosStatus.isDenied) {
                                  final result = await Permission.photos.request();
                                  if (result.isDenied || result.isPermanentlyDenied) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Permission nécessaire pour accéder aux photos'),
                                          backgroundColor: Colors.orange,
                                          action: SnackBarAction(
                                            label: 'Paramètres',
                                            onPressed: openAppSettings,
                                          ),
                                        ),
                                      );
                                    }
                                    return;
                                  }
                                }
                              }

                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );
                              
                              if (picked != null) {
                                // Copier l'image dans le répertoire de l'app pour persistance
                                final appDir = await getApplicationDocumentsDirectory();
                                final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                final savedImage = File(path.join(appDir.path, fileName));
                                await File(picked.path).copy(savedImage.path);
                                
                                setState(() {
                                  _pickedImageFile = savedImage;
                                  // Stocker le chemin local pour persistance
                                  _profilePictureUrlController.text = savedImage.path;
                                });
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Icon(Icons.photo_library),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nom d\'utilisateur',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        if (value.length < 3) {
                          return 'Minimum 3 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: 'Bio (optionnel)',
                        hintText: 'Parlez-nous de vous...',
                        prefixIcon: const Icon(Icons.notes),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      maxLength: 200,
                    ),
                    const SizedBox(height: 24),

                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Enregistrer les modifications'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}




