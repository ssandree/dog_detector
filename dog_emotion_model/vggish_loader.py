#!/usr/bin/env python3
"""
VGGish 사전학습 모델 로더
간단한 인터페이스로 사전학습된 VGGish 모델 사용
"""

import torch
import numpy as np
from typing import Optional, Union
import warnings

def load_vggish_model():
    """
    사전학습된 VGGish 모델 로드
    Returns:
        model: VGGish 모델 (torchvggish 또는 커스텀)
        use_pretrained: bool - 사전학습 모델 사용 여부
        preprocess_func: 전처리 함수
    """
    try:
        # 1. 우선 torchvggish (사전학습) 시도
        from torchvggish import vggish, vggish_input
        
        model = vggish()
        model.eval()
        
        def preprocess_audio(audio_path: str) -> torch.Tensor:
            """오디오 파일을 VGGish 입력으로 변환"""
            try:
                input_batch = vggish_input.wavfile_to_examples(audio_path)
                return torch.from_numpy(input_batch).float()
            except Exception as e:
                print(f"⚠️ 오디오 전처리 실패: {e}")
                return torch.zeros(1, 96, 64)  # 기본 크기
        
        print("✅ torchvggish 사전학습 모델 로드 성공")
        return model, True, preprocess_audio
        
    except ImportError:
        # 폴백: 더미 모델
        class DummyVGGish(torch.nn.Module):
            def forward(self, x):
                # 입력 크기에 관계없이 128차원 벡터 반환
                batch_size = x.size(0) if x.dim() > 0 else 1
                return torch.zeros(batch_size, 128)
        
        model = DummyVGGish()
        
        def preprocess_audio(audio_path: str) -> torch.Tensor:
            return torch.zeros(1, 96, 64)
        
        print("❌ torchvggish 없음: 더미 모델 사용")
        print("💡 사전학습된 VGGish 사용을 위해 'pip install torchvggish' 실행")
        return model, False, preprocess_audio

def extract_audio_features(audio_path: str, model: Optional[torch.nn.Module] = None, preprocess_func=None, device: str = 'cpu') -> np.ndarray:
    """
    오디오 파일에서 특성 추출
    Args:
        audio_path: 오디오 파일 경로
        model: VGGish 모델
        preprocess_func: 전처리 함수
        device: 디바이스
    Returns:
        features: 128차원 오디오 특성 벡터
    """
    if model is None or preprocess_func is None:
        print("⚠️ 모델 또는 전처리 함수가 없음: 0 벡터 반환")
        return np.zeros(128)
    
    try:
        # 오디오 전처리
        audio_tensor = preprocess_func(audio_path)
        
        if audio_tensor.dim() == 0 or audio_tensor.numel() == 0:
            print("⚠️ 빈 오디오 텐서: 0 벡터 반환")
            return np.zeros(128)
        
        # GPU 사용 가능시 이동
        if torch.cuda.is_available() and device != 'cpu':
            model = model.to(device)
            audio_tensor = audio_tensor.to(device)
        
        # 특성 추출
        with torch.no_grad():
            if audio_tensor.dim() == 3:  # (batch, height, width)
                features = model(audio_tensor)
            elif audio_tensor.dim() == 4:  # (batch, channel, height, width)
                features = model(audio_tensor)
            else:
                # 1차원 또는 2차원 입력 처리
                if audio_tensor.dim() == 1:
                    audio_tensor = audio_tensor.unsqueeze(0).unsqueeze(0).unsqueeze(0)
                elif audio_tensor.dim() == 2:
                    audio_tensor = audio_tensor.unsqueeze(0).unsqueeze(0)
                features = model(audio_tensor)
        
        # 평균값 계산 (여러 프레임의 경우)
        if features.dim() > 1:
            features = features.mean(dim=0)
        
        # numpy로 변환
        if features.is_cuda:
            features = features.cpu()
        
        result = features.numpy()
        
        # 128차원으로 맞춤
        if result.shape[-1] != 128:
            if result.shape[-1] > 128:
                result = result[:128]  # 자르기
            else:
                # 패딩
                padding = np.zeros(128)
                padding[:result.shape[-1]] = result
                result = padding
        
        return result
        
    except Exception as e:
        print(f"❌ 오디오 특성 추출 실패: {e}")
        return np.zeros(128)

# 전역 모델 인스턴스 (한번만 로드)
_vggish_model = None
_vggish_preprocess = None
_vggish_pretrained = False

def get_vggish_instance():
    """전역 VGGish 인스턴스 반환 (싱글톤 패턴)"""
    global _vggish_model, _vggish_preprocess, _vggish_pretrained
    
    if _vggish_model is None:
        _vggish_model, _vggish_pretrained, _vggish_preprocess = load_vggish_model()
    
    return _vggish_model, _vggish_pretrained, _vggish_preprocess

def test_vggish():
    """VGGish 모델 테스트"""
    print("🧪 VGGish 모델 테스트")
    print("="*40)
    
    model, pretrained, preprocess_func = get_vggish_instance()
    
    print(f"📊 사전학습 모델: {'✅' if pretrained else '❌'}")
    
    # 더미 오디오로 테스트
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    features = extract_audio_features("dummy.wav", model, preprocess_func, device)
    
    print(f"🎵 특성 추출 결과: {features.shape}")
    print(f"📈 특성 범위: [{features.min():.3f}, {features.max():.3f}]")
    print("✅ VGGish 테스트 완료")

if __name__ == "__main__":
    test_vggish()