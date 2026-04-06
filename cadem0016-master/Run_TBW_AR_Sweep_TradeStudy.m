clear
clc
close all

%% =========================================================
%% PARAMETRIC STUDY: AR vs SWEEP
%% =========================================================

AR_list = [10 12 14 16];
sweep_list = [0 10 20 30 40];

nAR = length(AR_list);
nSW = length(sweep_list);

RootTorque_MNm   = zeros(nAR,nSW);
MaxShear_MPa     = zeros(nAR,nSW);
MaxVM_MPa        = zeros(nAR,nSW);
tTorsion_mm      = zeros(nAR,nSW);
RootBM_MNm       = zeros(nAR,nSW);
WingMass_t       = zeros(nAR,nSW);

%% ---------------- run study ----------------
for i = 1:nAR
    for j = 1:nSW

        opts = struct();
        opts.AR = AR_list(i);
        opts.sweep = sweep_list(j);

        R = TBW_StructuralAnalysis('B', 2.5, opts);

        RootTorque_MNm(i,j) = abs(R.RootTorque_Nm)/1e6;
        MaxShear_MPa(i,j)   = max(R.tauTotal_y(R.validMask))/1e6;
        MaxVM_MPa(i,j)      = max(R.sigmaVM_y(R.validMask))/1e6;
        tTorsion_mm(i,j)    = R.tTorsion_req_m*1e3;
        RootBM_MNm(i,j)     = abs(R.RootBM_Nm)/1e6;
        WingMass_t(i,j)     = R.mWing_Refined_kg/1e3;

        Store{i,j} = R;
    end
end

%% =========================================================
%% PRINT RESULTS TABLES
%% =========================================================
fprintf('\n====================================================\n');
fprintf('AR vs SWEEP TRADE STUDY (CONFIG B, 2.5g)\n');
fprintf('====================================================\n');

for i = 1:nAR
    fprintf('\nAR = %.1f\n', AR_list(i));
    fprintf('Sweep [deg] | RootBM [MNm] | RootTorque [MNm] | MaxShear [MPa] | MaxVM [MPa] | tTorsion [mm] | WingMass [t]\n');
    fprintf('-------------------------------------------------------------------------------------------------------------\n');
    for j = 1:nSW
        fprintf('%11.1f | %12.3f | %16.3f | %14.2f | %11.2f | %13.3f | %11.2f\n', ...
            sweep_list(j), RootBM_MNm(i,j), RootTorque_MNm(i,j), ...
            MaxShear_MPa(i,j), MaxVM_MPa(i,j), tTorsion_mm(i,j), WingMass_t(i,j));
    end
end

%% =========================================================
%% FIGURE 1: ROOT TORQUE VS SWEEP FOR DIFFERENT AR
%% =========================================================
figure(1); clf; hold on
for i = 1:nAR
    plot(sweep_list, RootTorque_MNm(i,:), '-o', 'LineWidth', 2)
end
grid on
xlabel('Sweep angle [deg]')
ylabel('Root torque [MNm]')
title('Root torque vs sweep for different AR')
legend("AR="+string(AR_list), 'Location','best')

%% =========================================================
%% FIGURE 2: MAX SHEAR STRESS VS SWEEP
%% =========================================================
figure(2); clf; hold on
for i = 1:nAR
    plot(sweep_list, MaxShear_MPa(i,:), '-o', 'LineWidth', 2)
end
grid on
xlabel('Sweep angle [deg]')
ylabel('Max shear stress [MPa]')
title('Max shear stress vs sweep for different AR')
legend("AR="+string(AR_list), 'Location','best')

%% =========================================================
%% FIGURE 3: MAX VON MISES STRESS VS SWEEP
%% =========================================================
figure(3); clf; hold on
for i = 1:nAR
    plot(sweep_list, MaxVM_MPa(i,:), '-o', 'LineWidth', 2)
end
grid on
xlabel('Sweep angle [deg]')
ylabel('Max von Mises stress [MPa]')
title('Max von Mises stress vs sweep for different AR')
legend("AR="+string(AR_list), 'Location','best')

%% =========================================================
%% FIGURE 4: REQUIRED TORSION THICKNESS VS SWEEP
%% =========================================================
figure(4); clf; hold on
for i = 1:nAR
    plot(sweep_list, tTorsion_mm(i,:), '-o', 'LineWidth', 2)
end
grid on
xlabel('Sweep angle [deg]')
ylabel('Required torsion thickness [mm]')
title('Required torsion thickness vs sweep for different AR')
legend("AR="+string(AR_list), 'Location','best')

%% =========================================================
%% FIGURE 5: ROOT BENDING MOMENT VS SWEEP
%% =========================================================
figure(5); clf; hold on
for i = 1:nAR
    plot(sweep_list, RootBM_MNm(i,:), '-o', 'LineWidth', 2)
end
grid on
xlabel('Sweep angle [deg]')
ylabel('Root bending moment [MNm]')
title('Root bending moment vs sweep for different AR')
legend("AR="+string(AR_list), 'Location','best')

