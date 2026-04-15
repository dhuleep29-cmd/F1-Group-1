clear
clc
close all

%% =========================================================
%% CLASS I / CLASS II / CLASS II.5 COMPARISON
%% For:
%%   Conventional baseline
%%   TBW configuration
%%
%% Final design points:
%%   Conventional: AR=12, span=70, sweep=15, taper=0.35
%%   TBW:          AR=14, span=70, sweep=15, taper=0.35
%%
%% Class II methods used here:
%%   Method 1 = Raymer-style semi-empirical estimate
%%   Method 2 = Tuned semi-empirical correlation
%%
%% TBW Class II methodology:
%%   Conventional class II mass is corrected using bending-relief factor
%%   derived from the physics-based model.
%% =========================================================

%% ---------------- common assumptions ----------------
MTOM_kg = 350000;
tc = 0.16;              % thickness-to-chord ratio
nult = 2.5;             % manoeuvre sizing factor
fuelFrac = 0.19;        % for Raymer weak fuel term
qCruise_Pa = 5500;      % representative cruise dynamic pressure
alpha_relief = 0.55;    % TBW bending-relief exponent for Class II adaptation

%% ---------------- frozen configurations ----------------
Conv.AR     = 12;
Conv.span   = 70;
Conv.sweep  = 15;
Conv.lambda = 0.35;
Conv.name   = 'Conventional';

TBW.AR     = 14;
TBW.span   = 70;
TBW.sweep  = 26;
TBW.lambda = 0.35;
TBW.name   = 'TBW';

%% =========================================================
%% FINAL DESIGN POINT RESULTS
%% =========================================================

% ---------- Class II.5 / physics model ----------
R_conv = TBW_StructuralAnalysis('A', 2.5, struct( ...
    'AR', Conv.AR, ...
    'span', Conv.span, ...
    'lambda', Conv.lambda, ...
    'sweep', Conv.sweep, ...
    'MTOM', MTOM_kg));

R_tbw = TBW_StructuralAnalysis('B', 2.5, struct( ...
    'AR', TBW.AR, ...
    'span', TBW.span, ...
    'lambda', TBW.lambda, ...
    'sweep', TBW.sweep, ...
    'MTOM', MTOM_kg));

% ---------- Class I ----------
mClassI_conv_kg = R_conv.mWing_ClassI_kg;
mClassI_tbw_kg  = R_tbw.mWing_ClassI_kg;

% ---------- Class II Method 1: Raymer-style ----------
mClassII1_conv_kg = raymerWingMassSI( ...
    Conv.span, Conv.AR, Conv.sweep, Conv.lambda, tc, nult, MTOM_kg, fuelFrac, qCruise_Pa);

mClassII1_tbw_raw_kg = raymerWingMassSI( ...
    TBW.span, TBW.AR, TBW.sweep, TBW.lambda, tc, nult, MTOM_kg, fuelFrac, qCruise_Pa);

% TBW adaptation using bending-relief
bmReliefFactor = abs(R_tbw.RootBM_Nm) / abs(R_conv.RootBM_Nm);
mClassII1_tbw_kg = mClassII1_tbw_raw_kg * bmReliefFactor^alpha_relief;

% ---------- Class II Method 2: tuned semi-empirical ----------
% Calibrate coefficient so method 2 matches conventional Method 1 at frozen point
C_tuned = calibrateTunedClassII( ...
    mClassII1_conv_kg, Conv.span, Conv.AR, Conv.sweep, Conv.lambda, tc, nult, MTOM_kg);

mClassII2_conv_kg = tunedWingMassSI( ...
    Conv.span, Conv.AR, Conv.sweep, Conv.lambda, tc, nult, MTOM_kg, C_tuned);

mClassII2_tbw_raw_kg = tunedWingMassSI( ...
    TBW.span, TBW.AR, TBW.sweep, TBW.lambda, tc, nult, MTOM_kg, C_tuned);

mClassII2_tbw_kg = mClassII2_tbw_raw_kg * bmReliefFactor^alpha_relief;

% ---------- Class II.5 ----------
mClassII5_conv_kg = R_conv.mWing_Refined_kg;
mClassII5_tbw_kg  = R_tbw.mWing_Refined_kg;

%% =========================================================
%% PRINT FINAL TABLE
%% =========================================================
fprintf('\n====================================================\n');
fprintf('FINAL DESIGN POINT: CLASS I / II / II.5 COMPARISON\n');
fprintf('====================================================\n');

fprintf('\n--- Conventional ---\n');
fprintf('Geometry: AR = %.1f | Span = %.1f m | Sweep = %.1f deg | Taper = %.2f\n', ...
    Conv.AR, Conv.span, Conv.sweep, Conv.lambda);
