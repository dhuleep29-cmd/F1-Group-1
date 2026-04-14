clear
clc
close all

opts_no = struct();
opts_no.AR = 14;
opts_no.span = 70;
opts_no.lambda = 0.35;
opts_no.sweep = 15;
opts_no.MTOM = 350000;
opts_no.enableEngineLoad = false;

opts_eng = opts_no;
opts_eng.enableEngineLoad = true;
opts_eng.mEngine_kg = 7000;
opts_eng.yEngineFrac = 0.25;

R_no  = TBW_StructuralAnalysis('B', 2.5, opts_no);
R_eng = TBW_StructuralAnalysis('B', 2.5, opts_eng);

maskNo  = R_no.validMask;
maskEng = R_eng.validMask;

fprintf('\n====================================================\n');
fprintf('ENGINE LOAD CHECK\n');
fprintf('====================================================\n');
fprintf('Nominal root BM     = %.3f MNm\n', abs(R_no.RootBM_Nm)/1e6);
fprintf('With engine root BM = %.3f MNm\n', abs(R_eng.RootBM_Nm)/1e6);

fprintf('Nominal root torque     = %.3f MNm\n', abs(R_no.RootTorque_Nm)/1e6);
fprintf('With engine root torque = %.3f MNm\n', abs(R_eng.RootTorque_Nm)/1e6);

fprintf('Engine station y = %.3f m\n', R_eng.y_engine);
fprintf('Engine weight    = %.3f kN\n', R_eng.engineWeight_N/1e3);

figure(1); clf;
tiledlayout(3,1)

nexttile
plot(R_no.y(maskNo), R_no.V(maskNo)/1e6, 'LineWidth',1.8); hold on
plot(R_eng.y(maskEng), R_eng.V(maskEng)/1e6, 'LineWidth',1.8)
grid on
xlabel('y [m]')
ylabel('Shear [MN]')
legend('No engine','With engine','Location','best')
title('Shear comparison')

nexttile
plot(R_no.y(maskNo), R_no.M(maskNo)/1e6, 'LineWidth',1.8); hold on
plot(R_eng.y(maskEng), R_eng.M(maskEng)/1e6, 'LineWidth',1.8)
grid on
xlabel('y [m]')
ylabel('Bending moment [MNm]')
legend('No engine','With engine','Location','best')
title('Bending moment comparison')

nexttile
plot(R_no.y(maskNo), R_no.T(maskNo)/1e6, 'LineWidth',1.8); hold on
plot(R_eng.y(maskEng), R_eng.T(maskEng)/1e6, 'LineWidth',1.8)
grid on
xlabel('y [m]')
ylabel('Torque [MNm]')
legend('No engine','With engine','Location','best')
title('Torque comparison')
