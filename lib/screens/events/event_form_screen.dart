import 'package:flutter/material.dart';
import 'package:blok34_mobile/models/event.dart';
import 'package:blok34_mobile/models/venue.dart';
import 'package:blok34_mobile/enums/event_category.dart';
import 'package:blok34_mobile/widgets/glass_text_field.dart';
import 'package:blok34_mobile/widgets/glass_dropdown.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;
  final List<Venue> venues;
  final String currentUserId;

  const EventFormScreen({
    super.key,
    this.event,
    required this.venues,
    required this.currentUserId,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  EventCategory? _selectedCategory;
  Venue? _selectedVenue;

  DateTime? _startDate;
  DateTime? _startTime;
  DateTime? _endDate;
  DateTime? _endTime;

  bool _hasEndDate = false;
  String? _bannerPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  void _loadEventData() {
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _selectedCategory = widget.event!.category;
      _startDate = widget.event!.startDate;
      _startTime = widget.event!.startDate;
      _hasEndDate = widget.event!.endDate != null;
      if (widget.event!.endDate != null) {
        _endDate = widget.event!.endDate;
        _endTime = widget.event!.endDate;
      }
      _bannerPath = widget.event!.bannerPath;

      _selectedVenue = widget.venues.firstWhere(
            (v) => v.id == widget.event!.venueId,
        orElse: () => widget.venues.first,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'concert': return 'Concert';
      case 'festival': return 'Festival';
      case 'party': return 'Party';
      case 'clubNight': return 'Club Night';
      case 'workshop': return 'Workshop';
      case 'conference': return 'Conference';
      case 'sports': return 'Sports';
      case 'theater': return 'Theater';
      case 'exhibition': return 'Exhibition';
      case 'other': return 'Other';
      default: return category;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  DateTime? _getCombinedStartDateTime() {
    if (_startDate == null || _startTime == null) return null;
    return DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );
  }

  DateTime? _getCombinedEndDateTime() {
    if (!_hasEndDate || _endDate == null || _endTime == null) return null;
    return DateTime(
      _endDate!.year,
      _endDate!.month,
      _endDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStartDate
        ? (_startDate ?? now)
        : (_endDate ?? (_startDate ?? now));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00BCD4),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A3E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1A1A3E),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startTime == null) {
            _startTime = DateTime(picked.year, picked.month, picked.day, DateTime.now().hour, DateTime.now().minute);
          } else {
            _startTime = DateTime(picked.year, picked.month, picked.day, _startTime!.hour, _startTime!.minute);
          }
        } else {
          // Validate end date against start date
          final startDateTime = _getCombinedStartDateTime();
          final tempTime = _endTime ?? DateTime(picked.year, picked.month, picked.day, 23, 0);
          final tempEndDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            tempTime.hour,
            tempTime.minute,
          );

          if (startDateTime != null && tempEndDateTime.isBefore(startDateTime)) {
            _showErrorSnackBar('End date cannot be before start date');
            return;
          }

          _endDate = picked;
          if (_endTime == null) {
            _endTime = DateTime(picked.year, picked.month, picked.day, 23, 0);
          } else {
            _endTime = DateTime(picked.year, picked.month, picked.day, _endTime!.hour, _endTime!.minute);
          }
        }
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay initialTime = isStartTime
        ? (_startTime != null ? TimeOfDay(hour: _startTime!.hour, minute: _startTime!.minute) : TimeOfDay.now())
        : (_endTime != null ? TimeOfDay(hour: _endTime!.hour, minute: _endTime!.minute) : const TimeOfDay(hour: 23, minute: 0));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00BCD4),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A3E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1A1A3E),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Color(0xFF1A1A3E),
              hourMinuteTextColor: Colors.white,
              dialHandColor: Color(0xFF00BCD4),
              dialBackgroundColor: Color(0xFF2D1B69),
              hourMinuteColor: Color(0xFF2D1B69),
              entryModeIconColor: Color(0xFF00BCD4),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          if (_startDate != null) {
            _startTime = DateTime(
              _startDate!.year,
              _startDate!.month,
              _startDate!.day,
              picked.hour,
              picked.minute,
            );
          } else {
            final now = DateTime.now();
            _startDate = now;
            _startTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
          }
        } else {
          // Validate end time against start time
          final baseDate = _endDate ?? _startDate ?? DateTime.now();
          final tempTime = DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            picked.hour,
            picked.minute,
          );

          final startDateTime = _getCombinedStartDateTime();

          if (startDateTime != null && tempTime.isBefore(startDateTime)) {
            _showErrorSnackBar('End time cannot be before start time');
            return;
          }

          if (_endDate != null) {
            _endTime = DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              picked.hour,
              picked.minute,
            );
          } else {
            final now = DateTime.now();
            _endDate = _startDate ?? now;
            _endTime = DateTime(
              _endDate!.year,
              _endDate!.month,
              _endDate!.day,
              picked.hour,
              picked.minute,
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.event != null;
    final screenTitle = isEditing ? "Edit Event" : "Create Event";
    final buttonText = isEditing ? "Save Changes" : "Create Event";

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
                    if (_bannerPath != null)
                      Image.network(
                        _bannerPath!,
                        fit: BoxFit.cover,
                      ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Color(0xFF0F0F1A).withValues(alpha: 0.9),
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: GestureDetector(
                        onTap: _pickBannerImage,
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
                              Icon(
                                _bannerPath != null ? Icons.edit : Icons.cloud_upload,
                                size: 14,
                                color: Colors.cyan.shade200,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _bannerPath != null ? "Change banner" : "Tap to add banner",
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
                      // Event Title
                      GlassTextField(
                        controller: _titleController,
                        label: "Event Title",
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter an event title";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Venue Dropdown
                      GlassDropdown<Venue>(
                        label: "Venue",
                        icon: Icons.location_city,
                        value: _selectedVenue,
                        items: widget.venues,
                        onChanged: (venue) {
                          setState(() {
                            _selectedVenue = venue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return "Please select a venue";
                          }
                          return null;
                        },
                        itemLabelBuilder: (venue) => venue.name,
                      ),
                      const SizedBox(height: 20),

                      // Category Dropdown
                      GlassDropdown<EventCategory>(
                        label: "Category",
                        icon: Icons.category,
                        value: _selectedCategory,
                        items: EventCategory.values,
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
                          return _formatCategoryName(category.toString().split('.').last);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Start Date & Time Section
                      Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan.shade400.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.cyan.shade400.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                    color: Colors.cyan.shade200,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Start Date & Time",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectDate(true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.date_range, size: 20, color: Colors.cyan.shade200),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _startDate != null ? _formatDate(_startDate!) : "Select Date",
                                              style: TextStyle(
                                                color: _startDate != null
                                                    ? Colors.white
                                                    : Colors.white.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.arrow_drop_down, color: Colors.cyan.shade200),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _selectTime(true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.access_time, size: 20, color: Colors.cyan.shade200),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _startTime != null ? _formatTime(_startTime!) : "Select Time",
                                              style: TextStyle(
                                                color: _startTime != null
                                                    ? Colors.white
                                                    : Colors.white.withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.arrow_drop_down, color: Colors.cyan.shade200),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // End Date Toggle
                      Container(
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
                                color: Colors.purple.shade400.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.purple.shade400.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                Icons.timer,
                                size: 20,
                                color: Colors.purple.shade200,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "End Date & Time",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Optional - Add an end time for your event",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _hasEndDate,
                              onChanged: (value) {
                                setState(() {
                                  _hasEndDate = value;
                                  if (!value) {
                                    _endDate = null;
                                    _endTime = null;
                                  }
                                });
                              },
                              activeColor: Colors.purple.shade300,
                              activeTrackColor: Colors.purple.shade400.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),

                      // End Date & Time Pickers (if enabled)
                      if (_hasEndDate) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.05),
                                Colors.white.withValues(alpha: 0.02),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectDate(false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.date_range, size: 20, color: Colors.purple.shade200),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _endDate != null ? _formatDate(_endDate!) : "Select Date",
                                                style: TextStyle(
                                                  color: _endDate != null
                                                      ? Colors.white
                                                      : Colors.white.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.arrow_drop_down, color: Colors.purple.shade200),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectTime(false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.1),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time, size: 20, color: Colors.purple.shade200),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _endTime != null ? _formatTime(_endTime!) : "Select Time",
                                                style: TextStyle(
                                                  color: _endTime != null
                                                      ? Colors.white
                                                      : Colors.white.withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ),
                                            Icon(Icons.arrow_drop_down, color: Colors.purple.shade200),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

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
                      const SizedBox(height: 32),

                      // Submit Button
                      _isLoading
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
                                    isEditing ? Icons.save : Icons.add,
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
                                      "Delete Event",
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

  Future<void> _pickBannerImage() async {
    // TODO: Implement image picker
    print("Pick banner image");
  }

  String? _validateForm() {
    final startDateTime = _getCombinedStartDateTime();
    final endDateTime = _getCombinedEndDateTime();

    if (startDateTime == null) {
      return "Please select start date and time";
    }

    if (startDateTime.isBefore(DateTime.now())) {
      return "Start date cannot be in the past";
    }

    if (_hasEndDate && endDateTime != null) {
      if (endDateTime.isBefore(startDateTime)) {
        return "End date must be after start date";
      }
      if (endDateTime.isBefore(DateTime.now())) {
        return "End date cannot be in the past";
      }
    }

    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final validationError = _validateForm();
      if (validationError != null) {
        _showErrorSnackBar(validationError);
        return;
      }

      setState(() => _isLoading = true);

      final isEditing = widget.event != null;

      if (isEditing) {
        final updatedEvent = Event(
          id: widget.event!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          startDate: _getCombinedStartDateTime()!,
          endDate: _getCombinedEndDateTime(),
          venueId: _selectedVenue!.id,
          category: _selectedCategory!,
          createdByUserId: widget.event!.createdByUserId,
          bannerPath: _bannerPath,
        );

        // TODO: Update in Firebase
        print('Updating event: ${updatedEvent.title}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Event updated successfully!'),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );

          setState(() => _isLoading = false);
          Navigator.pop(context, updatedEvent);
        }
      } else {
        final newEvent = Event(
          id: '',
          title: _titleController.text,
          description: _descriptionController.text,
          startDate: _getCombinedStartDateTime()!,
          endDate: _getCombinedEndDateTime(),
          venueId: _selectedVenue!.id,
          category: _selectedCategory!,
          createdByUserId: widget.currentUserId,
          bannerPath: _bannerPath,
        );

        // TODO: Save to Firebase
        print('Creating event: ${newEvent.title}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Event created successfully!'),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );

          setState(() => _isLoading = false);
          Navigator.pop(context, newEvent);
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
          'Delete Event',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.event?.title}"? This action cannot be undone.',
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

              // TODO: Delete from Firebase
              print('Deleting event: ${widget.event?.title}');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Event deleted successfully!'),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );

                setState(() => _isLoading = false);
                Navigator.pop(context, null);
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
}