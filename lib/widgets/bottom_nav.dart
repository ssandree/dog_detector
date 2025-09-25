import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
   final int currentIndex;
   final Function(int) onTap;

   const BottomNavBar({
      super.key,
      required this.currentIndex,
      required this.onTap,
   });

   @override
   Widget build(BuildContext context) {
      return BottomNavigationBar(
         type: BottomNavigationBarType.fixed,
         currentIndex: currentIndex,
         onTap: onTap,
         selectedItemColor: Colors.blue,
         unselectedItemColor: Colors.grey,
         items: const [
         BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
         ),
         BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '실시간',
         ),
         BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: '리포트',
         ),
         BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
         ),
         ],
      );
   }
   }
