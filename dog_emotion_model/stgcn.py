import torch
from torch import nn
import torch.nn.functional as F


def create_normalized_adjacency(num_nodes, connections):
    """
    연결 리스트(connections)를 기반으로 정규화된 인접 행렬 A를 생성합니다.
    (ST-GCN 논문의 정규화 방식: D^-1/2 * A * D^-1/2)
    """
    # 1. 0으로 채워진 행렬 생성
    A = torch.zeros(num_nodes, num_nodes)

    # 2. 자기 자신 연결 (Self-loop) 추가
    for i in range(num_nodes):
        A[i, i] = 1

    # 3. 뼈대 연결 추가 (양방향)
    for i, j in connections:
        # 인덱스 범위 체크 (안전 장치)
        if 0 <= i < num_nodes and 0 <= j < num_nodes:
            A[i, j] = 1
            A[j, i] = 1
        else:
            print(f"Warning: Connection index out of bounds - ({i}, {j}). Max index is {num_nodes-1}.")

    # 4. 행렬 정규화
    D = A.sum(dim=1) # 각 노드의 연결 수 (Degree)
    # Degree가 0인 노드 방지 (나중에 0으로 나누는 것 방지)
    D[D <= 0] = 1.0 
    D_inv_sqrt = torch.pow(D, -0.5)

    D_mat_inv_sqrt = torch.diag(D_inv_sqrt) # 대각 행렬로 변환

    # 정규화된 인접 행렬 A_norm = D^-1/2 * A * D^-1/2
    A_normalized = D_mat_inv_sqrt @ A @ D_mat_inv_sqrt

    return A_normalized

# --- 부품 1: Graph Convolution (GCN) ---
# (수정된 5D 텐서 처리 버전)
class GraphConvolution(nn.Module):
    def __init__(self, in_channels, out_channels, A, num_nodes, edges):
        super(GraphConvolution, self).__init__()
        self.in_channels = in_channels
        self.out_channels = out_channels
        # A는 외부에서 주입받는 인접 행렬 (학습 가능한 파라미터가 아님)
        # 모델의 device에 맞춰주기 위해 register_buffer 사용 권장
        self.register_buffer('A', A) 
        self.num_nodes = num_nodes
        self.edges = edges
        self.theta = nn.Parameter(torch.FloatTensor(in_channels, out_channels))
        nn.init.xavier_uniform_(self.theta)

    def forward(self, x):
        N, C, T, V, M = x.size()

        # (N, C, T, V, M) -> (N, T, V, M, C)
        x = x.permute(0, 2, 3, 4, 1).contiguous()
        # (N*T*V*M, C)
        x = x.view(N * T * V * M, C)

        # (N*T*V*M, C_out)
        x = torch.matmul(x, self.theta)

        # (N, T, V, M, C_out)
        x = x.view(N, T, V, M, self.out_channels)
        # (N, C_out, T, V, M)
        x = x.permute(0, 4, 1, 2, 3).contiguous()

        # 인접 행렬 A와 공간적 GCN 연산
        # (N, C_out, T, V, M) @ (V, V) -> (N, C_out, T, V, M)
        x = torch.einsum('nctvm,vw->nctwm', (x, self.A))
        return x

# --- 부품 2: Temporal Convolution (TCN) ---
# (수정된 5D 텐서 처리 버전)
class TemporalConvolution(nn.Module):
    def __init__(self, in_channels, out_channels, dropout=0.5):
        super(TemporalConvolution, self).__init__()
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.dropout = dropout
        # 9 프레임(시간)을 보는 1D Conv (커널 (9, 1))
        self.conv = nn.Conv2d(in_channels, out_channels, kernel_size=(9, 1), padding=(4, 0))
        self.bn = nn.BatchNorm2d(out_channels)
        self.drop = nn.Dropout(dropout)

    def forward(self, x):
        N, C, T, V, M = x.size()

        # Conv2d를 위해 4D 텐서 (N*M, C, T, V)로 변환
        x = x.permute(0, 4, 1, 2, 3).contiguous()
        x = x.view(N * M, C, T, V)

        x = self.conv(x)
        x = self.bn(x)
        # (활성화 함수는 ST-GCN 블록 마지막에 적용)
        x = self.drop(x)

        # 다시 5D 텐서 (N, C_out, T, V, M)로 복원
        x = x.view(N, M, self.out_channels, T, V)
        x = x.permute(0, 2, 3, 4, 1).contiguous()
        return x

