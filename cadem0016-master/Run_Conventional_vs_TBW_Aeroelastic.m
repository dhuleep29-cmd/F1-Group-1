clear
clc
close all

%% =========================================================
%% Conventional vs TBW with / without aeroelasticity
%% =========================================================

% ---------- common baseline ----------
AR0     = 14;
span0   = 70;
lambda0 = 0.28;
sweep0  = 25;
MTOM0   = 280000;

% ---------- conventional / cantilever ----------
opts_A_rigid = struct();
opts_A_rigid.AR = AR0;
opts_A_rigid.span = span0;
opts_A_rigid.lambda = lambda0;
opts_A_rigid.sweep = sweep0;
opts_A_rigid.MTOM = MTOM0;
opts_A_rigid.enableAeroelastic = false;

opts_A_aero = opts_A_rigid;
opts_A_aero.enableAeroelastic = true;
opts_A_aero.kTheta = 4.0;

% ---------- TBW ----------
opts_B_rigid = struct();
opts_B_rigid.AR = AR0;
opts_B_rigid.span = span0;
opts_B_rigid.lambda = lambda0;
opts_B_rigid.sweep = sweep0;
opts_B_rigid.MTOM = MTOM0;
opts_B_rigid.enableAeroelastic = false;

opts_B_aero = opts_B_rigid;
opts_B_aero.enableAeroelastic = true;
opts_B_aero.kTheta = 4.0;

% optional: keep default strut settings for TBW
% opts_B_rigid.strutShare = 0.25;
% opts_B_aero.strutShare  = 0.25;

%% ---------------- run cases ----------------
A_rigid = TBW_StructuralAnalysis('A', 2.5, opts_A_rigid);
A_aero  = TBW_StructuralAnalysis('A', 2.5, opts_A_aero);

B_rigid = TBW_StructuralAnalysis('B', 2.5, opts_B_rigid);
B_aero  = TBW_StructuralAnalysis('B', 2.5, opts_B_aero);

maskA_r = A_rigid.validMask;
maskA_a = A_aero.validMask;
maskB_r = B_rigid.validMask;
maskB_a = B_aero.validMask;

%% ---------------- print summary ----------------
fprintf('\n====================================================\n');
fprintf('CONVENTIONAL vs TBW | RIGID vs AEROELASTIC\n');
fprintf('====================================================\n');

fprintf('\n--- Root Bending Moment [MNm] ---\n');
fprintf('A rigid : %.3f\n', abs(A_rigid.RootBM_Nm)/1e6);
fprintf('A aero  : %.3f\n', abs(A_aero.RootBM_Nm)/1e6);
fprintf('B rigid : %.3f\n', abs(B_rigid.RootBM_Nm)/1e6);
fprintf('B aero  : %.3f\n', abs(B_aero.RootBM_Nm)/1e6);

fprintf('\n--- Root Torque [MNm] ---\n');
fprintf('A rigid : %.3f\n', abs(A_rigid.RootTorque_Nm)/1e6);
fprintf('A aero  : %.3f\n', abs(A_aero.RootTorque_Nm)/1e6);
fprintf('B rigid : %.3f\n', abs(B_rigid.RootTorque_Nm)/1e6);
fprintf('B aero  : %.3f\n', abs(B_aero.RootTorque_Nm)/1e6);

fprintf('\n--- Max von Mises [MPa] ---\n');
fprintf('A rigid : %.2f\n', max(A_rigid.sigmaVM_y(maskA_r))/1e6);
fprintf('A aero  : %.2f\n', max(A_aero.sigmaVM_y(maskA_a))/1e6);
fprintf('B rigid : %.2f\n', max(B_rigid.sigmaVM_y(maskB_r))/1e6);
fprintf('B aero  : %.2f\n', max(B_aero.sigmaVM_y(maskB_a))/1e6);

fprintf('\n--- Root twist [deg] (reported at first valid point) ---\n');
fprintf('A aero  : %.3f\n', A_aero.theta_y_deg(1));
fprintf('B aero  : %.3f\n', B_aero.theta_y_deg(1));

