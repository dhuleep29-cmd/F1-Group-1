clear
clc
close all

%% =========================================================
%% EI(y) and GJ(y) distributions
%% Final frozen configurations
%% =========================================================

% ---------- Conventional ----------
optsA = struct();
optsA.AR = 12;
optsA.span = 70;
optsA.lambda = 0.35;
optsA.sweep = 26;
optsA.MTOM = 350000;
optsA.enableAeroelastic = false;

% ---------- TBW ----------
optsB = struct();
optsB.AR = 14;
optsB.span = 70;
optsB.lambda = 0.35;
optsB.sweep = 26;
optsB.MTOM = 350000;
optsB.enableAeroelastic = false;

RA = TBW_StructuralAnalysis('A', 2.5, optsA);
RB = TBW_StructuralAnalysis('B', 2.5, optsB);

maskA = RA.validMask;
maskB = RB.validMask;

%% ---------------- print root values ----------------
fprintf('\n====================================================\n');
fprintf('EI(y) and GJ(y) DISTRIBUTIONS\n');
fprintf('====================================================\n');

fprintf('\n--- Conventional ---\n');
fprintf('Root EI  = %.3e N m^2\n', RA.EI_y_Nm2(1));
fprintf('Root GJ  = %.3e N m^2\n', RA.GJ_y_Nm2(1));

fprintf('\n--- TBW ---\n');
fprintf('Root EI  = %.3e N m^2\n', RB.EI_y_Nm2(1));
fprintf('Root GJ  = %.3e N m^2\n', RB.GJ_y_Nm2(1));

%% ---------------- Figure 1: EI distribution ----------------
figure(1); clf;
plot(RA.y(maskA), RA.EI_y_Nm2(maskA), 'LineWidth', 2); hold on
plot(RB.y(maskB), RB.EI_y_Nm2(maskB), 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('EI(y) [N m^2]')
title('Spanwise bending stiffness distribution')
legend('Conventional','TBW','Location','best')

%% ---------------- Figure 2: GJ distribution ----------------
figure(2); clf;
plot(RA.y(maskA), RA.GJ_y_Nm2(maskA), 'LineWidth', 2); hold on
plot(RB.y(maskB), RB.GJ_y_Nm2(maskB), 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('GJ(y) [N m^2]')
title('Spanwise torsional stiffness distribution')
legend('Conventional','TBW','Location','best')

%% ---------------- Figure 3: Iyy distribution ----------------
figure(3); clf;
plot(RA.y(maskA), RA.Iyy_y_m4(maskA), 'LineWidth', 2); hold on
plot(RB.y(maskB), RB.Iyy_y_m4(maskB), 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('I_{yy}(y) [m^4]')
title('Spanwise second moment of area distribution')
legend('Conventional','TBW','Location','best')

%% ---------------- Figure 4: normalized comparison ----------------
figure(4); clf;
plot(RA.y(maskA), RA.EI_y_Nm2(maskA)/max(RA.EI_y_Nm2(maskA)), 'LineWidth', 2); hold on
plot(RB.y(maskB), RB.EI_y_Nm2(maskB)/max(RB.EI_y_Nm2(maskB)), 'LineWidth', 2)
plot(RA.y(maskA), RA.GJ_y_Nm2(maskA)/max(RA.GJ_y_Nm2(maskA)), '--', 'LineWidth', 2)
plot(RB.y(maskB), RB.GJ_y_Nm2(maskB)/max(RB.GJ_y_Nm2(maskB)), '--', 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('Normalized stiffness [-]')
title('Normalized EI and GJ distributions')
legend('EI Conventional','EI TBW','GJ Conventional','GJ TBW','Location','best')