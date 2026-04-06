clear
clc
close all

%% =========================================================
%% FULL PARAMETRIC STUDY FOR TBW
%% Parameters:
%%   AR, span, taper ratio, sweep
%%
%% Outputs plotted:
%%   Root bending moment
%%   Root shear
%%   Root torque
%%   Refined wing mass
%%   Required cap area
%%   Required web thickness
%%   Required torsion thickness
%%   Governing thickness
%%   Max bending stress
%%   Max shear stress
%%   Max von Mises stress
%% =========================================================

%% ---------------- baseline values ----------------
AR0     = 14;
span0   = 70;
lambda0 = 0.28;
sweep0  = 25;
MTOM0   = 280000;

%% ---------------- parameter ranges ----------------
AR_list     = [8 10 12 14 16 18];
span_list   = [60 65 70 75 80 85];
lambda_list = [0.20 0.25 0.30 0.35 0.40 0.45];
sweep_list  = [0 10 20 30 40];

%% ---------------- number of outputs ----------------
% 1 RootBM
% 2 RootShear
% 3 RootTorque
% 4 RefinedMass
% 5 Areq_root
% 6 tWeb_req
% 7 tTorsion_req
% 8 tGov_req
% 9 MaxBendingStress
% 10 MaxShearStress
% 11 MaxVMStress

nOut = 11;

Res_AR     = zeros(length(AR_list), nOut);
Res_span   = zeros(length(span_list), nOut);
Res_lambda = zeros(length(lambda_list), nOut);
Res_sweep  = zeros(length(sweep_list), nOut);

%% =========================================================
%% HELPER FUNCTION
%% =========================================================
extractMetrics = @(R) [ ...
    abs(R.RootBM_Nm)/1e6, ...
    abs(R.RootShear_N)/1e6, ...
    abs(R.RootTorque_Nm)/1e6, ...
    R.mWing_Refined_kg/1e3, ...
    R.Areq_root_m2, ...
    R.tWeb_req_m*1e3, ...
    R.tTorsion_req_m*1e3, ...
    R.tGov_req_m*1e3, ...
    max(R.sigmaBend_y(R.validMask))/1e6, ...
    max(R.tauTotal_y(R.validMask))/1e6, ...
    max(R.sigmaVM_y(R.validMask))/1e6  ...
    ];

%% =========================================================
%% 1) AR STUDY
%% =========================================================
for i = 1:length(AR_list)
    opts = struct();
    opts.AR     = AR_list(i);
    opts.span   = span0;
    opts.lambda = lambda0;
    opts.sweep  = sweep0;
    opts.MTOM   = MTOM0;

    R = TBW_StructuralAnalysis('B', 2.5, opts);
    Res_AR(i,:) = extractMetrics(R);
end

%% =========================================================
%% 2) SPAN STUDY
%% =========================================================
for i = 1:length(span_list)
    opts = struct();
    opts.AR     = AR0;
    opts.span   = span_list(i);
    opts.lambda = lambda0;
    opts.sweep  = sweep0;
    opts.MTOM   = MTOM0;

    R = TBW_StructuralAnalysis('B', 2.5, opts);
    Res_span(i,:) = extractMetrics(R);
end

%% =========================================================
%% 3) TAPER STUDY
%% =========================================================
for i = 1:length(lambda_list)
    opts = struct();
    opts.AR     = AR0;
    opts.span   = span0;
    opts.lambda = lambda_list(i);
    opts.sweep  = sweep0;
    opts.MTOM   = MTOM0;

    R = TBW_StructuralAnalysis('B', 2.5, opts);
    Res_lambda(i,:) = extractMetrics(R);
end

%% =========================================================
%% 4) SWEEP STUDY
%% =========================================================
for i = 1:length(sweep_list)
    opts = struct();
    opts.AR     = AR0;
    opts.span   = span0;
    opts.lambda = lambda0;
    opts.sweep  = sweep_list(i);
    opts.MTOM   = MTOM0;

    R = TBW_StructuralAnalysis('B', 2.5, opts);
    Res_sweep(i,:) = extractMetrics(R);
end

%% =========================================================
%% LABELS
%% =========================================================
yLabels = { ...
    'Root Bending Moment [MNm]', ...
    'Root Shear [MN]', ...
    'Root Torque [MNm]', ...
    'Refined Wing Mass [t]', ...
    'Required Cap Area [m^2]', ...
    'Required Web Thickness [mm]', ...
    'Required Torsion Thickness [mm]', ...
    'Governing Thickness [mm]', ...
    'Max Bending Stress [MPa]', ...
    'Max Shear Stress [MPa]', ...
    'Max von Mises Stress [MPa]'};

%% =========================================================
%% PLOT FUNCTION
%% =========================================================
plotMetricSet(AR_list,     Res_AR,     'Aspect Ratio', yLabels, 'AR');
plotMetricSet(span_list,   Res_span,   'Span [m]', yLabels, 'Span');
plotMetricSet(lambda_list, Res_lambda, 'Taper Ratio', yLabels, 'Taper');
plotMetricSet(sweep_list,  Res_sweep,  'Sweep [deg]', yLabels, 'Sweep');

%% =========================================================
%% PRINT SUMMARY TABLES
%% =========================================================
fprintf('\n====================================================\n');
fprintf('FULL PARAMETRIC STUDY SUMMARY\n');
fprintf('====================================================\n');

printTable('AR Study', AR_list, Res_AR);
printTable('Span Study', span_list, Res_span);
printTable('Taper Study', lambda_list, Res_lambda);
printTable('Sweep Study', sweep_list, Res_sweep);

%% =========================================================
%% LOCAL FUNCTIONS
%% =========================================================
function plotMetricSet(x, R, xlab, yLabels, tag)

    for k = 1:size(R,2)
        figure('Name',[tag ' Metric ' num2str(k)]);
        plot(x, R(:,k), '-o', 'LineWidth', 2);
        grid on
        xlabel(xlab)
        ylabel(yLabels{k})
        title([yLabels{k} ' vs ' xlab])
    end

    % one compact overview figure
    figure('Name',[tag ' Overview']);
    tiledlayout(4,3)

    nPlot = size(R,2);
    for k = 1:nPlot
        nexttile
        plot(x, R(:,k), '-o', 'LineWidth', 1.8)
        grid on
        xlabel(xlab)
        ylabel(yLabels{k}, 'Interpreter','none')
        title(['Metric ' num2str(k)])
    end
end

function printTable(titleStr, x, R)

    fprintf('\n----------------------------------------------------\n');
    fprintf('%s\n', titleStr);
    fprintf('----------------------------------------------------\n');
    fprintf('Value | RootBM | RootShear | RootTorque | Mass | Areq | tWeb | tTor | tGov | MaxSig | MaxTau | MaxVM\n');

    for i = 1:length(x)
        fprintf('%5.2f | %6.2f | %9.2f | %10.2f | %5.2f | %5.3f | %5.2f | %5.2f | %5.2f | %7.2f | %7.2f | %7.2f\n', ...
            x(i), ...
            R(i,1), R(i,2), R(i,3), R(i,4), R(i,5), ...
            R(i,6), R(i,7), R(i,8), R(i,9), R(i,10), R(i,11));
    end
end