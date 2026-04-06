clear
clc
close all

%% Frozen TBW design
opts_nom = struct();
opts_nom.AR = 14;
opts_nom.span = 70;
opts_nom.lambda = 0.35;
opts_nom.sweep = 15;
opts_nom.MTOM = 280000;
opts_nom.enableLandingCase = false;

opts_land = opts_nom;
opts_land.enableLandingCase = true;
opts_land.landingLoadFactor = 2.5;
opts_land.yGearFrac = 0.30;

R_nom  = TBW_StructuralAnalysis('B', 2.5, opts_nom);
R_land = TBW_StructuralAnalysis('B', 2.5, opts_land);

maskNom  = R_nom.validMask;
maskLand = R_land.validMask;

fprintf('\n====================================================\n');
fprintf('LANDING CASE CHECK\n');
fprintf('====================================================\n');

fprintf('Nominal root BM   = %.3f MNm\n', abs(R_nom.RootBM_Nm)/1e6);
fprintf('Landing root BM   = %.3f MNm\n', abs(R_land.RootBM_Nm)/1e6);

fprintf('Nominal root shear= %.3f MN\n', abs(R_nom.RootShear_N)/1e6);
fprintf('Landing root shear= %.3f MN\n', abs(R_land.RootShear_N)/1e6);

fprintf('Nominal root torque = %.3f MNm\n', abs(R_nom.RootTorque_Nm)/1e6);
fprintf('Landing root torque = %.3f MNm\n', abs(R_land.RootTorque_Nm)/1e6);

fprintf('Gear reaction load = %.3f MN\n', R_land.gearReaction_N/1e6);
fprintf('Gear station y      = %.3f m\n', R_land.y_gear);

figure(1); clf;
tiledlayout(3,1)

nexttile
plot(R_nom.y(maskNom), R_nom.V(maskNom)/1e6, 'LineWidth', 1.8); hold on
plot(R_land.y(maskLand), R_land.V(maskLand)/1e6, 'LineWidth', 1.8)
grid on
xlabel('y [m]')
ylabel('Shear [MN]')
legend('Nominal 2.5g','Landing case','Location','best')
title('Shear force comparison')

nexttile
plot(R_nom.y(maskNom), R_nom.M(maskNom)/1e6, 'LineWidth', 1.8); hold on
plot(R_land.y(maskLand), R_land.M(maskLand)/1e6, 'LineWidth', 1.8)
grid on
xlabel('y [m]')
ylabel('Bending moment [MNm]')
legend('Nominal 2.5g','Landing case','Location','best')
title('Bending moment comparison')

nexttile
plot(R_nom.y(maskNom), R_nom.T(maskNom)/1e6, 'LineWidth', 1.8); hold on
plot(R_land.y(maskLand), R_land.T(maskLand)/1e6, 'LineWidth', 1.8)
grid on
xlabel('y [m]')
ylabel('Torque [MNm]')
legend('Nominal 2.5g','Landing case','Location','best')
title('Torque comparison')