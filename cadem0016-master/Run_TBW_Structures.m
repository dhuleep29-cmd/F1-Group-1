clear; clc; close all;

%% ---------------- user options ----------------
opts = struct();
opts.bBoxRatio = 0.60;
opts.hBoxRatio = 0.16;

%% ---------------- load case definitions ----------------
caseTable = {
    'neg1'    , '-1g'      , -1.000 , -1.000;
    'pos1'    , '1g'       ,  1.000 ,  1.000;
    'man25'   , '2.5g'     ,  2.500 ,  2.500;
    'upgust'  , 'Up-gust'  ,  1.416 ,  1.498;
    'downgust', 'Down-gust',  0.584 ,  0.502;
};

%% ---------------- run all cases ----------------
R = struct('A', struct(), 'B', struct());

for i = 1:size(caseTable,1)
    caseName = caseTable{i,1};
    nA = caseTable{i,3};
    nB = caseTable{i,4};

    R.A.(caseName) = TBW_StructuralAnalysis('A', nA, opts);
    R.B.(caseName) = TBW_StructuralAnalysis('B', nB, opts);
end

%% ---------------- shorthand variables ----------------
Aneg1      = R.A.neg1;
A1         = R.A.pos1;
A25        = R.A.man25;
A_upgust   = R.A.upgust;
A_downgust = R.A.downgust;

Bneg1      = R.B.neg1;
B1         = R.B.pos1;
B25        = R.B.man25;
B_upgust   = R.B.upgust;
B_downgust = R.B.downgust;

labels = caseTable(:,2)';

%% ---------------- root bending moment summary ----------------
bmA = [Aneg1.RootBM_Nm, A1.RootBM_Nm, A25.RootBM_Nm, A_upgust.RootBM_Nm, A_downgust.RootBM_Nm];
bmB = [Bneg1.RootBM_Nm, B1.RootBM_Nm, B25.RootBM_Nm, B_upgust.RootBM_Nm, B_downgust.RootBM_Nm];

printDualSummary('ROOT BENDING MOMENT SUMMARY [MNm]', labels, bmA/1e6, bmB/1e6, '%.3f');
printReductionSummary('TBW ROOT BM REDUCTION vs BASELINE A [%]', labels, bmA, bmB);

%% ---------------- root torque summary ----------------
torqueA = [Aneg1.RootTorque_Nm, A1.RootTorque_Nm, A25.RootTorque_Nm, A_upgust.RootTorque_Nm, A_downgust.RootTorque_Nm];
torqueB = [Bneg1.RootTorque_Nm, B1.RootTorque_Nm, B25.RootTorque_Nm, B_upgust.RootTorque_Nm, B_downgust.RootTorque_Nm];

printDualSummary('ROOT TORQUE SUMMARY [MNm]', labels, torqueA/1e6, torqueB/1e6, '%.3f');
printReductionSummary('TBW ROOT TORQUE REDUCTION vs BASELINE A [%]', labels, torqueA, torqueB);

%% ---------------- wing mass summary ----------------
fprintf('\n====================================================\n');
fprintf('WING MASS SUMMARY [t]\n');
fprintf('====================================================\n');
fprintf('Config A Class-I            : %.2f\n', A25.mWing_ClassI_kg/1e3);
fprintf('Config B Class-I            : %.2f\n', B25.mWing_ClassI_kg/1e3);
fprintf('Config A Refined            : %.2f\n', A25.mWing_Refined_kg/1e3);
fprintf('Config B Refined            : %.2f\n', B25.mWing_Refined_kg/1e3);
fprintf('Config A Realistic Total    : %.2f\n', A25.W_wing_realistic_total_kg/1e3);
fprintf('Config B Realistic Total    : %.2f\n', B25.W_wing_realistic_total_kg/1e3);

%% ---------------- fuel / loaded wing summary ----------------
fprintf('\n====================================================\n');
fprintf('FUEL MASS / LOADED WING SUMMARY\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Total fuel mass             : %.2f t\n', A25.mFuel_total_kg/1e3);
fprintf('Centre tank fuel            : %.2f t\n', A25.mFuel_center_kg/1e3);
fprintf('Inner wing fuel             : %.2f t\n', A25.mFuel_inner_kg/1e3);
fprintf('Outer wing fuel             : %.2f t\n', A25.mFuel_outer_kg/1e3);
fprintf('Loaded wing mass            : %.2f t\n', A25.W_loaded_wing_total_kg/1e3);

