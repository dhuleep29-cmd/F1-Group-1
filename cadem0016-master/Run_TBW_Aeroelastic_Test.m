clear
clc
close all

opts_no = struct();
opts_no.AR = 14;
opts_no.span = 70;
opts_no.lambda = 0.28;
opts_no.sweep = 26;
opts_no.enableAeroelastic = false;

opts_yes = opts_no;
opts_yes.enableAeroelastic = true;
opts_yes.kTheta = 4.0;

R_no  = TBW_StructuralAnalysis('B', 2.5, opts_no);
R_yes = TBW_StructuralAnalysis('B', 2.5, opts_yes);

figure
tiledlayout(4,1)

nexttile
plot(R_no.y(R_no.validMask), R_no.M(R_no.validMask)/1e6, 'LineWidth',1.8); hold on
plot(R_yes.y(R_yes.validMask), R_yes.M(R_yes.validMask)/1e6, 'LineWidth',1.8)
grid on
xlabel('y [m]')
ylabel('Bending moment [MNm]')
legend('No aeroelasticity','With aeroelasticity','Location','best')
title('Bending moment comparison')

nexttile
plot(R_no.y(R_no.validMask), R_no.T(R_no.validMask)/1e6, 'LineWidth',1.8); hold on
plot(R_yes.y(R_yes.validMask), R_yes.T(R_yes.validMask)/1e6, 'LineWidth',1.8)
grid on
xlabel('y [m]')
ylabel('Torque [MNm]')
legend('No aeroelasticity','With aeroelasticity','Location','best')
title('Torque comparison')

nexttile
plot(R_yes.y(R_yes.validMask), R_yes.theta_y_deg(R_yes.validMask), 'LineWidth',1.8)
grid on
xlabel('y [m]')
ylabel('Twist [deg]')
title('Static aeroelastic twist distribution')

nexttile
plot(R_no.y(R_no.validMask), R_no.sigmaVM_y(R_no.validMask)/1e6, 'LineWidth',1.8); hold on
plot(R_yes.y(R_yes.validMask), R_yes.sigmaVM_y(R_yes.validMask)/1e6, 'LineWidth',1.8)
grid on
xlabel('y [m]')
ylabel('von Mises [MPa]')
legend('No aeroelasticity','With aeroelasticity','Location','best')
title('von Mises comparison')