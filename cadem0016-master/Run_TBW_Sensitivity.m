clear; clc; close all;

%% Baseline reference
A_ref = TBW_StructuralAnalysis('A', 2.5);
B_ref = TBW_StructuralAnalysis('B', 2.5);

fprintf('\n=== BASELINE 2.5g ===\n');
fprintf('A Root BM      : %.3f MNm\n', A_ref.RootBM_Nm/1e6);
fprintf('B Root BM      : %.3f MNm\n', B_ref.RootBM_Nm/1e6);
fprintf('A Root Torque  : %.3f MNm\n', A_ref.RootTorque_Nm/1e6);
fprintf('B Root Torque  : %.3f MNm\n', B_ref.RootTorque_Nm/1e6);

%% 1) kwing sensitivity
kvals = [180 200 220];
BM_k = zeros(size(kvals));
T_k  = zeros(size(kvals));

for i = 1:numel(kvals)
    R = TBW_StructuralAnalysis('B', 2.5, struct('kwing', kvals(i)));
    BM_k(i) = R.RootBM_Nm/1e6;
    T_k(i)  = R.RootTorque_Nm/1e6;
end

%% 2) strutShare sensitivity
svals = [0.20 0.25 0.30];
BM_s = zeros(size(svals));
T_s  = zeros(size(svals));

for i = 1:numel(svals)
    R = TBW_StructuralAnalysis('B', 2.5, struct('strutShare', svals(i)));
    BM_s(i) = R.RootBM_Nm/1e6;
    T_s(i)  = R.RootTorque_Nm/1e6;
end

%% 3) strut location sensitivity
yvals = [0.40 0.45 0.50];
BM_y = zeros(size(yvals));
T_y  = zeros(size(yvals));

for i = 1:numel(yvals)
    R = TBW_StructuralAnalysis('B', 2.5, struct('yStrutFrac', yvals(i)));
    BM_y(i) = R.RootBM_Nm/1e6;
    T_y(i)  = R.RootTorque_Nm/1e6;
end

%% Print tables
fprintf('\n=== TBW 2.5g: kwing sensitivity ===\n');
for i = 1:numel(kvals)
    fprintf('kwing = %3.0f kg/m^2  | Root BM = %6.3f MNm | Root Torque = %6.3f MNm\n', ...
        kvals(i), BM_k(i), T_k(i));
end

fprintf('\n=== TBW 2.5g: strutShare sensitivity ===\n');
for i = 1:numel(svals)
    fprintf('strutShare = %4.2f     | Root BM = %6.3f MNm | Root Torque = %6.3f MNm\n', ...
        svals(i), BM_s(i), T_s(i));
end

fprintf('\n=== TBW 2.5g: yStrutFrac sensitivity ===\n');
for i = 1:numel(yvals)
    fprintf('yStrutFrac = %4.2f     | Root BM = %6.3f MNm | Root Torque = %6.3f MNm\n', ...
        yvals(i), BM_y(i), T_y(i));
end

%% Plots
figure(1); clf;
tiledlayout(3,1);

nexttile;
plot(kvals, BM_k, '-o', 'LineWidth', 1.8); hold on;
plot(kvals, T_k, '-s', 'LineWidth', 1.8);
grid on;
xlabel('kwing [kg/m^2]');
ylabel('Root load [MNm]');
legend('Root BM','Root Torque','Location','best');
title('TBW 2.5g sensitivity to kwing');

nexttile;
plot(svals, BM_s, '-o', 'LineWidth', 1.8); hold on;
plot(svals, T_s, '-s', 'LineWidth', 1.8);
grid on;
xlabel('strutShare [-]');
ylabel('Root load [MNm]');
legend('Root BM','Root Torque','Location','best');
title('TBW 2.5g sensitivity to strutShare');

nexttile;
plot(yvals, BM_y, '-o', 'LineWidth', 1.8); hold on;
plot(yvals, T_y, '-s', 'LineWidth', 1.8);
grid on;
xlabel('yStrutFrac of semi-span [-]');
ylabel('Root load [MNm]');
legend('Root BM','Root Torque','Location','best');
title('TBW 2.5g sensitivity to strut location');