fprintf('\n--- Config B ---\n');
fprintf('Total fuel mass             : %.2f t\n', B25.mFuel_total_kg/1e3);
fprintf('Centre tank fuel            : %.2f t\n', B25.mFuel_center_kg/1e3);
fprintf('Inner wing fuel             : %.2f t\n', B25.mFuel_inner_kg/1e3);
fprintf('Outer wing fuel             : %.2f t\n', B25.mFuel_outer_kg/1e3);
fprintf('Loaded wing mass            : %.2f t\n', B25.W_loaded_wing_total_kg/1e3);

%% ---------------- Class II structural weight breakdown ----------------
fprintf('\n====================================================\n');
fprintf('CLASS II STRUCTURAL WEIGHT BREAKDOWN SUMMARY (2.5g)\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Bending material (half-wing): %.2f t\n', A25.W_bending_half_kg/1e3);
fprintf('Shear web weight (half-wing): %.2f t\n', A25.W_shearWeb_half_kg/1e3);
fprintf('Torsion/skin weight (half)  : %.2f t\n', A25.W_torsion_half_kg/1e3);
fprintf('Ideal structure (half-wing) : %.2f t\n', A25.W_ideal_half_kg/1e3);
fprintf('Rib weight (half-wing)      : %.2f t\n', A25.W_rib_half_kg/1e3);
fprintf('Non-ideal weight (half)     : %.2f t\n', A25.W_nonIdeal_half_kg/1e3);
fprintf('Total Class II structural   : %.2f t\n', A25.W_classII_total_kg/1e3);

fprintf('\n--- Config B ---\n');
fprintf('Bending material (half-wing): %.2f t\n', B25.W_bending_half_kg/1e3);
fprintf('Shear web weight (half-wing): %.2f t\n', B25.W_shearWeb_half_kg/1e3);
fprintf('Torsion/skin weight (half)  : %.2f t\n', B25.W_torsion_half_kg/1e3);
fprintf('Ideal structure (half-wing) : %.2f t\n', B25.W_ideal_half_kg/1e3);
fprintf('Rib weight (half-wing)      : %.2f t\n', B25.W_rib_half_kg/1e3);
fprintf('Non-ideal weight (half)     : %.2f t\n', B25.W_nonIdeal_half_kg/1e3);
fprintf('Total Class II structural   : %.2f t\n', B25.W_classII_total_kg/1e3);

%% ---------------- max stress summary ----------------
fprintf('\n====================================================\n');
fprintf('MAX STRESS SUMMARY (2.5g)\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Max bending stress          : %.1f MPa\n', A25.sigmaBend_max_Pa/1e6);
fprintf('Max total shear stress      : %.1f MPa\n', A25.tauTotal_max_Pa/1e6);
fprintf('Max von Mises stress        : %.1f MPa\n', A25.sigmaVM_max_Pa/1e6);
fprintf('Yield stress                : %.1f MPa\n', A25.sigmaY_Pa/1e6);
fprintf('Allowable stress            : %.1f MPa\n', A25.sigmaAllow_Pa/1e6);

fprintf('\n--- Config B ---\n');
fprintf('Max bending stress          : %.1f MPa\n', B25.sigmaBend_max_Pa/1e6);
fprintf('Max total shear stress      : %.1f MPa\n', B25.tauTotal_max_Pa/1e6);
fprintf('Max von Mises stress        : %.1f MPa\n', B25.sigmaVM_max_Pa/1e6);
fprintf('Yield stress                : %.1f MPa\n', B25.sigmaY_Pa/1e6);
fprintf('Allowable stress            : %.1f MPa\n', B25.sigmaAllow_Pa/1e6);

%% ---------------- inertia relief summary ----------------
fprintf('\n====================================================\n');
fprintf('INERTIA RELIEF SUMMARY (2.5g)\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Wing relief factor          : %.4f\n', A25.Rin_wing);
fprintf('Fuel relief factor          : %.4f\n', A25.Rin_fuel);
fprintf('Engine relief factor        : %.4f\n', A25.Rin_engine);
fprintf('Total relief factor         : %.4f\n', A25.Rin_total);

