#!/usr/bin/env python3
"""
슬개골 탈구 분류 모델 (ST-GCN + MLP)
[수정] 과적합 방지를 위해 MLP 층 단순화
"""

import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np

class PatellaSTGCN(nn.Module):
    """슬개골 탈구 분류를 위한 ST-GCN 모델"""
    
    def __init__(self, in_channels=3, num_classes=5, dropout=0.5):
        super(PatellaSTGCN, self).__init__()
        
        self.A = self._create_dog_adjacency_matrix()
        self.num_nodes = 20
        
        self.stgcn1 = STGCN_Block(in_channels, 32, self.A, dropout=dropout)
        self.stgcn2 = STGCN_Block(32, 64, self.A, dropout=dropout)
        self.stgcn3 = STGCN_Block(64, 128, self.A, dropout=dropout)
        
        self.global_pool = nn.AdaptiveAvgPool2d(1)
        
        # ▼▼▼ [핵심 수정] MLP 층 단순화 (Overfitting 방지) ▼▼▼
        # (기존: 256 -> 512 -> 256 -> 128 -> 5)
        self.mlp = nn.Sequential(
            nn.Linear(128, 64), # 256 -> 128
            nn.ELU(inplace=True),
            nn.Dropout(dropout),
            
            # (512, 256 층 제거)
            
            # 출력층
            nn.Linear(64, num_classes) # 64 -> 5
        )
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
        
        self._initialize_weights()
    
    def _create_dog_adjacency_matrix(self):
        """강아지 관절 연결 관계 인접 행렬 생성"""
        A = np.zeros((20, 20))
        A += np.eye(20)
        
        # 앞다리 (L: 0-1-2 / R: 6-7-8)
        A[0, 1] = A[1, 0] = 1; A[1, 2] = A[2, 1] = 1
        A[6, 7] = A[7, 6] = 1; A[7, 8] = A[8, 7] = 1
        
        # 뒷다리 (L: 3-4-5 / R: 9-10-11)
        A[3, 4] = A[4, 3] = 1; A[4, 5] = A[5, 4] = 1
        A[9, 10] = A[10, 9] = 1; A[10, 11] = A[11, 10] = 1
        
        # 몸통 (어깨 연결)
        A[2, 5] = A[5, 2] = 1; A[8, 11] = A[11, 8] = 1
        A[2, 8] = A[8, 2] = 1; A[5, 11] = A[11, 5] = 1
        
        # 꼬리 (12-13)
        A[12, 13] = A[13, 12] = 1
        A[12, 5] = A[5, 12] = 1; A[12, 11] = A[11, 12] = 1
        
        # 머리
        A[16, 17] = A[17, 16] = 1 # nose-mouth
        A[14, 18] = A[18, 14] = 1 # L ear
        A[15, 19] = A[19, 15] = 1 # R ear
        
        # 머리-목 (앞어깨 연결)
        A[16, 2] = A[2, 16] = 1; A[16, 8] = A[8, 16] = 1
        
        # 정규화
        D = np.sum(A, axis=1)
        D_inv = np.diag(1.0 / (D + 1e-6))
        A_norm = D_inv @ A
        
        return torch.FloatTensor(A_norm)
    
    def _initialize_weights(self):
        """가중치 초기화"""
        for m in self.modules():
            if isinstance(m, nn.Linear):
                nn.init.xavier_uniform_(m.weight)
                if m.bias is not None:
                    nn.init.constant_(m.bias, 0)
            elif isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode='fan_out', nonlinearity='relu')
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)
    
    def forward(self, x):
        N, C, T, V, M = x.size()
        
        x = self.stgcn1(x)
        x = self.stgcn2(x)
        x = self.stgcn3(x)
        
        N, C, T, V, M = x.size()
        x = x.view(N * M, C, T, V)
        x = self.global_pool(x)
        x = x.view(N, M, C)
        
        x = torch.mean(x, dim=1)
        
        logits = self.mlp(x)
        
        return logits

class STGCN_Block(nn.Module):
    """ST-GCN 블록 (GCN + TCN + Residual)"""
    def __init__(self, in_channels, out_channels, A, dropout=0.5):
        super(STGCN_Block, self).__init__()
        self.gcn = GraphConvolution(in_channels, out_channels, A)
        self.tcn = TemporalConvolution(out_channels, out_channels, dropout)
        self.elu = nn.ELU(inplace=True)
        if in_channels != out_channels:
            self.residual = nn.Sequential(
                nn.Conv2d(in_channels, out_channels, kernel_size=1),
                nn.BatchNorm2d(out_channels)
            )
        else:
            self.residual = lambda x: x
    
    def forward(self, x):
        N, C, T, V, M = x.size()
        res = x.permute(0, 4, 1, 2, 3).contiguous()
        res = res.view(N * M, C, T, V)
        res = self.residual(res)
        res = res.view(N, M, -1, T, V).permute(0, 2, 3, 4, 1).contiguous()
        x = self.gcn(x)
        x = self.elu(x)
        x = self.tcn(x)
        x = x + res
        x = self.elu(x)
        return x

class GraphConvolution(nn.Module):
    """그래프 합성곱"""
    def __init__(self, in_channels, out_channels, A):
        super(GraphConvolution, self).__init__()
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.register_buffer('A', A)
        self.conv = nn.Conv2d(in_channels, out_channels, kernel_size=1)
        self.bn = nn.BatchNorm2d(out_channels)
    
    def forward(self, x):
        N, C, T, V, M = x.size()
        x = x.permute(0, 4, 1, 2, 3).contiguous()
        x = x.view(N * M, C, T, V)
        x = self.conv(x)
        x = self.bn(x)
        x = torch.einsum('nctv,vw->nctw', x, self.A)
        x = x.view(N, M, self.out_channels, T, V)
        x = x.permute(0, 2, 3, 4, 1).contiguous()
        return x

class TemporalConvolution(nn.Module):
    """시간 합성곱"""
    def __init__(self, in_channels, out_channels, dropout=0.5, kernel_size=9):
        super(TemporalConvolution, self).__init__()
        self.out_channels = out_channels
        padding = (kernel_size - 1) // 2
        self.conv = nn.Conv2d(in_channels, out_channels, 
                             kernel_size=(kernel_size, 1), 
                             padding=(padding, 0))
        self.bn = nn.BatchNorm2d(out_channels)
        self.dropout = nn.Dropout(dropout)
    
    def forward(self, x):
        N, C, T, V, M = x.size()
        x = x.permute(0, 4, 1, 2, 3).contiguous()
        x = x.view(N * M, C, T, V)
        x = self.conv(x)
        x = self.bn(x)
        x = self.dropout(x)
        x = x.view(N, M, self.out_channels, T, V)
        x = x.permute(0, 2, 3, 4, 1).contiguous()
        return x

if __name__ == "__main__":
    # 테스트 (단순화된 MLP로 파라미터 수 감소 확인)
    model = PatellaSTGCN(in_channels=3, num_classes=5, dropout=0.5)
    
    x = torch.randn(2, 3, 60, 20, 1)
    
    print(f"입력 크기: {x.shape}")
    print(f"모델 파라미터 수 (단순화됨): {sum(p.numel() for p in model.parameters()):,}") # 967,749 -> 약 800k
    
    with torch.no_grad():
        output = model(x)
        print(f"출력 크기: {output.shape}")