fprintf('Class I mass              : %8.2f t\n', mClassI_conv_kg/1e3);
fprintf('Class II Method 1         : %8.2f t\n', mClassII1_conv_kg/1e3);
fprintf('Class II Method 2         : %8.2f t\n', mClassII2_conv_kg/1e3);
fprintf('Class II.5 physics model  : %8.2f t\n', mClassII5_conv_kg/1e3);

fprintf('\n--- TBW ---\n');
fprintf('Geometry: AR = %.1f | Span = %.1f m | Sweep = %.1f deg | Taper = %.2f\n', ...
    TBW.AR, TBW.span, TBW.sweep, TBW.lambda);
fprintf('Class I mass              : %8.2f t\n', mClassI_tbw_kg/1e3);
fprintf('Class II Method 1         : %8.2f t\n', mClassII1_tbw_kg/1e3);
fprintf('Class II Method 2         : %8.2f t\n', mClassII2_tbw_kg/1e3);
fprintf('Class II.5 physics model  : %8.2f t\n', mClassII5_tbw_kg/1e3);

fprintf('\nBending relief factor (TBW / Conventional root BM) = %.3f\n', bmReliefFactor);

%% =========================================================
%% FINAL BAR CHART
%% =========================================================
figure('Name','Final design point comparison'); clf
X = categorical({'Class I','Class II-1','Class II-2','Class II.5'});
X = reordercats(X, {'Class I','Class II-1','Class II-2','Class II.5'});

Y_conv = [mClassI_conv_kg, mClassII1_conv_kg, mClassII2_conv_kg, mClassII5_conv_kg]/1e3;
Y_tbw  = [mClassI_tbw_kg,  mClassII1_tbw_kg,  mClassII2_tbw_kg,  mClassII5_tbw_kg]/1e3;

bar(X, [Y_conv(:), Y_tbw(:)], 'grouped')
grid on
ylabel('Wing mass [t]')
title('Final design point: Conventional vs TBW')
legend('Conventional','TBW','Location','best')

%% =========================================================
%% AR SENSITIVITY STUDY
%% =========================================================
AR_list_conv = [8 10 12 14 16];
AR_list_tbw  = [8 10 12 14 16];

mI_conv   = zeros(size(AR_list_conv));
mII1_conv = zeros(size(AR_list_conv));
mII2_conv = zeros(size(AR_list_conv));
mII5_conv = zeros(size(AR_list_conv));

mI_tbw   = zeros(size(AR_list_tbw));
mII1_tbw = zeros(size(AR_list_tbw));
mII2_tbw = zeros(size(AR_list_tbw));
mII5_tbw = zeros(size(AR_list_tbw));

for i = 1:length(AR_list_conv)
    AR = AR_list_conv(i);

    Rc = TBW_StructuralAnalysis('A', 2.5, struct( ...
        'AR', AR, ...
        'span', Conv.span, ...
        'lambda', Conv.lambda, ...
        'sweep', Conv.sweep, ...
        'MTOM', MTOM_kg));

    Rt = TBW_StructuralAnalysis('B', 2.5, struct( ...
        'AR', AR, ...
        'span', TBW.span, ...
        'lambda', TBW.lambda, ...
        'sweep', TBW.sweep, ...
        'MTOM', MTOM_kg));

    % Class I
    mI_conv(i) = Rc.mWing_ClassI_kg;
    mI_tbw(i)  = Rt.mWing_ClassI_kg;

    % Class II-1
    mII1_conv(i) = raymerWingMassSI( ...
        Conv.span, AR, Conv.sweep, Conv.lambda, tc, nult, MTOM_kg, fuelFrac, qCruise_Pa);

    mII1_tbw_raw = raymerWingMassSI( ...
        TBW.span, AR, TBW.sweep, TBW.lambda, tc, nult, MTOM_kg, fuelFrac, qCruise_Pa);

    reliefAR = abs(Rt.RootBM_Nm) / abs(Rc.RootBM_Nm);
    mII1_tbw(i) = mII1_tbw_raw * reliefAR^alpha_relief;

    % Class II-2
    mII2_conv(i) = tunedWingMassSI( ...
        Conv.span, AR, Conv.sweep, Conv.lambda, tc, nult, MTOM_kg, C_tuned);

    mII2_tbw_raw = tunedWingMassSI( ...
        TBW.span, AR, TBW.sweep, TBW.lambda, tc, nult, MTOM_kg, C_tuned);

    mII2_tbw(i) = mII2_tbw_raw * reliefAR^alpha_relief;

    % Class II.5
    mII5_conv(i) = Rc.mWing_Refined_kg;
    mII5_tbw(i)  = Rt.mWing_Refined_kg;
end

