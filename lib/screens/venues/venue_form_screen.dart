import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/enums/venue_category.dart';
import 'package:blok34_mobile/widgets/glass_text_field.dart';
import 'package:blok34_mobile/widgets/glass_dropdown.dart';
import 'package:blok34_mobile/utils/text_formatter.dart';
import 'package:blok34_mobile/services/venue_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class VenueFormScreen extends StatefulWidget {
  final Venue? venue;

  const VenueFormScreen({super.key, this.venue});

  @override
  State<VenueFormScreen> createState() => _VenueFormScreenState();
}

class _VenueFormScreenState extends State<VenueFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  VenueCategory? _selectedCategory;
  bool _isPublic = true;
  String? _bannerUrl; // Only store the Firebase URL, not local path
  bool _isLoading = false;
  bool _isUploadingImage = false;
  final VenueService _venueService = VenueService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadVenueData();
  }

  void _loadVenueData() {
    if (widget.venue != null) {
      _nameController.text = widget.venue!.name;
      _descriptionController.text = widget.venue!.description;
      _addressController.text = widget.venue!.address;
      _phoneController.text = widget.venue!.phone;
      _selectedCategory = widget.venue!.category;
      _isPublic = widget.venue!.isPublic;
      _bannerUrl = widget.venue!.bannerPath; // Load existing banner URL
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<String?> _uploadBannerImage(File imageFile) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('venue_banners')
          .child(userId)
          .child('banner_$timestamp.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading banner: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload banner: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _pickBannerImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _isLoading = true;
          _isUploadingImage = true;
          // DON'T set _bannerPath here - it's a local file path, not a URL!
          // _bannerPath = pickedFile.path; // REMOVE THIS LINE
        });

        final file = File(pickedFile.path);
        final uploadedUrl = await _uploadBannerImage(file);

        if (uploadedUrl != null && mounted) {
          setState(() {
            _bannerUrl = uploadedUrl;  // Only set the URL after upload
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Banner uploaded successfully!'),
              backgroundColor: Colors.green.shade400,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error picking banner: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final isEditing = widget.venue != null;
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          throw Exception('User not logged in');
        }

        if (isEditing) {
          // Update existing venue
          final updatedVenue = Venue(
            id: widget.venue!.id,
            name: _nameController.text,
            category: _selectedCategory!,
            description: _descriptionController.text,
            address: _addressController.text,
            bannerPath: _bannerUrl ?? widget.venue!.bannerPath, // Use the uploaded URL
            phone: _phoneController.text,
            isPublic: _isPublic,
            venueManagerId: widget.venue!.venueManagerId,
          );

          await _venueService.updateVenue(updatedVenue);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Venue updated successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
              ),
            );
            Navigator.pop(context, updatedVenue);
          }
        } else {
          // Create new venue
          final newVenue = Venue(
            id: '', // Will be set by Firestore
            name: _nameController.text,
            category: _selectedCategory!,
            description: _descriptionController.text,
            address: _addressController.text,
            bannerPath: _bannerUrl, // This will be the Firebase Storage URL
            phone: _phoneController.text,
            isPublic: _isPublic,
            venueManagerId: currentUser.uid,
          );

          await _venueService.insertVenue(newVenue);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Venue created successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
              ),
            );
            Navigator.pop(context, newVenue);
          }
        }
      } catch (e) {
        print('Error submitting form: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3E),
        title: const Text(
          'Delete Venue',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.venue?.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.cyan.shade200),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                await _venueService.deleteVenue(widget.venue!.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Venue deleted successfully!'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                    ),
                  );
                  Navigator.pop(context, null);
                }
              } catch (e) {
                print('Error deleting venue: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting venue: ${e.toString()}'),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red.shade200),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.venue != null;
    final screenTitle = isEditing ? "Edit Venue" : "Create Venue";
    final buttonText = isEditing ? "Save Changes" : "Create Venue";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F1A),
              Color(0xFF1A1A3E),
              Color(0xFF2D1B69),
              Color(0xFF4A0E4E),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.cyan.shade400.withValues(alpha: 0.15),
                          Colors.blue.shade600.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.cyan.shade400.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      screenTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Display banner image if URL exists
                    if (_bannerUrl != null && _bannerUrl!.isNotEmpty)
                      Image.network(
                        _bannerUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(
                            Icons.store,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                      ),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            const Color(0xFF0F0F1A).withValues(alpha: 0.9),
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                    // Upload button
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: GestureDetector(
                        onTap: _isUploadingImage ? null : _pickBannerImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.cyan.shade400.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.cyan.shade400.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isUploadingImage)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.cyan),
                                  ),
                                )
                              else
                                Icon(
                                  _bannerUrl != null ? Icons.edit : Icons.cloud_upload,
                                  size: 14,
                                  color: Colors.cyan.shade200,
                                ),
                              const SizedBox(width: 6),
                              Text(
                                _isUploadingImage
                                    ? "Uploading..."
                                    : (_bannerUrl != null ? "Change banner" : "Tap to add banner"),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.cyan.shade200,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Loading overlay
                    if (_isLoading || _isUploadingImage)
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Venue Name
                      GlassTextField(
                        controller: _nameController,
                        label: "Venue Name",
                        icon: Icons.store,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a venue name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Category Dropdown
                      GlassDropdown<VenueCategory>(
                        label: "Category",
                        icon: Icons.category,
                        value: _selectedCategory,
                        items: VenueCategory.values,
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please select a category";
                          }
                          return null;
                        },
                        itemLabelBuilder: (category) {
                          return TextFormatter.formatCategoryName(category.toString().split('.').last);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Address
                      GlassTextField(
                        controller: _addressController,
                        label: "Address",
                        icon: Icons.location_on,
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter an address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Phone
                      GlassTextField(
                        controller: _phoneController,
                        label: "Phone Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Description
                      GlassTextField(
                        controller: _descriptionController,
                        label: "Description",
                        icon: Icons.description,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter a description";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Public/Private Toggle
                      Opacity(
                        opacity: isEditing ? 0.7 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.08),
                                Colors.white.withValues(alpha: 0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isPublic
                                      ? Colors.cyan.shade400.withValues(alpha: 0.15)
                                      : Colors.purple.shade400.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _isPublic
                                        ? Colors.cyan.shade400.withValues(alpha: 0.3)
                                        : Colors.purple.shade400.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Icon(
                                  _isPublic ? Icons.public : Icons.lock,
                                  size: 20,
                                  color: _isPublic ? Colors.cyan.shade200 : Colors.purple.shade200,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isPublic ? "Public Venue" : "Private Venue",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      isEditing
                                          ? "Venue type may only be set upon creation."
                                          : (_isPublic
                                          ? "Anyone may create events at this venue."
                                          : "Only you may create events at this venue."),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isPublic,
                                onChanged: isEditing ? null : (value) {
                                  setState(() {
                                    _isPublic = value;
                                  });
                                },
                                activeThumbColor: Colors.cyan.shade300,
                                activeTrackColor: Colors.cyan.shade400.withValues(alpha: 0.3),
                                inactiveThumbColor: Colors.purple.shade300,
                                inactiveTrackColor: Colors.purple.shade400.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      _isLoading && !_isUploadingImage
                          ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.cyan.shade200),
                        ),
                      )
                          : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.cyan.shade400.withValues(alpha: 0.2),
                              Colors.purple.shade400.withValues(alpha: 0.2),
                              Colors.blue.shade400.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.cyan.shade400.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _submitForm,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEditing ? Icons.save : Icons.add_business,
                                    color: Colors.cyan.shade200,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    buttonText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.cyan.shade200,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Delete Button (only for editing mode)
                      if (isEditing) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.red.shade400.withValues(alpha: 0.15),
                                Colors.red.shade600.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red.shade400.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _confirmDelete,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade200,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Delete Venue",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade200,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}