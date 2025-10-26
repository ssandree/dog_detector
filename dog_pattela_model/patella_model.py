import torch
from torch import nn
import torch.nn.functional as F

class stgcn(torch.nn.Module):
    def __init__(self, in_channels, out_channels, A, num_nodes, edges, dropout=0.5):
        super(stgcn, self).__init__() # 한번만 호출
        
        self.gcn = GraphConvolution(in_channels, out_channels, A, num_nodes, edges)
        self.tcn = TemporalConvolution(out_channels, out_channels, dropout)
        self.relu = nn.ReLU()
        
        # 잔차 연결 (Residual Connection)
        # 입력 채널과 출력 채널이 다를 경우 1x1 Conv로 차원을 맞춰줌
        if in_channels == out_channels:
            self.residual = lambda x: x # 채널이 같으면 아무것도 안 함
        else:
            self.residual = nn.Sequential(
                nn.Conv2d(in_channels, out_channels, kernel_size=1),
                nn.BatchNorm2d(out_channels)
            )

    def forward(self, x):
        # 1. 원본 x를 잔차 연결을 위해 저장
        # TCN과 동일한 4D 변환을 위해 준비
        N, C, T, V, M = x.size()
        res = x.permute(0, 4, 1, 2, 3).contiguous().view(N * M, C, T, V)
        res = self.residual(res) # 1x1 Conv 적용 (N*M, C_out, T, V)
        # 5D로 복원 (N, C_out, T, V, M)
        res = res.view(N, M, self.out_channels, T, V).permute(0, 2, 3, 4, 1).contiguous()

        # 2. GCN
        x = self.gcn(x) # (N, C_out, T, V, M)
        x = self.relu(x) # GCN 후 활성화
        
        # 3. TCN
        x = self.tcn(x) # (N, C_out, T, V, M)
        
        # 4. 잔차 연결 (TCN 출력 + 원본 x)
        x = x + res
        
        # 5. 최종 활성화
        x = self.relu(x)
        return x

class GraphConvolution(nn.Module):
    def __init__(self, in_channels, out_channels, A, num_nodes, edges):
        super(GraphConvolution, self).__init__()
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.A = A
        self.num_nodes = num_nodes
        self.edges = edges
        self.theta = nn.Parameter(torch.FloatTensor(in_channels, out_channels))
        nn.init.xavier_uniform_(self.theta)

    def forward(self, x):
        N, C, T, V, M = x.size()
        
        # (N, C, T, V, M) -> (N, T, V, M, C)
        x = x.permute(0, 2, 3, 4, 1).contiguous()
        # (N*T*V*M, C)로 변환 (수정된 부분)
        x = x.view(N * T * V * M, C)
        
        x = torch.matmul(x, self.theta) # (N*T*V*M, C_out)
        
        # (N, T, V, M, C_out)
        x = x.view(N, T, V, M, self.out_channels)
        # (N, C_out, T, V, M)
        x = x.permute(0, 4, 1, 2, 3).contiguous() 
        
        x = torch.einsum('nctvm,vw->nctwm', (x, self.A))
        return x

class TemporalConvolution(nn.Module):
    def __init__(self, in_channels, out_channels, dropout=0.5):
        super(TemporalConvolution, self).__init__()
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.dropout = dropout
        # TCN의 커널 크기는 (Temporal Kernel, 1) 이어야 함. (9, 1)은 올바름.
        self.conv = nn.Conv2d(in_channels, out_channels, kernel_size=(9, 1), padding=(4, 0))
        self.bn = nn.BatchNorm2d(out_channels)
        self.drop = nn.Dropout(dropout)
        # TCN 이후, 잔차 연결 전에 ReLU를 넣기도 함 (설계에 따라 다름)
        # self.relu = nn.ReLU() 

    def forward(self, x):
        N, C, T, V, M = x.size()
        
        # 5D 텐서 (N, C, T, V, M) -> 4D 텐서 (N*M, C, T, V)로 변환 (수정된 부분)
        x = x.permute(0, 4, 1, 2, 3).contiguous() 
        x = x.view(N * M, C, T, V)
        
        x = self.conv(x)
        x = self.bn(x)
        # x = self.relu(x) # 여기에 ReLU를 추가할 수도 있음
        x = self.drop(x)
        
        # 다시 5D 텐서 (N, C_out, T, V, M)로 복원 (수정된 부분)
        x = x.view(N, M, self.out_channels, T, V)
        x = x.permute(0, 2, 3, 4, 1).contiguous()
        return x

if __name__ == "__main__":
    # A는 정규화된 인접 행렬이어야 하지만, 테스트를 위해 Identity 사용
    A = torch.eye(24) 
    model = stgcn(in_channels=3, out_channels=64, A=A, num_nodes=24, edges=None)
    
    # (N, C_in, T, V, M)
    input_data = torch.randn(1, 3, 300, 24, 1)  
    output_data = model(input_data)
    print(output_data.shape) # 예상 출력: torch.Size([1, 64, 300, 24, 1])