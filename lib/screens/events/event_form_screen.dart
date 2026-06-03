import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/models/event.dart';
import '/models/venue.dart';
import '/enums/event_category.dart';

class EventFormPage extends StatefulWidget {
  final List<Venue> venues;
  final Event? existingEvent; // null = create, not null = edit
  final Function(Event) onSubmit;

  const EventFormPage({
    super.key,
    required this.venues,
    required this.onSubmit,
    this.existingEvent,
  });

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;

  EventCategory? selectedCategory;
  Venue? selectedVenue;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    final e = widget.existingEvent;

    titleCtrl = TextEditingController(text: e?.title ?? '');
    descCtrl = TextEditingController(text: e?.description ?? '');

    selectedCategory = e?.category;
    selectedVenue = widget.venues
        .where((v) => v.id == e?.venueId)
        .cast<Venue?>()
        .firstOrNull;

    startDate = e?.startDate;
    endDate = e?.endDate;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingEvent != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      appBar: AppBar(
        title: Text(isEdit ? "Edit Event" : "Create Event"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _titleField(),
              const SizedBox(height: 12),
              _categoryDropdown(),
              const SizedBox(height: 12),
              _descField(),
              const SizedBox(height: 12),
              _venueDropdown(),
              const SizedBox(height: 12),
              _datePicker(
                label: "Start Date",
                value: startDate,
                onPick: (d) => setState(() => startDate = d),
              ),
              const SizedBox(height: 12),
              _datePicker(
                label: "End Date (optional)",
                value: endDate,
                onPick: (d) => setState(() => endDate = d),
                allowClear: true,
              ),
              const SizedBox(height: 20),
              _submitButton(isEdit),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TITLE ----------------

  Widget _titleField() {
    return TextFormField(
      controller: titleCtrl,
      style: const TextStyle(color: Colors.white),
      decoration: _input("Title"),
      validator: (v) =>
      v == null || v.isEmpty ? "Title is required" : null,
    );
  }

  // ---------------- DESCRIPTION ----------------

  Widget _descField() {
    return TextFormField(
      controller: descCtrl,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: _input("Description"),
      validator: (v) =>
      v == null || v.isEmpty ? "Description is required" : null,
    );
  }

  // ---------------- CATEGORY ----------------

  Widget _categoryDropdown() {
    return DropdownButtonFormField<EventCategory>(
      value: selectedCategory,
      dropdownColor: const Color(0xFF2A2A3C),
      style: const TextStyle(color: Colors.white),
      decoration: _input("Category"),
      items: EventCategory.values
          .map(
            (c) => DropdownMenuItem(
          value: c,
          child: Text(c.name),
        ),
      )
          .toList(),
      onChanged: (v) => setState(() => selectedCategory = v),
      validator: (v) => v == null ? "Select a category" : null,
    );
  }

  // ---------------- VENUE ----------------

  Widget _venueDropdown() {
    return DropdownButtonFormField<Venue>(
      value: selectedVenue,
      dropdownColor: const Color(0xFF2A2A3C),
      style: const TextStyle(color: Colors.white),
      decoration: _input("Venue"),
      items: widget.venues
          .map(
            (v) => DropdownMenuItem(
          value: v,
          child: Text(v.name),
        ),
      )
          .toList(),
      onChanged: (v) => setState(() => selectedVenue = v),
      validator: (v) => v == null ? "Select a venue" : null,
    );
  }

  // ---------------- DATE PICKER ----------------

  Widget _datePicker({
    required String label,
    required DateTime? value,
    required Function(DateTime) onPick,
    bool allowClear = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value == null
                      ? "Not selected"
                      : DateFormat("yyyy-MM-dd HH:mm").format(value),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),

            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );

                if (pickedDate == null) return;

                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (pickedTime == null) return;

                final finalDate = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                onPick(finalDate);
              },
              child: const Text("Pick"),
            ),

            if (allowClear)
              IconButton(
                onPressed: () => setState(() {
                  endDate = null;
                }),
                icon: const Icon(Icons.clear, color: Colors.red),
              )
          ],
        ),
      ],
    );
  }

  // ---------------- SUBMIT ----------------

  Widget _submitButton(bool isEdit) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(14),
        backgroundColor: const Color(0xFF8A2BE2),
      ),
      onPressed: () {
        if (!_formKey.currentState!.validate()) return;

        if (startDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Start date required")),
          );
          return;
        }

        if (endDate != null && endDate!.isBefore(startDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("End date must be after start date"),
            ),
          );
          return;
        }

        final event = Event(
          id: widget.existingEvent?.id ?? '',
          title: titleCtrl.text,
          description: descCtrl.text,
          startDate: startDate!,
          endDate: endDate,
          venueId: selectedVenue!.id,
          category: selectedCategory!,
          createdByUserId: widget.existingEvent?.createdByUserId,
        );

        widget.onSubmit(event);
      },
      child: Text(isEdit ? "Update Event" : "Create Event"),
    );
  }

  // ---------------- INPUT STYLE ----------------

  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}