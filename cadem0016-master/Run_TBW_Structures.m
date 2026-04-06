clear; clc; close all;

%% ---------------- basic manoeuvre cases ----------------
Aneg1 = TBW_StructuralAnalysis('A', -1.0);
Bneg1 = TBW_StructuralAnalysis('B', -1.0);

A1 = TBW_StructuralAnalysis('A', 1.0);
B1 = TBW_StructuralAnalysis('B', 1.0);

A25 = TBW_StructuralAnalysis('A', 2.5);
B25 = TBW_StructuralAnalysis('B', 2.5);

%% ---------------- gust cases ----------------
A_upgust   = TBW_StructuralAnalysis('A', 1.416);
A_downgust = TBW_StructuralAnalysis('A', 0.584);

B_upgust   = TBW_StructuralAnalysis('B', 1.498);
B_downgust = TBW_StructuralAnalysis('B', 0.502);

%% ---------------- root bending moment summary ----------------
fprintf('\n====================================================\n');
fprintf('ROOT BENDING MOMENT SUMMARY [MNm]\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('-1g         : %.3f\n', Aneg1.RootBM_Nm/1e6);
fprintf('1g          : %.3f\n', A1.RootBM_Nm/1e6);
fprintf('2.5g        : %.3f\n', A25.RootBM_Nm/1e6);
fprintf('Up-gust     : %.3f\n', A_upgust.RootBM_Nm/1e6);
fprintf('Down-gust   : %.3f\n', A_downgust.RootBM_Nm/1e6);

fprintf('\n--- Config B ---\n');
fprintf('-1g         : %.3f\n', Bneg1.RootBM_Nm/1e6);
fprintf('1g          : %.3f\n', B1.RootBM_Nm/1e6);
fprintf('2.5g        : %.3f\n', B25.RootBM_Nm/1e6);
fprintf('Up-gust     : %.3f\n', B_upgust.RootBM_Nm/1e6);
fprintf('Down-gust   : %.3f\n', B_downgust.RootBM_Nm/1e6);

%% ---------------- reduction vs baseline A ----------------
fprintf('\n====================================================\n');
fprintf('TBW ROOT BM REDUCTION vs BASELINE A [%%]\n');
fprintf('====================================================\n');

fprintf('-1g         : %.2f %%\n', ...
    100*(abs(Aneg1.RootBM_Nm)-abs(Bneg1.RootBM_Nm))/abs(Aneg1.RootBM_Nm));

fprintf('1g          : %.2f %%\n', ...
    100*(abs(A1.RootBM_Nm)-abs(B1.RootBM_Nm))/abs(A1.RootBM_Nm));

fprintf('2.5g        : %.2f %%\n', ...
    100*(abs(A25.RootBM_Nm)-abs(B25.RootBM_Nm))/abs(A25.RootBM_Nm));

fprintf('Up-gust     : %.2f %%\n', ...
    100*(abs(A_upgust.RootBM_Nm)-abs(B_upgust.RootBM_Nm))/abs(A_upgust.RootBM_Nm));

fprintf('Down-gust   : %.2f %%\n', ...
    100*(abs(A_downgust.RootBM_Nm)-abs(B_downgust.RootBM_Nm))/abs(A_downgust.RootBM_Nm));

%% ---------------- root torque summary ----------------
fprintf('\n====================================================\n');
fprintf('ROOT TORQUE SUMMARY [MNm]\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('-1g         : %.3f\n', Aneg1.RootTorque_Nm/1e6);
fprintf('1g          : %.3f\n', A1.RootTorque_Nm/1e6);
fprintf('2.5g        : %.3f\n', A25.RootTorque_Nm/1e6);
fprintf('Up-gust     : %.3f\n', A_upgust.RootTorque_Nm/1e6);
fprintf('Down-gust   : %.3f\n', A_downgust.RootTorque_Nm/1e6);

fprintf('\n--- Config B ---\n');
fprintf('-1g         : %.3f\n', Bneg1.RootTorque_Nm/1e6);
fprintf('1g          : %.3f\n', B1.RootTorque_Nm/1e6);
fprintf('2.5g        : %.3f\n', B25.RootTorque_Nm/1e6);
fprintf('Up-gust     : %.3f\n', B_upgust.RootTorque_Nm/1e6);
fprintf('Down-gust   : %.3f\n', B_downgust.RootTorque_Nm/1e6);

fprintf('\n====================================================\n');
fprintf('TBW ROOT TORQUE REDUCTION vs BASELINE A [%%]\n');
fprintf('====================================================\n');

fprintf('-1g         : %.2f %%\n', ...
    100*(abs(Aneg1.RootTorque_Nm)-abs(Bneg1.RootTorque_Nm))/abs(Aneg1.RootTorque_Nm));

fprintf('1g          : %.2f %%\n', ...
    100*(abs(A1.RootTorque_Nm)-abs(B1.RootTorque_Nm))/abs(A1.RootTorque_Nm));

fprintf('2.5g        : %.2f %%\n', ...
    100*(abs(A25.RootTorque_Nm)-abs(B25.RootTorque_Nm))/abs(A25.RootTorque_Nm));

fprintf('Up-gust     : %.2f %%\n', ...
    100*(abs(A_upgust.RootTorque_Nm)-abs(B_upgust.RootTorque_Nm))/abs(A_upgust.RootTorque_Nm));

fprintf('Down-gust   : %.2f %%\n', ...
    100*(abs(A_downgust.RootTorque_Nm)-abs(B_downgust.RootTorque_Nm))/abs(A_downgust.RootTorque_Nm));

%% ---------------- wing mass summary ----------------
fprintf('\n====================================================\n');
fprintf('WING MASS SUMMARY [t]\n');
fprintf('====================================================\n');

fprintf('Config A Class-I       : %.2f\n', A25.mWing_ClassI_kg/1e3);
fprintf('Config B Class-I       : %.2f\n', B25.mWing_ClassI_kg/1e3);

fprintf('Config A Refined       : %.2f\n', A25.mWing_Refined_kg/1e3);
fprintf('Config B Refined       : %.2f\n', B25.mWing_Refined_kg/1e3);

%% ---------------- max stress summary ----------------
fprintf('\n====================================================\n');
fprintf('MAX STRESS SUMMARY (2.5g)\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Max bending stress     : %.1f MPa\n', A25.sigmaBend_max_Pa/1e6);
fprintf('Max total shear stress : %.1f MPa\n', A25.tauTotal_max_Pa/1e6);
fprintf('Max von Mises stress   : %.1f MPa\n', A25.sigmaVM_max_Pa/1e6);
fprintf('Yield stress           : %.1f MPa\n', A25.sigmaY_Pa/1e6);
fprintf('Allowable stress       : %.1f MPa\n', A25.sigmaAllow_Pa/1e6);

fprintf('\n--- Config B ---\n');
fprintf('Max bending stress     : %.1f MPa\n', B25.sigmaBend_max_Pa/1e6);
fprintf('Max total shear stress : %.1f MPa\n', B25.tauTotal_max_Pa/1e6);
fprintf('Max von Mises stress   : %.1f MPa\n', B25.sigmaVM_max_Pa/1e6);
fprintf('Yield stress           : %.1f MPa\n', B25.sigmaY_Pa/1e6);
fprintf('Allowable stress       : %.1f MPa\n', B25.sigmaAllow_Pa/1e6);

%% ---------------- root wingbox sizing summary ----------------
fprintf('\n====================================================\n');
fprintf('ROOT WINGBOX SIZING SUMMARY (2.5g)\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Wingbox width          : %.3f m\n', A25.bBox_root_m);
fprintf('Wingbox height         : %.3f m\n', A25.hBox_root_m);
fprintf('Required cap area      : %.6f m^2\n', A25.Areq_root_m2);
fprintf('Required web thickness : %.3f mm\n', A25.tWeb_req_m*1e3);
fprintf('Required torsion thickness : %.3f mm\n', A25.tTorsion_req_m*1e3);
fprintf('Governing thickness    : %.3f mm\n', A25.tGov_req_m*1e3);

fprintf('\n--- Config B ---\n');
fprintf('Wingbox width          : %.3f m\n', B25.bBox_root_m);
fprintf('Wingbox height         : %.3f m\n', B25.hBox_root_m);
fprintf('Required cap area      : %.6f m^2\n', B25.Areq_root_m2);
fprintf('Required web thickness : %.3f mm\n', B25.tWeb_req_m*1e3);
fprintf('Required torsion thickness : %.3f mm\n', B25.tTorsion_req_m*1e3);
fprintf('Governing thickness    : %.3f mm\n', B25.tGov_req_m*1e3);

fprintf('\n====================================================\n');
fprintf('ROOT X POSITION SUMMARY\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Front spar x position : %.3f m\n', A25.x_front_spar(1));
fprintf('Rear spar x position  : %.3f m\n', A25.x_rear_spar(1));
fprintf('Quarter chord         : %.3f m\n', A25.x_QC(1));

fprintf('\n--- Config B ---\n');
fprintf('Front spar x position : %.3f m\n', B25.x_front_spar(1));
fprintf('Rear spar x position  : %.3f m\n', B25.x_rear_spar(1));
fprintf('Quarter chord         : %.3f m\n', B25.x_QC(1));

fprintf('\n====================================================\n');
fprintf('ROOT WINGBOX SIZING SUMMARY (-1g, 1g, 2.5g)\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('-1g  | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', ...
    Aneg1.bBox_root_m, Aneg1.hBox_root_m, Aneg1.Areq_root_m2);
fprintf(' 1g  | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', ...
    A1.bBox_root_m, A1.hBox_root_m, A1.Areq_root_m2);
fprintf('2.5g | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', ...
    A25.bBox_root_m, A25.hBox_root_m, A25.Areq_root_m2);

fprintf('\n--- Config B ---\n');
fprintf('-1g  | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', ...
    Bneg1.bBox_root_m, Bneg1.hBox_root_m, Bneg1.Areq_root_m2);
fprintf(' 1g  | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', ...
    B1.bBox_root_m, B1.hBox_root_m, B1.Areq_root_m2);
fprintf('2.5g | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', ...
    B25.bBox_root_m, B25.hBox_root_m, B25.Areq_root_m2);

fprintf('\n====================================================\n');
fprintf('REQUIRED CAP AREA SUMMARY [m^2]\n');
fprintf('====================================================\n');

fprintf('Config A  | -1g: %.6f | 1g: %.6f | 2.5g: %.6f\n', ...
    Aneg1.Areq_root_m2, A1.Areq_root_m2, A25.Areq_root_m2);

fprintf('Config B  | -1g: %.6f | 1g: %.6f | 2.5g: %.6f\n', ...
    Bneg1.Areq_root_m2, B1.Areq_root_m2, B25.Areq_root_m2);

%% ---------------- Figure 1: A vs B for 2.5g ----------------
figure(1); clf;
tiledlayout(2,1);

nexttile;
plot(A25.y, A25.qNet/1e3, 'LineWidth', 1.8); hold on;
plot(B25.y, B25.qNet/1e3, 'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Net load [kN/m]');
legend('Config A','Config B','Location','best');
title('2.5g net spanwise load distribution');

nexttile;
plot(A25.y, A25.M/1e6, 'LineWidth', 1.8); hold on;
plot(B25.y, B25.M/1e6, 'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Bending moment [MNm]');
legend('Config A','Config B','Location','best');
title('2.5g half-wing bending moment comparison');

%% ---------------- Figure 2: Config A, -1g / 1g / 2.5g ----------------
figure(2); clf;
tiledlayout(2,1);

nexttile;
plot(Aneg1.y, Aneg1.M/1e6, 'LineWidth', 1.8); hold on;
plot(A1.y,    A1.M/1e6,    'LineWidth', 1.8);
plot(A25.y,   A25.M/1e6,   'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Bending moment [MNm]');
legend('-1g','1g','2.5g','Location','best');
title('Config A bending moment: -1g, 1g, 2.5g');

nexttile;
plot(Aneg1.y, Aneg1.V/1e6, 'LineWidth', 1.8); hold on;
plot(A1.y,    A1.V/1e6,    'LineWidth', 1.8);
plot(A25.y,   A25.V/1e6,   'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Shear [MN]');
legend('-1g','1g','2.5g','Location','best');
title('Config A shear: -1g, 1g, 2.5g');

%% ---------------- Figure 3: Config B, -1g / 1g / 2.5g ----------------
figure(3); clf;
tiledlayout(2,1);

nexttile;
plot(Bneg1.y, Bneg1.M/1e6, 'LineWidth', 1.8); hold on;
plot(B1.y,    B1.M/1e6,    'LineWidth', 1.8);
plot(B25.y,   B25.M/1e6,   'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Bending moment [MNm]');
legend('-1g','1g','2.5g','Location','best');
title('Config B bending moment: -1g, 1g, 2.5g');

nexttile;
plot(Bneg1.y, Bneg1.V/1e6, 'LineWidth', 1.8); hold on;
plot(B1.y,    B1.V/1e6,    'LineWidth', 1.8);
plot(B25.y,   B25.V/1e6,   'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Shear [MN]');
legend('-1g','1g','2.5g','Location','best');
title('Config B shear: -1g, 1g, 2.5g');

%% ---------------- Figure 4: Gust comparison ----------------
figure(4); clf;
tiledlayout(2,1);

nexttile;
plot(A_upgust.y, A_upgust.M/1e6, 'LineWidth', 1.8); hold on;
plot(A_downgust.y, A_downgust.M/1e6, 'LineWidth', 1.8);
plot(B_upgust.y, B_upgust.M/1e6, 'LineWidth', 1.8);
plot(B_downgust.y, B_downgust.M/1e6, 'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Bending moment [MNm]');
legend('A up-gust','A down-gust','B up-gust','B down-gust','Location','best');
title('Gust bending moment comparison');

nexttile;
plot(A_upgust.y, A_upgust.V/1e6, 'LineWidth', 1.8); hold on;
plot(A_downgust.y, A_downgust.V/1e6, 'LineWidth', 1.8);
plot(B_upgust.y, B_upgust.V/1e6, 'LineWidth', 1.8);
plot(B_downgust.y, B_downgust.V/1e6, 'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Shear [MN]');
legend('A up-gust','A down-gust','B up-gust','B down-gust','Location','best');
title('Gust shear comparison');

%% ---------------- Figure 5: Torque comparison ----------------
figure(5); clf;
tiledlayout(2,1);

nexttile;
plot(A25.y, A25.T/1e6, 'LineWidth', 1.8); hold on;
plot(B25.y, B25.T/1e6, 'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Torque [MNm]');
legend('Config A','Config B','Location','best');
title('2.5g torque comparison');

nexttile;
plot(Bneg1.y, Bneg1.T/1e6, 'LineWidth', 1.8); hold on;
plot(B1.y,    B1.T/1e6,    'LineWidth', 1.8);
plot(B25.y,   B25.T/1e6,   'LineWidth', 1.8);
grid on;
xlabel('y [m]');
ylabel('Torque [MNm]');
legend('-1g','1g','2.5g','Location','best');
title('Config B torque: -1g, 1g, 2.5g');

%% ---------------- Figure 6: Bending stress vs yield ----------------
figure(6); clf;
plot(A25.y, A25.sigmaBend_y/1e6, 'LineWidth',1.8); hold on;
plot(B25.y, B25.sigmaBend_y/1e6, 'LineWidth',1.8);
yline(A25.sigmaY_Pa/1e6, '--', 'Yield stress', 'LineWidth',1.5);
yline(A25.sigmaAllow_Pa/1e6, ':', 'Allowable stress', 'LineWidth',1.5);
grid on;
xlabel('y [m]');
ylabel('Bending stress [MPa]');
legend('Config A','Config B','Location','best');
title('2.5g bending stress distribution vs yield');

%% ---------------- Figure 7: von Mises stress vs yield ----------------
figure(7); clf;
plot(A25.y, A25.sigmaVM_y/1e6, 'LineWidth',1.8); hold on;
plot(B25.y, B25.sigmaVM_y/1e6, 'LineWidth',1.8);
yline(A25.sigmaY_Pa/1e6, '--', 'Yield stress', 'LineWidth',1.5);
yline(A25.sigmaAllow_Pa/1e6, ':', 'Allowable stress', 'LineWidth',1.5);
grid on;
xlabel('y [m]');
ylabel('von Mises stress [MPa]');
legend('Config A','Config B','Location','best');
title('2.5g von Mises stress distribution vs yield');

%% ---------------- Figure 8: Shear stress vs shear yield ----------------
figure(8); clf;
plot(A25.y, A25.tauTotal_y/1e6, 'LineWidth',1.8); hold on;
plot(B25.y, B25.tauTotal_y/1e6, 'LineWidth',1.8);
yline(A25.tauY_Pa/1e6, '--', 'Shear yield', 'LineWidth',1.5);
yline(A25.tauAllow_Pa/1e6, ':', 'Shear allowable', 'LineWidth',1.5);
grid on;
xlabel('y [m]');
ylabel('Shear stress [MPa]');
legend('Config A','Config B','Location','best');
title('2.5g shear stress distribution vs shear yield');

%% ---------------- Figure 9: Root-to-tip load distributions ----------------
figure(9); clf;
tiledlayout(3,1);

maskA = A25.validMask;
maskB = B25.validMask;

nexttile;
plot(A25.y(maskA), A25.V(maskA)/1e6, 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.V(maskB)/1e6, 'LineWidth',1.8);
grid on;
xlabel('y [m]');
ylabel('Shear [MN]');
legend('Config A','Config B','Location','best');
title('Root-to-tip shear force distribution (2.5g)');

nexttile;
plot(A25.y(maskA), A25.M(maskA)/1e6, 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.M(maskB)/1e6, 'LineWidth',1.8);
grid on;
xlabel('y [m]');
ylabel('Bending moment [MNm]');
legend('Config A','Config B','Location','best');
title('Root-to-tip bending moment distribution (2.5g)');

nexttile;
plot(A25.y(maskA), A25.T(maskA)/1e6, 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.T(maskB)/1e6, 'LineWidth',1.8);
grid on;
xlabel('y [m]');
ylabel('Torque [MNm]');
legend('Config A','Config B','Location','best');
title('Root-to-tip torque distribution (2.5g)');

%% ---------------- Figure 10: Root-to-tip stress distributions ----------------
figure(10); clf;
tiledlayout(3,1);

nexttile;
plot(A25.y(maskA), A25.sigmaBend_y(maskA)/1e6, 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.sigmaBend_y(maskB)/1e6, 'LineWidth',1.8);
yline(A25.sigmaY_Pa/1e6, '--', 'Yield', 'LineWidth',1.5);
yline(A25.sigmaAllow_Pa/1e6, ':', 'Allowable', 'LineWidth',1.5);
grid on;
xlabel('y [m]');
ylabel('Bending stress [MPa]');
legend('Config A','Config B','Location','best');
title('Root-to-tip bending stress distribution (2.5g)');

nexttile;
plot(A25.y(maskA), A25.tauTotal_y(maskA)/1e6, 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.tauTotal_y(maskB)/1e6, 'LineWidth',1.8);
yline(A25.tauY_Pa/1e6, '--', 'Shear yield', 'LineWidth',1.5);
yline(A25.tauAllow_Pa/1e6, ':', 'Shear allowable', 'LineWidth',1.5);
grid on;
xlabel('y [m]');
ylabel('Shear stress [MPa]');
legend('Config A','Config B','Location','best');
title('Root-to-tip shear stress distribution (2.5g)');

nexttile;
plot(A25.y(maskA), A25.sigmaVM_y(maskA)/1e6, 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.sigmaVM_y(maskB)/1e6, 'LineWidth',1.8);
yline(A25.sigmaY_Pa/1e6, '--', 'Yield', 'LineWidth',1.5);
yline(A25.sigmaAllow_Pa/1e6, ':', 'Allowable', 'LineWidth',1.5);
grid on;
xlabel('y [m]');
ylabel('von Mises stress [MPa]');
legend('Config A','Config B','Location','best');
title('Root-to-tip von Mises stress distribution (2.5g)');

%% ---------------- Figure 11: Root-to-tip wingbox sizing ----------------
figure(11); clf;
tiledlayout(3,1);

nexttile;
plot(A25.y(maskA), A25.Aeff_y_m2(maskA), 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.Aeff_y_m2(maskB), 'LineWidth',1.8);
grid on;
xlabel('y [m]');
ylabel('Cap area [m^2]');
legend('Config A','Config B','Location','best');
title('Root-to-tip spar cap area requirement (2.5g)');

nexttile;
plot(A25.y(maskA), A25.tWeb_y_m(maskA)*1e3, 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.tWeb_y_m(maskB)*1e3, 'LineWidth',1.8);
grid on;
xlabel('y [m]');
ylabel('Web thickness [mm]');
legend('Config A','Config B','Location','best');
title('Root-to-tip web thickness requirement (2.5g)');

nexttile;
plot(A25.y(maskA), A25.tSkin_y_m(maskA)*1e3, 'LineWidth',1.8); hold on;
plot(B25.y(maskB), B25.tSkin_y_m(maskB)*1e3, 'LineWidth',1.8);
grid on;
xlabel('y [m]');
ylabel('Skin / governing thickness [mm]');
legend('Config A','Config B','Location','best');
title('Root-to-tip governing thickness distribution (2.5g)');