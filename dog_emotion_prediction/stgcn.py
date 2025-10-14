import torch
from torch import nn
import torch.nn.functional as F


class stgcn(torch.nn.Module):
    def __init__(self, in_channels, out_channels, A, num_nodes, edges, dropout=0.5):
        super(stgcn, self).__init__()
        super(stgcn, self).__init__()
        self.gcn = GraphConvolution(in_channels, out_channels, A, num_nodes, edges)
        self.tcn = TemporalConvolution(out_channels, out_channels, dropout)
        self.relu = nn.ReLU()
        self.out_channels = out_channels
        self.in_channels = in_channels
        self.A = A
        self.num_nodes = num_nodes
        self.edges = edges
        self.dropout = dropout
    def forward(self, x):
        x = self.gcn(x)
        x = self.tcn(x)
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
        x = x.permute(0, 2, 3, 1, 4).contiguous().view(N * T * V, C * M)
        x = torch.matmul(x, self.theta)
        x = x.view(N, T, V, self.out_channels, M).permute(0, 3, 1, 2, 4).contiguous()
        x = torch.einsum('nctvm,vw->nctwm', (x, self.A))
        return x
class TemporalConvolution(nn.Module):
    def __init__(self, in_channels, out_channels, dropout=0.5):
        super(TemporalConvolution, self).__init__()
        self.in_channels = in_channels
        self.out_channels = out_channels
        self.dropout = dropout
        self.conv = nn.Conv2d(in_channels, out_channels, kernel_size=(9, 1), padding=(4, 0))
        self.bn = nn.BatchNorm2d(out_channels)
        self.drop = nn.Dropout(dropout)
    def forward(self, x):
        x = self.conv(x)
        x = self.bn(x)
        x = self.drop(x)
        return x

if __name__ == "__main__":
    model = stgcn(in_channels=3, out_channels=64, A=torch.eye(24), num_nodes=24, edges=None)
    input_data = torch.randn(1, 3, 300, 24, 1)  # (N, C, T, V, M)
    output_data = model(input_data)
    print(output_data.shape)  # 예상 출력 형태: (1, 64, 300, 24, 1)