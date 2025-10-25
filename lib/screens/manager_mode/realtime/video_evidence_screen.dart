import 'package:flutter/material.dart';

class VideoEvidenceScreen extends StatefulWidget {
  final String emotionName; // 예: '불안함'
  final String timeText; // 예: '오전 9:22에 발생'

   const VideoEvidenceScreen({
      super.key,
      required this.emotionName,
      required this.timeText,
   });

   @override
   State<VideoEvidenceScreen> createState() => _VideoEvidenceScreenState();
   }

   class _VideoEvidenceScreenState extends State<VideoEvidenceScreen> {
   late String emotionName;
   late String timeText;

   @override
   void initState() {
      super.initState();
      emotionName = widget.emotionName;
      timeText = widget.timeText;
   }

   @override
   Widget build(BuildContext context) {
      return Scaffold(
         backgroundColor: Colors.black.withValues(alpha: 0.3),
         body: Center(
         child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(16),
               boxShadow: [
               BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
               ),
               ],
            ),
            child: Column(
               mainAxisSize: MainAxisSize.min,
               children: [
               // 헤더
               Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                     children: [
                     Text(
                        '<2025년 10월 1일 - #1>',
                        style: const TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.bold,
                           color: Colors.black,
                        ),
                     ),
                     const Spacer(),
                     InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 20, color: Colors.black54),
                     ),
                     ],
                  ),
               ),

               // 썸네일 + 재생버튼 + 길이
               Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 160,
                  decoration: BoxDecoration(
                     color: Colors.grey[200],
                     borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                     children: [
                     Positioned.fill(
                        child: Container(
                           decoration: BoxDecoration(
                           color: Colors.grey[300],
                           borderRadius: BorderRadius.circular(12),
                           ),
                        ),
                     ),
                     Center(
                        child: Container(
                           width: 44,
                           height: 44,
                           decoration: BoxDecoration(
                           color: Colors.black.withValues(alpha: 0.6),
                           shape: BoxShape.circle,
                           ),
                           child: const Icon(Icons.play_arrow, color: Colors.white),
                        ),
                     ),
                     Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                           color: Colors.black.withValues(alpha: 0.6),
                           borderRadius: BorderRadius.circular(6),
                           ),
                           child: const Text(
                           '0:04',
                           style: TextStyle(color: Colors.white, fontSize: 10),
                           ),
                        ),
                     ),
                     ],
                  ),
               ),

               const SizedBox(height: 12),

               // 감정 텍스트 라인
               Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                     crossAxisAlignment: CrossAxisAlignment.center,
                     children: [
                     Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                           color: const Color(0xFFFFEDE5),
                           borderRadius: BorderRadius.circular(999),
                           border: Border.all(color: const Color(0xFFE6B7A0), width: 1),
                        ),
                        child: const Icon(Icons.sentiment_dissatisfied, color: Color(0xFFCA7E5F), size: 16),
                     ),
                     const SizedBox(width: 8),
                     Expanded(
                        child: RichText(
                           text: TextSpan(
                           children: [
                              const TextSpan(
                                 text: "'",
                                 style: TextStyle(color: Color(0xFFCA7E5F), fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                 text: emotionName,
                                 style: const TextStyle(color: Color(0xFFCA7E5F), fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                 text: "' 감정이 감지되었습니다.",
                                 style: TextStyle(color: Colors.black, fontSize: 14),
                              ),
                           ],
                           ),
                        ),
                     ),
                     ],
                  ),
               ),

               const SizedBox(height: 4),

               // 시간 텍스트
               Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                     alignment: Alignment.centerLeft,
                     child: Text(
                     timeText,
                     style: TextStyle(color: Colors.grey[600], fontSize: 12),
                     ),
                  ),
               ),

               const SizedBox(height: 12),
               ],
            ),
         ),
         ),
      );
   }
   }