# --- 부품 3: ST-GCN Block (GCN + TCN + Residual) ---
class stgcn(torch.nn.Module):
    """
    ST-GCN의 기본 빌딩 블록 (GCN, TCN, 잔차 연결 포함)
    """
    def __init__(self, in_channels, out_channels, A, num_nodes, edges, dropout=0.5):
        super(stgcn, self).__init__()
        self.out_channels = out_channels # 잔차 연결 재구성(reshape)에 필요

        self.gcn = GraphConvolution(in_channels, out_channels, A, num_nodes, edges)
        self.tcn = TemporalConvolution(out_channels, out_channels, dropout)

        # ▼▼▼▼▼ [수정] ELU -> ReLU ▼▼▼▼▼
        self.activation = nn.ELU() # ELU 대신 ReLU 사용
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

        # 잔차 연결 (입력/출력 채널이 다를 경우 1x1 Conv로 차원 맞춤)
        if in_channels == out_channels:
            self.residual = lambda x: x
        else:
            # Conv2d를 사용하므로 BatchNorm2d 사용
            self.residual = nn.Sequential(
                nn.Conv2d(in_channels, out_channels, kernel_size=1),
                nn.BatchNorm2d(out_channels)
            )

    def forward(self, x):
        N, C, T, V, M = x.size()

        # 1. 잔차 연결 준비 (TCN 입력 형식과 동일하게 4D로 변환)
        res = x.permute(0, 4, 1, 2, 3).contiguous().view(N * M, C, T, V)
        res = self.residual(res) # (N*M, C_out, T, V)
        # 5D로 복원
        res = res.view(N, M, self.out_channels, T, V).permute(0, 2, 3, 4, 1).contiguous()

        # 2. GCN (공간 처리)
        x = self.gcn(x)
        # ▼▼▼▼▼ [수정] self.relu -> self.activation ▼▼▼▼▼
        x = self.activation(x) # GCN 후 활성화
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

        # 3. TCN (시간 처리)
        x = self.tcn(x)

        # 4. 잔차 연결 (TCN 출력 + 원본)
        x = x + res

        # 5. 최종 활성화
        # ▼▼▼▼▼ [수정] self.relu -> self.activation ▼▼▼▼▼
        x = self.activation(x) # 최종 활성화
        # ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
        return x

# --- 완성품: 강아지 감정 분류 모델 ---
class DogEmotionSTGCN(nn.Module):
    """
    ST-GCN 블록들을 조립하여 최종 감정 분류를 수행하는 전체 모델
    """
    def __init__(self, in_channels, num_classes, A, num_nodes, edges, dropout=0.5):
        super(DogEmotionSTGCN, self).__init__()

        # --- 1. Backbone (특징 추출기) ---
        # ST-GCN 블록 3개 적층
        self.stgcn_block1 = stgcn(in_channels, 64, A, num_nodes, edges, dropout)
        self.stgcn_block2 = stgcn(64, 128, A, num_nodes, edges, dropout)
        self.stgcn_block3 = stgcn(128, 256, A, num_nodes, edges, dropout)



        # --- 2. Head (분류기) ---
        # (Pooling은 forward에서 .mean()으로 직접 처리)
        self.fc = nn.Sequential(
            nn.Linear(256, 256), nn.ELU(), nn.Dropout(0.5),
            nn.Linear(256, 256), nn.ReLU(), nn.Dropout(0.5),
            nn.Linear(256, num_classes)
        )
        self.dropout = nn.Dropout(dropout) # (FC 레이어 전용 드롭아웃)

    def forward(self, x):
        # 입력: (N, C, T, V, M)
        
        # 1. Backbone
        x = self.stgcn_block1(x) # (N, 64, T, V, M)
        x = self.stgcn_block2(x) # (N, 128, T, V, M)
        x = self.stgcn_block3(x) # (N, 256, T, V, M)





        # 2. Global Average Pooling
        # (N, C, T, V, M) -> (N, C)
        # 시간(T), 관절(V), 멤버(M) 차원을 모두 평균내어 요약
        x = x.mean(dim=[2, 3, 4]) # (N, 256)

        # 3. Head
        x = self.dropout(x)
        x = self.fc(x)           # (N, num_classes)

        return x