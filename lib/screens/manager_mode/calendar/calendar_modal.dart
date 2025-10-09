import 'package:flutter/material.dart';

class CalendarModal extends StatelessWidget {
   final DateTime currentDate;
   final int day;

   const CalendarModal({
      super.key,
      required this.currentDate,
      required this.day,
   });

   @override
   Widget build(BuildContext context) {
      return Container(
         height: MediaQuery.of(context).size.height * 0.6,
         decoration: const BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
         ),
         ),
      child: Column(
         children: [
            // 모달 핸들
            Container(
               margin: const EdgeInsets.only(top: 8),
               width: 40,
               height: 4,
               decoration: BoxDecoration(
               color: Colors.grey[300],
               borderRadius: BorderRadius.circular(2),
            ),
            ),
            
            // 모달 내용
            Expanded(
               child: Padding(
               padding: const EdgeInsets.all(20.0),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     // 날짜 제목
                     Text(
                     '${currentDate.month}월 ${day}일',
                     style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                     ),
                     ),
                     const SizedBox(height: 20),

                     // 슬개골 탈구 의심 행동 감지 알림
                     Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                           color: const Color(0xFF4CAF50),
                           width: 1,
                        ),
                     ),
                     child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                           children: [
                              Container(
                                 padding: const EdgeInsets.all(6),
                                 decoration: BoxDecoration(
                                 color: const Color(0xFF4CAF50),
                                 borderRadius: BorderRadius.circular(6),
                                 ),
                                 child: const Icon(
                                 Icons.warning_amber_rounded,
                                 color: Colors.white,
                                 size: 16,
                                 ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                 child: Text(
                                 day == 10 ? '슬개골 탈구 의심 행동이 2회 감지되었어요' : '슬개골 탈구 의심 행동이 1회 감지되었어요',
                                 style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                 ),
                                 ),
                              ),
                           ],
                           ),
                           const SizedBox(height: 16),
                           
                           // 감정 진행 바
                           Row(
                           children: [
                              Expanded(
                                 flex: 60,
                                 child: Container(
                                 height: 20,
                                 decoration: const BoxDecoration(
                                    color: Color(0xFFE0B29F),
                                    borderRadius: BorderRadius.only(
                                       topLeft: Radius.circular(10),
                                       bottomLeft: Radius.circular(10),
                                    ),
                                 ),
                                 alignment: Alignment.centerLeft,
                                 padding: const EdgeInsets.only(left: 10),
                                 child: const Text(
                                    '부정 감정 60%',
                                    style: TextStyle(color: Colors.black, fontSize: 12),
                                 ),
                                 ),
                              ),
                              Expanded(
                                 flex: 40,
                                 child: Container(
                                 height: 20,
                                 decoration: const BoxDecoration(
                                    color: Color(0xFFA5D6A7),
                                    borderRadius: BorderRadius.only(
                                       topRight: Radius.circular(10),
                                       bottomRight: Radius.circular(10),
                                    ),
                                 ),
                                 alignment: Alignment.centerRight,
                                 padding: const EdgeInsets.only(right: 10),
                                 child: const Text(
                                    '긍정 감정 40%',
                                    style: TextStyle(color: Colors.black, fontSize: 12),
                                 ),
                                 ),
                              ),
                           ],
                           ),
                        ],
                     ),
                     ),
                     const SizedBox(height: 20),

                     // 일일 분석 바로가기 버튼
                     SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: ElevatedButton(
                        onPressed: () {
                           Navigator.pop(context);
                           // 일일 분석 화면으로 이동
                           Navigator.pushNamed(context, '/daily-report');
                        },
                        style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.white,
                           foregroundColor: Colors.black,
                           side: const BorderSide(
                           color: Color(0xFF4CAF50),
                           width: 2,
                           ),
                           shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(10),
                           ),
                           elevation: 0,
                        ),
                        child: const Text(
                           '일일 분석 바로가기',
                           style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.bold,
                           ),
                        ),
                     ),
                     ),
                     const SizedBox(height: 20),

                     // 타임라인 보기
                     const Text(
                     '타임라인 보기',
                     style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                     ),
                     ),
                     const SizedBox(height: 15),
                     
                     // 타임라인 항목들
                     _buildTimelineItem('오전 11:00'),
                     _buildTimelineItem('오후 3:30'),
                  ],
               ),
               ),
            ),
         ],
         ),
      );
   }

   Widget _buildTimelineItem(String time) {
      return Padding(
         padding: const EdgeInsets.only(bottom: 12.0),
         child: Row(
         children: [
            Container(
               width: 8,
               height: 8,
               decoration: const BoxDecoration(
               color: Color(0xFF4CAF50),
               shape: BoxShape.circle,
               ),
            ),
            const SizedBox(width: 12),
            Text(
               time,
               style: const TextStyle(
               fontSize: 14,
               fontWeight: FontWeight.bold,
               color: Colors.black,
               ),
            ),
            const SizedBox(width: 12),
            Expanded(
               child: Container(
               height: 40,
               decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                     color: Colors.grey[300]!,
                     width: 1,
                  ),
               ),
               ),
            ),
         ],
         ),
      );
   }
   }