fprintf('\n--- Config B ---\n');
fprintf('Wing relief factor          : %.4f\n', B25.Rin_wing);
fprintf('Fuel relief factor          : %.4f\n', B25.Rin_fuel);
fprintf('Engine relief factor        : %.4f\n', B25.Rin_engine);
fprintf('Total relief factor         : %.4f\n', B25.Rin_total);

%% ---------------- root wingbox sizing summary ----------------
fprintf('\n====================================================\n');
fprintf('ROOT WINGBOX SIZING SUMMARY (2.5g)\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Wingbox width               : %.3f m\n', A25.x_rear_spar(1) - A25.x_front_spar(1));
fprintf('Wingbox width               : %.3f m\n', B25.x_rear_spar(1) - B25.x_front_spar(1));
fprintf('Required cap area           : %.6f m^2\n', A25.Areq_root_m2);
fprintf('Required web thickness      : %.3f mm\n', A25.tWeb_req_m*1e3);
fprintf('Required torsion thickness  : %.3f mm\n', A25.tTorsion_req_m*1e3);
fprintf('Governing thickness         : %.3f mm\n', A25.tGov_req_m*1e3);

fprintf('\n--- Config B ---\n');
fprintf('Wingbox width               : %.3f m\n', B25.bBox_root_m);
fprintf('Wingbox height              : %.3f m\n', B25.hBox_root_m);
fprintf('Required cap area           : %.6f m^2\n', B25.Areq_root_m2);
fprintf('Required web thickness      : %.3f mm\n', B25.tWeb_req_m*1e3);
fprintf('Required torsion thickness  : %.3f mm\n', B25.tTorsion_req_m*1e3);
fprintf('Governing thickness         : %.3f mm\n', B25.tGov_req_m*1e3);