%% =========================================================
%% FIGURE 6: REFINED WING MASS VS SWEEP
%% =========================================================
figure(6); clf; hold on
for i = 1:nAR
    plot(sweep_list, WingMass_t(i,:), '-o', 'LineWidth', 2)
end
grid on
xlabel('Sweep angle [deg]')
ylabel('Refined wing mass [t]')
title('Refined wing mass vs sweep for different AR')
legend("AR="+string(AR_list), 'Location','best')

%% =========================================================
%% FIGURE 7: HEATMAP ROOT TORQUE
%% =========================================================
figure(7); clf
imagesc(sweep_list, AR_list, RootTorque_MNm)
set(gca,'YDir','normal')
colorbar
xlabel('Sweep angle [deg]')
ylabel('Aspect ratio [-]')
title('Heatmap: Root torque [MNm]')

%% =========================================================
%% FIGURE 8: HEATMAP MAX VON MISES
%% =========================================================
figure(8); clf
imagesc(sweep_list, AR_list, MaxVM_MPa)
set(gca,'YDir','normal')
colorbar
xlabel('Sweep angle [deg]')
ylabel('Aspect ratio [-]')
title('Heatmap: Max von Mises stress [MPa]')

%% =========================================================
%% FIGURE 9: HEATMAP REQUIRED TORSION THICKNESS
%% =========================================================
figure(9); clf
imagesc(sweep_list, AR_list, tTorsion_mm)
set(gca,'YDir','normal')
colorbar
xlabel('Sweep angle [deg]')
ylabel('Aspect ratio [-]')
title('Heatmap: Required torsion thickness [mm]')

%% =========================================================
%% FIGURE 10: TORQUE DISTRIBUTION FOR BEST/WORST CASES
%% choose best = minimum torsion thickness
%% choose worst = maximum torsion thickness
[minVal, idxMin] = min(tTorsion_mm(:));
[maxVal, idxMax] = max(tTorsion_mm(:));

[iMin, jMin] = ind2sub(size(tTorsion_mm), idxMin);
[iMax, jMax] = ind2sub(size(tTorsion_mm), idxMax);

Rbest  = Store{iMin,jMin};
Rworst = Store{iMax,jMax};

figure(10); clf
plot(Rbest.y(Rbest.validMask), Rbest.T(Rbest.validMask)/1e6, 'LineWidth', 2); hold on
plot(Rworst.y(Rworst.validMask), Rworst.T(Rworst.validMask)/1e6, 'LineWidth', 2);
grid on
xlabel('y [m]')
ylabel('Torque [MNm]')
title('Torque distribution: best vs worst torsion-thickness case')
legend( ...
    sprintf('Best: AR=%.0f, sweep=%.0f deg', AR_list(iMin), sweep_list(jMin)), ...
    sprintf('Worst: AR=%.0f, sweep=%.0f deg', AR_list(iMax), sweep_list(jMax)), ...
    'Location','best')

%% =========================================================
%% SIMPLE SCORE FOR STRUCTURAL DOWN-SELECTION
%% lower is better
RootTorque_norm = RootTorque_MNm / max(RootTorque_MNm(:));
MaxShear_norm   = MaxShear_MPa   / max(MaxShear_MPa(:));
MaxVM_norm      = MaxVM_MPa      / max(MaxVM_MPa(:));
tTorsion_norm   = tTorsion_mm    / max(tTorsion_mm(:));
WingMass_norm   = WingMass_t     / max(WingMass_t(:));

Score = 0.30*RootTorque_norm + ...
        0.20*MaxShear_norm + ...
        0.20*MaxVM_norm + ...
        0.20*tTorsion_norm + ...
        0.10*WingMass_norm;

[minScore, idxBest] = min(Score(:));
[iBest, jBest] = ind2sub(size(Score), idxBest);

fprintf('\n====================================================\n');
fprintf('BEST STRUCTURAL TRADE-STUDY POINT\n');
fprintf('====================================================\n');
fprintf('Best AR           : %.1f\n', AR_list(iBest));
fprintf('Best sweep        : %.1f deg\n', sweep_list(jBest));
fprintf('Best score        : %.4f\n', minScore);
fprintf('Root BM           : %.3f MNm\n', RootBM_MNm(iBest,jBest));
fprintf('Root torque       : %.3f MNm\n', RootTorque_MNm(iBest,jBest));
fprintf('Max shear stress  : %.2f MPa\n', MaxShear_MPa(iBest,jBest));
fprintf('Max von Mises     : %.2f MPa\n', MaxVM_MPa(iBest,jBest));
fprintf('Torsion thickness : %.3f mm\n', tTorsion_mm(iBest,jBest));
fprintf('Refined wing mass : %.2f t\n', WingMass_t(iBest,jBest));

figure(11); clf
imagesc(sweep_list, AR_list, Score)
set(gca,'YDir','normal')
colorbar
xlabel('Sweep angle [deg]')
ylabel('Aspect ratio [-]')
title('Structural trade-study score (lower is better)')