%% =========================================================
%% FIGURE 1: Bending moment comparison
%% =========================================================
figure(1); clf;
plot(A_rigid.y(maskA_r), A_rigid.M(maskA_r)/1e6, 'LineWidth', 2); hold on
plot(A_aero.y(maskA_a),  A_aero.M(maskA_a)/1e6,  '--', 'LineWidth', 2)
plot(B_rigid.y(maskB_r), B_rigid.M(maskB_r)/1e6, 'LineWidth', 2)
plot(B_aero.y(maskB_a),  B_aero.M(maskB_a)/1e6,  '--', 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('Bending moment [MNm]')
title('Conventional vs TBW: rigid and aeroelastic bending moment')
legend('Conventional rigid','Conventional aeroelastic', ...
       'TBW rigid','TBW aeroelastic', 'Location','best')

%% =========================================================
%% FIGURE 2: Torque comparison
%% =========================================================
figure(2); clf;
plot(A_rigid.y(maskA_r), A_rigid.T(maskA_r)/1e6, 'LineWidth', 2); hold on
plot(A_aero.y(maskA_a),  A_aero.T(maskA_a)/1e6,  '--', 'LineWidth', 2)
plot(B_rigid.y(maskB_r), B_rigid.T(maskB_r)/1e6, 'LineWidth', 2)
plot(B_aero.y(maskB_a),  B_aero.T(maskB_a)/1e6,  '--', 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('Torque [MNm]')
title('Conventional vs TBW: rigid and aeroelastic torque')
legend('Conventional rigid','Conventional aeroelastic', ...
       'TBW rigid','TBW aeroelastic', 'Location','best')

%% =========================================================
%% FIGURE 3: von Mises comparison
%% =========================================================
figure(3); clf;
plot(A_rigid.y(maskA_r), A_rigid.sigmaVM_y(maskA_r)/1e6, 'LineWidth', 2); hold on
plot(A_aero.y(maskA_a),  A_aero.sigmaVM_y(maskA_a)/1e6,  '--', 'LineWidth', 2)
plot(B_rigid.y(maskB_r), B_rigid.sigmaVM_y(maskB_r)/1e6, 'LineWidth', 2)
plot(B_aero.y(maskB_a),  B_aero.sigmaVM_y(maskB_a)/1e6,  '--', 'LineWidth', 2)
yline(A_rigid.sigmaY_Pa/1e6, ':', 'Yield', 'LineWidth', 1.5)
yline(A_rigid.sigmaAllow_Pa/1e6, '--', 'Allowable', 'LineWidth', 1.5)
grid on
xlabel('y [m]')
ylabel('von Mises stress [MPa]')
title('Conventional vs TBW: rigid and aeroelastic von Mises stress')
legend('Conventional rigid','Conventional aeroelastic', ...
       'TBW rigid','TBW aeroelastic', 'Location','best')

%% =========================================================
%% FIGURE 4: Twist comparison
%% =========================================================
figure(4); clf;
plot(A_aero.y(maskA_a), A_aero.theta_y_deg(maskA_a), 'LineWidth', 2); hold on
plot(B_aero.y(maskB_a), B_aero.theta_y_deg(maskB_a), 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('Twist [deg]')
title('Conventional vs TBW: aeroelastic twist distribution')
legend('Conventional aeroelastic','TBW aeroelastic','Location','best')

%% =========================================================
%% FIGURE 5: Shear comparison
%% =========================================================
figure(5); clf;
plot(A_rigid.y(maskA_r), A_rigid.V(maskA_r)/1e6, 'LineWidth', 2); hold on
plot(A_aero.y(maskA_a),  A_aero.V(maskA_a)/1e6,  '--', 'LineWidth', 2)
plot(B_rigid.y(maskB_r), B_rigid.V(maskB_r)/1e6, 'LineWidth', 2)
plot(B_aero.y(maskB_a),  B_aero.V(maskB_a)/1e6,  '--', 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('Shear [MN]')
title('Conventional vs TBW: rigid and aeroelastic shear')
legend('Conventional rigid','Conventional aeroelastic', ...
       'TBW rigid','TBW aeroelastic', 'Location','best')

%% =========================================================
%% FIGURE 6: Summary bar chart at root
%% =========================================================
figure(6); clf;

BMvals = [abs(A_rigid.RootBM_Nm), abs(A_aero.RootBM_Nm), ...
          abs(B_rigid.RootBM_Nm), abs(B_aero.RootBM_Nm)]/1e6;

Tvals  = [abs(A_rigid.RootTorque_Nm), abs(A_aero.RootTorque_Nm), ...
          abs(B_rigid.RootTorque_Nm), abs(B_aero.RootTorque_Nm)]/1e6;

VMvals = [max(A_rigid.sigmaVM_y(maskA_r)), max(A_aero.sigmaVM_y(maskA_a)), ...
          max(B_rigid.sigmaVM_y(maskB_r)), max(B_aero.sigmaVM_y(maskB_a))]/1e6;

subplot(3,1,1)
bar(BMvals)
grid on
ylabel('Root BM [MNm]')
title('Root response summary')
set(gca,'XTickLabel',{'A rigid','A aero','B rigid','B aero'})

subplot(3,1,2)
bar(Tvals)
grid on
ylabel('Root torque [MNm]')
set(gca,'XTickLabel',{'A rigid','A aero','B rigid','B aero'})

subplot(3,1,3)
bar(VMvals)
grid on
ylabel('Max VM [MPa]')
set(gca,'XTickLabel',{'A rigid','A aero','B rigid','B aero'})