%% =========================================================
%% PLOTS: CONVENTIONAL
%% =========================================================
figure('Name','Conventional AR sensitivity'); clf
plot(AR_list_conv, mI_conv/1e3,   '-o', 'LineWidth', 2); hold on
plot(AR_list_conv, mII1_conv/1e3, '-s', 'LineWidth', 2)
plot(AR_list_conv, mII2_conv/1e3, '-^', 'LineWidth', 2)
plot(AR_list_conv, mII5_conv/1e3, '-d', 'LineWidth', 2)
grid on
xlabel('Aspect Ratio')
ylabel('Wing mass [t]')
title('Conventional: Class I / II / II.5 wing mass vs AR')
legend('Class I','Class II-1','Class II-2','Class II.5','Location','best')

%% =========================================================
%% PLOTS: TBW
%% =========================================================
figure('Name','TBW AR sensitivity'); clf
plot(AR_list_tbw, mI_tbw/1e3,   '-o', 'LineWidth', 2); hold on
plot(AR_list_tbw, mII1_tbw/1e3, '-s', 'LineWidth', 2)
plot(AR_list_tbw, mII2_tbw/1e3, '-^', 'LineWidth', 2)
plot(AR_list_tbw, mII5_tbw/1e3, '-d', 'LineWidth', 2)
grid on
xlabel('Aspect Ratio')
ylabel('Wing mass [t]')
title('TBW: Class I / II / II.5 wing mass vs AR')
legend('Class I','Class II-1','Class II-2','Class II.5','Location','best')

%% =========================================================
%% OVERLAY: TBW vs CONVENTIONAL FOR CLASS II.5
%% =========================================================
figure('Name','Class II.5 TBW vs Conventional'); clf
plot(AR_list_conv, mII5_conv/1e3, '-o', 'LineWidth', 2); hold on
plot(AR_list_tbw,  mII5_tbw/1e3,  '-s', 'LineWidth', 2)
grid on
xlabel('Aspect Ratio')
ylabel('Wing mass [t]')
title('Class II.5 comparison: Conventional vs TBW')
legend('Conventional','TBW','Location','best')

%% =========================================================
%% HELPER FUNCTIONS
%% =========================================================
function mWing_kg = raymerWingMassSI(span_m, AR, sweep_deg, taper, tc, nult, MTOW_kg, fuelFrac, qCruise_Pa)
    % Raymer-style transport wing mass approximation
    % Implemented using mixed-unit standard form with conversions.
    %
    % Output: total wing mass [kg]

    % Derived geometry
    S_m2 = span_m^2 / AR;

    % Conversions
    kg2lb = 2.20462262185;
    m2_to_ft2 = 10.7639104167;
    Pa_to_psf = 0.020885434273;
    deg2rad = pi/180;

    Wdg_lb = MTOW_kg * kg2lb;
    Wfw_lb = fuelFrac * MTOW_kg * kg2lb;
    Sw_ft2 = S_m2 * m2_to_ft2;
    q_psf  = qCruise_Pa * Pa_to_psf;
    Lambda = sweep_deg * deg2rad;

    % Raymer-style correlation
    Wwing_lb = 0.036 * (Sw_ft2^0.758) ...
                    * (Wfw_lb^0.0035) ...
                    * ((AR/(cos(Lambda)^2))^0.60) ...
                    * (q_psf^0.006) ...
                    * (taper^0.04) ...
                    * ((100*tc/cos(Lambda))^(-0.30)) ...
                    * ((nult * Wdg_lb)^0.49);

    mWing_kg = Wwing_lb / kg2lb;
end

function C = calibrateTunedClassII(targetMass_kg, span_m, AR, sweep_deg, taper, tc, nult, MTOW_kg)
    % Calibrates the tuned semi-empirical coefficient to match target mass at one point
    base = classIIshape(span_m, AR, sweep_deg, taper, tc, nult, MTOW_kg);
    C = targetMass_kg / base;
end

function mWing_kg = tunedWingMassSI(span_m, AR, sweep_deg, taper, tc, nult, MTOW_kg, C)
    % Tuned semi-empirical Class II surrogate
    base = classIIshape(span_m, AR, sweep_deg, taper, tc, nult, MTOW_kg);
    mWing_kg = C * base;
end

function val = classIIshape(span_m, AR, sweep_deg, taper, tc, nult, MTOW_kg)
    % Dimensionless-ish semi-empirical shape function in SI
    % Not physics-based; intended as a Class II correlation form.
    Lambda = deg2rad(sweep_deg);
    S = span_m^2 / AR;

    val = (nult * MTOW_kg)^0.55 ...
        * S^0.30 ...
        * AR^0.25 ...
        * (cos(Lambda)^(-0.8)) ...
        * ((1+taper)^0.10) ...
        * (tc^(-0.20));
end