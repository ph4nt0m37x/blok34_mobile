// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// import '/models/event_attendance.dart';
// import '/models/event.dart';
// import '/models/venue.dart';
// import '/enums/attendance_status.dart';
//
// class EventDetailsPage extends StatelessWidget {
//   final Event event;
//   final String currentUserId;
//
//   const EventDetailsPage({
//     super.key,
//     required this.event,
//     required this.currentUserId,
//   });
//
//   bool get isCreator => event.createdByUserId == currentUserId;
//
//   EventAttendance? get userAttendance {
//     return event.attendees.firstWhere(
//           (a) => a.userId == currentUserId,
//       orElse: () => null,
//     );
//   }
//
//   String formatDate(DateTime dt) {
//     return DateFormat('EEEE, MMMM dd, yyyy').format(dt);
//   }
//
//   String formatTime(DateTime dt) {
//     return DateFormat('h:mm a').format(dt);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final venue = event.venue;
//
//     final hasBanner = venue?.bannerPath != null && venue!.bannerPath!.isNotEmpty;
//     final banner = hasBanner
//         ? venue!.bannerPath!
//         : 'https://images.unsplash.com/photo-1505236858219-8359eb29e329';
//
//     final status = userAttendance?.status;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F0F1A),
//       body: CustomScrollView(
//         slivers: [
//           SliverToBoxAdapter(
//             child: Stack(
//               children: [
//                 // Banner
//                 SizedBox(
//                   height: 260,
//                   width: double.infinity,
//                   child: Image.network(
//                     banner,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//
//                 Container(
//                   height: 260,
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.transparent,
//                         Colors.black87,
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 Positioned(
//                   bottom: 20,
//                   left: 16,
//                   right: 16,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Chip(
//                         label: Text(event.category.name),
//                         backgroundColor: Colors.deepPurple.withOpacity(0.7),
//                         labelStyle: const TextStyle(color: Colors.white),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         event.title,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // DESCRIPTION
//                   sectionTitle("Description"),
//                   const SizedBox(height: 8),
//                   sectionBox(Text(
//                     event.description,
//                     style: const TextStyle(color: Colors.white70),
//                   )),
//
//                   const SizedBox(height: 20),
//
//                   // SCHEDULE
//                   sectionTitle("Schedule"),
//                   const SizedBox(height: 8),
//                   sectionBox(
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         rowIconText(
//                           Icons.play_arrow,
//                           "Starts",
//                           "${formatDate(event.startDate)}\n${formatTime(event.startDate)}",
//                         ),
//                         if (event.endDate != null) ...[
//                           const SizedBox(height: 12),
//                           rowIconText(
//                             Icons.stop,
//                             "Ends",
//                             "${formatDate(event.endDate!)}\n${formatTime(event.endDate!)}",
//                           ),
//                         ],
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // VENUE
//                   sectionTitle("Venue"),
//                   const SizedBox(height: 8),
//                   sectionBox(
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on, color: Colors.white),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 venue?.name ?? "No venue",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               Text(
//                                 venue?.address ?? "",
//                                 style: const TextStyle(color: Colors.white70),
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // STATUS
//                   sectionTitle("Your Status"),
//                   const SizedBox(height: 8),
//                   sectionBox(
//                     Text(
//                       status == null
//                           ? "Not attending"
//                           : status.name,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   // ACTIONS
//                   if (isCreator) ...[
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // navigate to edit
//                       },
//                       icon: const Icon(Icons.edit),
//                       label: const Text("Edit Event"),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                       onPressed: () {},
//                       icon: const Icon(Icons.delete),
//                       label: const Text("Delete Event"),
//                     ),
//                   ]
//                   else ...[
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // RSVP logic
//                       },
//                       icon: const Icon(Icons.check),
//                       label: const Text("Mark Attending"),
//                     ),
//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // Interested logic
//                       },
//                       icon: const Icon(Icons.star),
//                       label: const Text("Mark Interested"),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget sectionTitle(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         color: Colors.white,
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
//
//   Widget sectionBox(Widget child) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white12),
//       ),
//       child: child,
//     );
//   }
//
//   Widget rowIconText(IconData icon, String title, String value) {
//     return Row(
//       children: [
//         CircleAvatar(
//           backgroundColor: Colors.deepPurple,
//           child: Icon(icon, color: Colors.white),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: const TextStyle(color: Colors.white)),
//               const SizedBox(height: 4),
//               Text(value, style: const TextStyle(color: Colors.white70)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }