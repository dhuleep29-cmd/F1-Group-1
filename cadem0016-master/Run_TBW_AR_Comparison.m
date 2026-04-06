clear
clc
close all

%% =========================================================
%% ROOT BENDING MOMENT vs ASPECT RATIO
%% Cantilever vs TBW
%% =========================================================

AR_list = [8 10 12 14 16 18];

nCases = length(AR_list);

RootBM_A = zeros(1,nCases);
RootBM_B = zeros(1,nCases);

RootTorque_A = zeros(1,nCases);
RootTorque_B = zeros(1,nCases);

WingMass_A = zeros(1,nCases);
WingMass_B = zeros(1,nCases);

for i = 1:nCases

    AR = AR_list(i);

    opts = struct();
    opts.AR = AR;

    % Cantilever
    A = TBW_StructuralAnalysis('A',2.5,opts);

    % TBW
    B = TBW_StructuralAnalysis('B',2.5,opts);

    RootBM_A(i) = abs(A.RootBM_Nm)/1e6;
    RootBM_B(i) = abs(B.RootBM_Nm)/1e6;

    RootTorque_A(i) = abs(A.RootTorque_Nm)/1e6;
    RootTorque_B(i) = abs(B.RootTorque_Nm)/1e6;

    WingMass_A(i) = A.mWing_Refined_kg/1e3;
    WingMass_B(i) = B.mWing_Refined_kg/1e3;

end

%% =========================================================
%% FIGURE 1 ROOT BENDING MOMENT vs AR
%% =========================================================

figure(1)
plot(AR_list,RootBM_A,'-o','LineWidth',2)
hold on
plot(AR_list,RootBM_B,'-o','LineWidth',2)

grid on

xlabel('Aspect Ratio')
ylabel('Root Bending Moment [MNm]')

title('Root Bending Moment vs Aspect Ratio')

legend('Cantilever Wing','Truss Braced Wing','Location','best')

%% =========================================================
%% FIGURE 2 ROOT TORQUE vs AR
%% =========================================================

figure(2)
plot(AR_list,RootTorque_A,'-o','LineWidth',2)
hold on
plot(AR_list,RootTorque_B,'-o','LineWidth',2)

grid on

xlabel('Aspect Ratio')
ylabel('Root Torque [MNm]')

title('Root Torque vs Aspect Ratio')

legend('Cantilever Wing','Truss Braced Wing','Location','best')

%% =========================================================
%% FIGURE 3 REFINED WING MASS vs AR
%% =========================================================

figure(3)

plot(AR_list,WingMass_A,'-o','LineWidth',2)
hold on
plot(AR_list,WingMass_B,'-o','LineWidth',2)

grid on

xlabel('Aspect Ratio')
ylabel('Refined Wing Mass [t]')

title('Refined Wing Mass vs Aspect Ratio')

legend('Cantilever Wing','Truss Braced Wing','Location','best')

%% =========================================================
%% REDUCTION TABLE
%% =========================================================

fprintf('\n====================================================\n')
fprintf('TBW STRUCTURAL BENEFIT vs ASPECT RATIO\n')
fprintf('====================================================\n')

fprintf('AR | BM Cantilever | BM TBW | Reduction [%%]\n')
fprintf('--------------------------------------------\n')

for i = 1:nCases

    reduction = 100*(RootBM_A(i)-RootBM_B(i))/RootBM_A(i);

    fprintf('%2.0f | %12.3f | %7.3f | %8.2f\n', ...
        AR_list(i),RootBM_A(i),RootBM_B(i),reduction);

end