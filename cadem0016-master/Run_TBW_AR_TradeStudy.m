clear; clc; close all;

ARvals = [10 12 14];
hBoxRatio = 0.12;       % keep fixed for this study
nCase = 2.5;

%% ---------------- arrays ----------------
BM_A = zeros(size(ARvals));
BM_B = zeros(size(ARvals));

T_A = zeros(size(ARvals));
T_B = zeros(size(ARvals));

Mref_A = zeros(size(ARvals));
Mref_B = zeros(size(ARvals));

DiProxy = zeros(size(ARvals));   % induced-drag proxy, normalized to AR=10

%% ---------------- run study ----------------
for i = 1:length(ARvals)
    ARi = ARvals(i);

    A = TBW_StructuralAnalysis('A', nCase, struct('AR', ARi, 'hBoxRatio', hBoxRatio));
    B = TBW_StructuralAnalysis('B', nCase, struct('AR', ARi, 'hBoxRatio', hBoxRatio));

    BM_A(i) = A.RootBM_Nm/1e6;
    BM_B(i) = B.RootBM_Nm/1e6;

    T_A(i) = A.RootTorque_Nm/1e6;
    T_B(i) = B.RootTorque_Nm/1e6;

    Mref_A(i) = A.mWing_Refined_kg/1e3;
    Mref_B(i) = B.mWing_Refined_kg/1e3;

    % normalized induced-drag proxy (lower is better)
    DiProxy(i) = 10 / ARi;
end

%% ---------------- normalized trade metrics ----------------
% Normalize to AR=10 values for Config B (TBW)
BM_norm = BM_B / BM_B(1);
T_norm = T_B / T_B(1);
Mref_norm = Mref_B / Mref_B(1);
Di_norm = DiProxy / DiProxy(1);

% Example combined score (lower = better)
% More weight on bending + mass, but aero benefit included
TradeScore = 0.45*BM_norm + 0.35*Mref_norm + 0.20*Di_norm;

%% ---------------- print summary ----------------
fprintf('\n====================================================\n');
fprintf('AR TRADE STUDY (Config B, 2.5g)\n');
fprintf('====================================================\n');
fprintf('AR   RootBM[MNm]   RootTorque[MNm]   RefMass[t]   DiProxy[-]   TradeScore[-]\n');

for i = 1:length(ARvals)
    fprintf('%2.0f   %10.3f      %10.3f      %8.3f    %8.3f     %8.3f\n', ...
        ARvals(i), BM_B(i), T_B(i), Mref_B(i), DiProxy(i), TradeScore(i));
end

%% ---------------- compare A vs B ----------------
fprintf('\n====================================================\n');
fprintf('A vs B ROOT BM COMPARISON (2.5g)\n');
fprintf('====================================================\n');
fprintf('AR   A_RootBM[MNm]   B_RootBM[MNm]   TBW_Reduction[%%]\n');

for i = 1:length(ARvals)
    red = 100*(BM_A(i)-BM_B(i))/BM_A(i);
    fprintf('%2.0f    %10.3f      %10.3f        %8.2f\n', ...
        ARvals(i), BM_A(i), BM_B(i), red);
end

%% ---------------- find strutShare needed for AR=14 ----------------
targetBM = BM_B(1);   % target = AR=10 TBW root BM
shareVals = 0.10:0.01:0.60;
BM_share = zeros(size(shareVals));

for i = 1:length(shareVals)
    R = TBW_StructuralAnalysis('B', nCase, struct( ...
        'AR', 14, ...
        'hBoxRatio', hBoxRatio, ...
        'strutShare', shareVals(i)));
    BM_share(i) = R.RootBM_Nm/1e6;
end

[~, idxBest] = min(abs(BM_share - targetBM));
reqShare = shareVals(idxBest);
reqBM = BM_share(idxBest);

fprintf('\n====================================================\n');
fprintf('AR=14 REQUIRED STRUT SHARE STUDY\n');
fprintf('====================================================\n');
fprintf('Target root BM (AR=10 TBW) : %.3f MNm\n', targetBM);
fprintf('Best strutShare found      : %.2f\n', reqShare);
fprintf('Resulting root BM          : %.3f MNm\n', reqBM);

%% ---------------- plots ----------------
figure(1); clf;
tiledlayout(2,2);

nexttile;
plot(ARvals, BM_A, '-o', 'LineWidth', 1.8); hold on;
plot(ARvals, BM_B, '-s', 'LineWidth', 1.8);
grid on;
xlabel('Aspect Ratio');
ylabel('Root BM [MNm]');
legend('Config A','Config B','Location','best');
title('2.5g root bending moment vs AR');

nexttile;
plot(ARvals, Mref_A, '-o', 'LineWidth', 1.8); hold on;
plot(ARvals, Mref_B, '-s', 'LineWidth', 1.8);
grid on;
xlabel('Aspect Ratio');
ylabel('Refined mass [t]');
legend('Config A','Config B','Location','best');
title('2.5g refined mass vs AR');

nexttile;
plot(ARvals, DiProxy, '-^', 'LineWidth', 1.8);
grid on;
xlabel('Aspect Ratio');
ylabel('Induced-drag proxy [-]');
title('Aerodynamic benefit proxy vs AR');

nexttile;
plot(ARvals, TradeScore, '-d', 'LineWidth', 1.8);
grid on;
xlabel('Aspect Ratio');
ylabel('Trade score [-]');
title('Combined trade score (lower is better)');

figure(2); clf;

ARcompare = [10 12 14];
BM_share_all = zeros(length(ARcompare), length(shareVals));

for k = 1:length(ARcompare)
    ARk = ARcompare(k);
    for i = 1:length(shareVals)
        R = TBW_StructuralAnalysis('B', nCase, struct( ...
            'AR', ARk, ...
            'hBoxRatio', hBoxRatio, ...
            'strutShare', shareVals(i)));
        BM_share_all(k,i) = R.RootBM_Nm/1e6;
    end
end

plot(shareVals, BM_share_all(1,:), '-o', 'LineWidth', 1.8); hold on;
plot(shareVals, BM_share_all(2,:), '-s', 'LineWidth', 1.8);
plot(shareVals, BM_share_all(3,:), '-^', 'LineWidth', 1.8);

grid on;
xlabel('strutShare [-]');
ylabel('Root BM [MNm]');
title('TBW root bending vs strutShare for AR = 10, 12, 14');
legend('AR = 10','AR = 12','AR = 14','Location','best');