%% ---------------- root x-position summary ----------------
fprintf('\n====================================================\n');
fprintf('ROOT X POSITION SUMMARY\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('Front spar x position       : %.3f m\n', A25.x_front_spar(1));
fprintf('Rear spar x position        : %.3f m\n', A25.x_rear_spar(1));
fprintf('Quarter chord               : %.3f m\n', A25.x_QC(1));

fprintf('\n--- Config B ---\n');
fprintf('Front spar x position       : %.3f m\n', B25.x_front_spar(1));
fprintf('Rear spar x position        : %.3f m\n', B25.x_rear_spar(1));
fprintf('Quarter chord               : %.3f m\n', B25.x_QC(1));

%% ---------------- multi-case root wingbox sizing summary ----------------
fprintf('\n====================================================\n');
fprintf('ROOT WINGBOX SIZING SUMMARY (-1g, 1g, 2.5g)\n');
fprintf('====================================================\n');

fprintf('\n--- Config A ---\n');
fprintf('-1g  | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', Aneg1.bBox_root_m, Aneg1.hBox_root_m, Aneg1.Areq_root_m2);
fprintf(' 1g  | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', A1.bBox_root_m,    A1.hBox_root_m,    A1.Areq_root_m2);
fprintf('2.5g | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', A25.bBox_root_m,   A25.hBox_root_m,   A25.Areq_root_m2);

fprintf('\n--- Config B ---\n');
fprintf('-1g  | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', Bneg1.bBox_root_m, Bneg1.hBox_root_m, Bneg1.Areq_root_m2);
fprintf(' 1g  | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', B1.bBox_root_m,    B1.hBox_root_m,    B1.Areq_root_m2);
fprintf('2.5g | bBox = %.3f m | hBox = %.3f m | Areq = %.6f m^2\n', B25.bBox_root_m,   B25.hBox_root_m,   B25.Areq_root_m2);

fprintf('\n====================================================\n');
fprintf('REQUIRED CAP AREA SUMMARY [m^2]\n');
fprintf('====================================================\n');
fprintf('Config A | -1g: %.6f | 1g: %.6f | 2.5g: %.6f\n', Aneg1.Areq_root_m2, A1.Areq_root_m2, A25.Areq_root_m2);
fprintf('Config B | -1g: %.6f | 1g: %.6f | 2.5g: %.6f\n', Bneg1.Areq_root_m2, B1.Areq_root_m2, B25.Areq_root_m2);

%% ---------------- masks ----------------
maskA = A25.validMask;
maskB = B25.validMask;

%% ---------------- Figure 1: A vs B for 2.5g ----------------
figure(1); clf;
tiledlayout(2,1);

nexttile;
plotTwoConfigs(A25, B25, 'qNet', 1e3, 'Net load [kN/m]', '2.5g net spanwise load distribution');

nexttile;
plotTwoConfigs(A25, B25, 'M', 1e6, 'Bending moment [MNm]', '2.5g half-wing bending moment comparison');

%% ---------------- Figure 2: Config A, -1g / 1g / 2.5g ----------------
figure(2); clf;
tiledlayout(2,1);

nexttile;
plotTriplet(Aneg1, A1, A25, 'M', 1e6, 'Bending moment [MNm]', 'Config A bending moment: -1g, 1g, 2.5g');

nexttile;
plotTriplet(Aneg1, A1, A25, 'V', 1e6, 'Shear [MN]', 'Config A shear: -1g, 1g, 2.5g');

%% ---------------- Figure 3: Config B, -1g / 1g / 2.5g ----------------
figure(3); clf;
tiledlayout(2,1);

nexttile;
plotTriplet(Bneg1, B1, B25, 'M', 1e6, 'Bending moment [MNm]', 'Config B bending moment: -1g, 1g, 2.5g');

nexttile;
plotTriplet(Bneg1, B1, B25, 'V', 1e6, 'Shear [MN]', 'Config B shear: -1g, 1g, 2.5g');

%% ---------------- Figure 4: Gust comparison ----------------
figure(4); clf;
tiledlayout(2,1);

nexttile;
plotGustComparison(A_upgust, A_downgust, B_upgust, B_downgust, 'M', 1e6, 'Bending moment [MNm]', 'Gust bending moment comparison');

nexttile;
plotGustComparison(A_upgust, A_downgust, B_upgust, B_downgust, 'V', 1e6, 'Shear [MN]', 'Gust shear comparison');

%% ---------------- Figure 5: Torque comparison ----------------
figure(5); clf;
tiledlayout(2,1);

nexttile;
plotTwoConfigs(A25, B25, 'T', 1e6, 'Torque [MNm]', '2.5g torque comparison');

nexttile;
plotTriplet(Bneg1, B1, B25, 'T', 1e6, 'Torque [MNm]', 'Config B torque: -1g, 1g, 2.5g');

%% ---------------- Figure 6: Bending stress vs yield ----------------
figure(6); clf;
plotStressComparison(A25, B25, 'sigmaBend_y', 1e6, ...
    'Bending stress [MPa]', '2.5g bending stress distribution vs yield', ...
    A25.sigmaY_Pa/1e6, A25.sigmaAllow_Pa/1e6, ...
    'Yield stress', 'Allowable stress');

%% ---------------- Figure 7: von Mises stress vs yield ----------------
figure(7); clf;
plotStressComparison(A25, B25, 'sigmaVM_y', 1e6, ...
    'von Mises stress [MPa]', '2.5g von Mises stress distribution vs yield', ...
    A25.sigmaY_Pa/1e6, A25.sigmaAllow_Pa/1e6, ...
    'Yield stress', 'Allowable stress');

%% ---------------- Figure 8: Shear stress vs shear yield ----------------
figure(8); clf;
plotStressComparison(A25, B25, 'tauTotal_y', 1e6, ...
    'Shear stress [MPa]', '2.5g shear stress distribution vs shear yield', ...
    A25.tauY_Pa/1e6, A25.tauAllow_Pa/1e6, ...
    'Shear yield', 'Shear allowable');

%% ---------------- Figure 9: Root-to-tip load distributions ----------------
figure(9); clf;
tiledlayout(3,1);

nexttile;
plotTwoConfigsMasked(A25, B25, maskA, maskB, 'V', 1e6, 'Shear [MN]', 'Root-to-tip shear force distribution (2.5g)');

nexttile;
plotTwoConfigsMasked(A25, B25, maskA, maskB, 'M', 1e6, 'Bending moment [MNm]', 'Root-to-tip bending moment distribution (2.5g)');

nexttile;
plotTwoConfigsMasked(A25, B25, maskA, maskB, 'T', 1e6, 'Torque [MNm]', 'Root-to-tip torque distribution (2.5g)');

%% ---------------- Figure 10: Root-to-tip stress distributions ----------------
figure(10); clf;
tiledlayout(3,1);

nexttile;
plotTwoConfigsMaskedWithLimits(A25, B25, maskA, maskB, 'sigmaBend_y', 1e6, ...
    'Bending stress [MPa]', 'Root-to-tip bending stress distribution (2.5g)', ...
    A25.sigmaY_Pa/1e6, A25.sigmaAllow_Pa/1e6, 'Yield', 'Allowable');

nexttile;
plotTwoConfigsMaskedWithLimits(A25, B25, maskA, maskB, 'tauTotal_y', 1e6, ...
    'Shear stress [MPa]', 'Root-to-tip shear stress distribution (2.5g)', ...
    A25.tauY_Pa/1e6, A25.tauAllow_Pa/1e6, 'Shear yield', 'Shear allowable');

nexttile;
plotTwoConfigsMaskedWithLimits(A25, B25, maskA, maskB, 'sigmaVM_y', 1e6, ...
    'von Mises stress [MPa]', 'Root-to-tip von Mises stress distribution (2.5g)', ...
    A25.sigmaY_Pa/1e6, A25.sigmaAllow_Pa/1e6, 'Yield', 'Allowable');

%% ---------------- Figure 11: Root-to-tip wingbox sizing ----------------
figure(11); clf;
tiledlayout(3,1);

nexttile;
plotTwoConfigsMasked(A25, B25, maskA, maskB, 'Aeff_y_m2', 1, 'Cap area [m^2]', 'Root-to-tip spar cap area requirement (2.5g)');

nexttile;
plotTwoConfigsMasked(A25, B25, maskA, maskB, 'tWeb_y_m', 1e-3, 'Web thickness [mm]', 'Root-to-tip web thickness requirement (2.5g)');

nexttile;
plotTwoConfigsMasked(A25, B25, maskA, maskB, 'tSkin_y_m', 1e-3, 'Skin / governing thickness [mm]', 'Root-to-tip governing thickness distribution (2.5g)');

%% ---------------- Figure 12: Class II weight breakdown ----------------
figure(12); clf;

cats = categorical({'Bending','Shear Web','Torsion/Skin','Ribs','Non-Ideal','Total'});
cats = reordercats(cats, {'Bending','Shear Web','Torsion/Skin','Ribs','Non-Ideal','Total'});

Avals = [ ...
    A25.W_bending_half_kg, ...
    A25.W_shearWeb_half_kg, ...
    A25.W_torsion_half_kg, ...
    A25.W_rib_half_kg, ...
    A25.W_nonIdeal_half_kg, ...
    0.5*A25.W_classII_total_kg] / 1e3;

Bvals = [ ...
    B25.W_bending_half_kg, ...
    B25.W_shearWeb_half_kg, ...
    B25.W_torsion_half_kg, ...
    B25.W_rib_half_kg, ...
    B25.W_nonIdeal_half_kg, ...
    0.5*B25.W_classII_total_kg] / 1e3;

bar(cats, [Avals(:), Bvals(:)], 'grouped');
grid on;
ylabel('Weight [t per half-wing]');
legend('Config A', 'Config B', 'Location', 'best');
title('Class II structural weight breakdown comparison (2.5g)');

%% ---------------- Figure 13: Inertia relief factors ----------------
figure(13); clf;

cats2 = categorical({'Wing','Fuel','Engine','Total'});
cats2 = reordercats(cats2, {'Wing','Fuel','Engine','Total'});

Arel = [A25.Rin_wing, A25.Rin_fuel, A25.Rin_engine, A25.Rin_total];
Brel = [B25.Rin_wing, B25.Rin_fuel, B25.Rin_engine, B25.Rin_total];

bar(cats2, [Arel(:), Brel(:)], 'grouped');
grid on;
ylabel('Relief factor [-]');
legend('Config A', 'Config B', 'Location', 'best');
title('Inertia relief factor comparison (2.5g)');

%% ========================= local functions =========================
function printDualSummary(titleStr, labels, valsA, valsB, fmt)
    fprintf('\n====================================================\n');
    fprintf('%s\n', titleStr);
    fprintf('====================================================\n');

    fprintf('\n--- Config A ---\n');
    for k = 1:numel(labels)
        fprintf(['%-12s : ' fmt '\n'], labels{k}, valsA(k));
    end

    fprintf('\n--- Config B ---\n');
    for k = 1:numel(labels)
        fprintf(['%-12s : ' fmt '\n'], labels{k}, valsB(k));
    end
end

function printReductionSummary(titleStr, labels, valsA, valsB)
    reductionPct = 100*(abs(valsA) - abs(valsB))./abs(valsA);

    fprintf('\n====================================================\n');
    fprintf('%s\n', titleStr);
    fprintf('====================================================\n');

    for k = 1:numel(labels)
        fprintf('%-12s : %.2f %%\n', labels{k}, reductionPct(k));
    end
end

function plotTwoConfigs(RA, RB, fieldName, scale, yLabelText, titleText)
    plot(RA.y, RA.(fieldName)/scale, 'LineWidth', 1.8); hold on;
    plot(RB.y, RB.(fieldName)/scale, 'LineWidth', 1.8);
    grid on;
    xlabel('y [m]');
    ylabel(yLabelText);
    legend('Config A', 'Config B', 'Location', 'best');
    title(titleText);
end

function plotTriplet(R1, R2, R3, fieldName, scale, yLabelText, titleText)
    plot(R1.y, R1.(fieldName)/scale, 'LineWidth', 1.8); hold on;
    plot(R2.y, R2.(fieldName)/scale, 'LineWidth', 1.8);
    plot(R3.y, R3.(fieldName)/scale, 'LineWidth', 1.8);
    grid on;
    xlabel('y [m]');
    ylabel(yLabelText);
    legend('-1g', '1g', '2.5g', 'Location', 'best');
    title(titleText);
end

function plotGustComparison(Aup, Adown, Bup, Bdown, fieldName, scale, yLabelText, titleText)
    plot(Aup.y,   Aup.(fieldName)/scale,   'LineWidth', 1.8); hold on;
    plot(Adown.y, Adown.(fieldName)/scale, 'LineWidth', 1.8);
    plot(Bup.y,   Bup.(fieldName)/scale,   'LineWidth', 1.8);
    plot(Bdown.y, Bdown.(fieldName)/scale, 'LineWidth', 1.8);
    grid on;
    xlabel('y [m]');
    ylabel(yLabelText);
    legend('A up-gust', 'A down-gust', 'B up-gust', 'B down-gust', 'Location', 'best');
    title(titleText);
end

function plotStressComparison(RA, RB, fieldName, scale, yLabelText, titleText, limit1, limit2, label1, label2)
    plot(RA.y, RA.(fieldName)/scale, 'LineWidth', 1.8); hold on;
    plot(RB.y, RB.(fieldName)/scale, 'LineWidth', 1.8);
    yline(limit1, '--', label1, 'LineWidth', 1.5);
    yline(limit2, ':',  label2, 'LineWidth', 1.5);
    grid on;
    xlabel('y [m]');
    ylabel(yLabelText);
    legend('Config A', 'Config B', 'Location', 'best');
    title(titleText);
end

function plotTwoConfigsMasked(RA, RB, maskA, maskB, fieldName, scale, yLabelText, titleText)
    plot(RA.y(maskA), RA.(fieldName)(maskA)/scale, 'LineWidth', 1.8); hold on;
    plot(RB.y(maskB), RB.(fieldName)(maskB)/scale, 'LineWidth', 1.8);
    grid on;
    xlabel('y [m]');
    ylabel(yLabelText);
    legend('Config A', 'Config B', 'Location', 'best');
    title(titleText);
end

function plotTwoConfigsMaskedWithLimits(RA, RB, maskA, maskB, fieldName, scale, yLabelText, titleText, limit1, limit2, label1, label2)
    plot(RA.y(maskA), RA.(fieldName)(maskA)/scale, 'LineWidth', 1.8); hold on;
    plot(RB.y(maskB), RB.(fieldName)(maskB)/scale, 'LineWidth', 1.8);
    yline(limit1, '--', label1, 'LineWidth', 1.5);
    yline(limit2, ':',  label2, 'LineWidth', 1.5);
    grid on;
    xlabel('y [m]');
    ylabel(yLabelText);
    legend('Config A', 'Config B', 'Location', 'best');
    title(titleText);
end

