// import 'package:flutter/material.dart';
// import 'package:recipe_app/screens/meals.dart';
// import 'package:blok34_mobile/models/event.dart';
//
//
// class EventCard extends StatelessWidget {
//   final Category category;
//
//   const CategoryCard({super.key, required this.category});
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     Color color = Colors.orangeAccent;
//     Color text = Colors.white;
//
//     return GestureDetector(
//         onTap: () {
//           Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => MealsScreen(category: category.name,)));
//         },
//         child: Card(
//             shape: RoundedRectangleBorder(
//               side: BorderSide(color: color, width: 3),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             color: color,
//             elevation: 2,
//             child: Padding(
//               padding: EdgeInsets.all(5),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                             padding: EdgeInsets.all(4),
//                             clipBehavior: Clip.hardEdge,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10), // rounded white background
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(98),
//                               child: Image.network(category.img),
//                             )
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Divider()
//                     ],
//                   ),
//                   Row (
//                     children: [
//                       SizedBox(width: 8),
//                       Text(category.name, style: TextStyle(fontSize: 22, color: text, fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
//                     ],
//                   ),
//                   Divider(),
//                   Row(
//                     children: [
//                       SizedBox(width: 8),
//                       Expanded(child:
//                       Text(category.desc, style: TextStyle(fontSize: 12, color: text)),
//                       )
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       Divider()
//                     ],
//                   ),
//                 ],
//               ),)
//         )
//     );
//   }
// }