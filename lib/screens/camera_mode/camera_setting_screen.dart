import 'package:flutter/material.dart';

class CameraSettingScreen extends StatelessWidget {
   const CameraSettingScreen({super.key});

   @override
   Widget build(BuildContext context) {
      return Scaffold(
         backgroundColor: const Color(0xFFF5F5F5),
         body: SafeArea(
            child: Padding(
               padding: const EdgeInsets.all(20.0),
               child: Column(
                  children: [
                     // 헤더
                     Row(
                        children: [
                           IconButton(
                              icon: const Icon(
                                 Icons.arrow_back_ios,
                                 color: Colors.black,
                                 size: 20,
                              ),
                              onPressed: () {
                                 Navigator.pop(context);
                              },
                           ),
                           const Expanded(
                              child: Text(
                                 '카메라 설치 단계',
                                 textAlign: TextAlign.center,
                                 style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                 ),
                              ),
                           ),
                           const SizedBox(width: 40), // 뒤로가기 버튼과 균형 맞추기
                        ],
                     ),
                     const SizedBox(height: 30),
                     
                     // 메인 콘텐츠 영역
                     Expanded(
                        child: Container(
                           color: Colors.white,
                           child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                 children: [
                                    // 왼쪽 섹션 (설명 및 버튼)
                                    Expanded(
                                       flex: 1,
                                       child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                             // 주요 안내 문구
                                             const Text(
                                                '강아지가 점선 안에 들어오도록\n카메라를 설치해주세요.',
                                                style: TextStyle(
                                                   fontSize: 16,
                                                   fontWeight: FontWeight.bold,
                                                   color: Colors.black,
                                                   height: 1.4,
                                                ),
                                             ),
                                             const SizedBox(height: 20),
                                             
                                             // 권장사항
                                             const Text(
                                                '• 바닥에서 약 40cm 높이를 권장해요',
                                                style: TextStyle(
                                                   fontSize: 14,
                                                   color: Color(0xFF666666),
                                                   height: 1.3,
                                                ),
                                             ),
                                             const SizedBox(height: 8),
                                             const Text(
                                                '• 낮에 빛이 잘 들면 좋아요',
                                                style: TextStyle(
                                                   fontSize: 14,
                                                   color: Color(0xFF666666),
                                                   height: 1.3,
                                                ),
                                             ),
                                             
                                             const Spacer(),
                                             
                                             // 설치 완료 버튼
                                             SizedBox(
                                                width: double.infinity,
                                                height: 50,
                                                child: ElevatedButton(
                                                   onPressed: () {
                                                      // 설치 완료 로직
                                                      Navigator.pop(context);
                                                   },
                                                   style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF81C784),
                                                      foregroundColor: Colors.black,
                                                      shape: RoundedRectangleBorder(
                                                         borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      elevation: 0,
                                                   ),
                                                   child: const Text(
                                                      '설치 완료',
                                                      style: TextStyle(
                                                         fontSize: 16,
                                                         fontWeight: FontWeight.bold,
                                                      ),
                                                   ),
                                                ),
                                             ),
                                          ],
                                       ),
                                    ),
                                    
                                    const SizedBox(width: 20),
                                    
                                    // 오른쪽 섹션 (이미지 영역)
                                    Expanded(
                                       flex: 1,
                                       child: Container(
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                             color: const Color(0xFFE0E0E0),
                                             borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Stack(
                                             children: [
                                                // 회색 배경
                                                Container(
                                                   width: double.infinity,
                                                   height: double.infinity,
                                                   decoration: BoxDecoration(
                                                      color: const Color(0xFFE0E0E0),
                                                      borderRadius: BorderRadius.circular(15),
                                                   ),
                                                ),
                                                
                                                // 점선 타원 (강아지 영역 표시)
                                                Positioned(
                                                   top: 60,
                                                   left: 20,
                                                   right: 20,
                                                   bottom: 80,
                                                   child: CustomPaint(
                                                      painter: DashedOvalPainter(),
                                                      child: Container(
                                                         decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(50),
                                                         ),
                                                      ),
                                                   ),
                                                ),
                                             ],
                                          ),
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
      );
   }
}

class DashedOvalPainter extends CustomPainter {
   @override
   void paint(Canvas canvas, Size size) {
      final paint = Paint()
         ..color = Colors.black
         ..strokeWidth = 2.0
         ..style = PaintingStyle.stroke;

      final path = Path();
      path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
      
      // 점선 효과를 위한 dash 패턴
      final dashWidth = 5.0;
      final dashSpace = 3.0;
      
      final pathMetrics = path.computeMetrics();
      for (final pathMetric in pathMetrics) {
         double distance = 0.0;
         while (distance < pathMetric.length) {
            final extractPath = pathMetric.extractPath(
               distance,
               distance + dashWidth,
            );
            canvas.drawPath(extractPath, paint);
            distance += dashWidth + dashSpace;
         }
      }
   }

   @override
   bool shouldRepaint(CustomPainter oldDelegate) => false;
}
