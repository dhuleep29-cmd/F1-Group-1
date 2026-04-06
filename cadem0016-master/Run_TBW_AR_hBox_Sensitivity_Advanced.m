clear
clc
close all

%% =========================================================
%% ADVANCED SENSITIVITY STUDY
%% Parameters:
%%   AR
%%   hBoxRatio = h/c
%%
%% Outputs:
%%   Root BM
%%   Root Shear
%%   Root Torque
%%   Refined Wing Mass
%%   Required Cap Area
%%   Required Web Thickness
%%   Required Torsion Thickness
%%   Governing Thickness
%%   Max Bending Stress
%%   Max Shear Stress
%%   Max von Mises Stress
%% =========================================================

ARvals = [10 12 14];
hvals  = [0.10 0.12 0.14];

nAR = length(ARvals);
nh  = length(hvals);

% Output order:
% 1 RootBM [MNm]
% 2 RootShear [MN]
% 3 RootTorque [MNm]
% 4 RefinedMass [t]
% 5 Areq_root [m^2]
% 6 tWeb_req [mm]
% 7 tTorsion_req [mm]
% 8 tGov_req [mm]
% 9 MaxBendingStress [MPa]
% 10 MaxShearStress [MPa]
% 11 MaxVonMises [MPa]

nOut = 11;

Res_A = zeros(nAR, nh, nOut);
Res_B = zeros(nAR, nh, nOut);

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
    max(R.sigmaVM_y(R.validMask))/1e6 ];

%% =========================================================
%% CONFIG A
%% =========================================================
for i = 1:nAR
    for j = 1:nh

        opts = struct();
        opts.AR = ARvals(i);
        opts.hBoxRatio = hvals(j);

        R = TBW_StructuralAnalysis('A', 2.5, opts);

        Res_A(i,j,:) = extractMetrics(R);
    end
end

%% =========================================================
%% CONFIG B
%% =========================================================
for i = 1:nAR
    for j = 1:nh

        opts = struct();
        opts.AR = ARvals(i);
        opts.hBoxRatio = hvals(j);

        R = TBW_StructuralAnalysis('B', 2.5, opts);

        Res_B(i,j,:) = extractMetrics(R);
    end
end

%% =========================================================
%% PRINT RESULTS
%% =========================================================
fprintf('\n====================================================\n');
fprintf('ADVANCED AR-h/c SENSITIVITY STUDY\n');
fprintf('====================================================\n');

metricNames = { ...
    'Root BM [MNm]', ...
    'Root Shear [MN]', ...
    'Root Torque [MNm]', ...
    'Refined Mass [t]', ...
    'Required Cap Area [m^2]', ...
    'Required Web Thickness [mm]', ...
    'Required Torsion Thickness [mm]', ...
    'Governing Thickness [mm]', ...
    'Max Bending Stress [MPa]', ...
    'Max Shear Stress [MPa]', ...
    'Max von Mises [MPa]'};

fprintf('\n=== CONFIG A ===\n');
for i = 1:nAR
    for j = 1:nh
        vals = squeeze(Res_A(i,j,:));
        fprintf('AR=%2.0f, h/c=%4.2f | BM=%6.2f | V=%5.2f | T=%5.2f | Mass=%6.2f | Areq=%6.4f | tWeb=%5.2f | tTor=%5.2f | tGov=%5.2f | sB=%6.1f | tau=%6.1f | VM=%6.1f\n', ...
            ARvals(i), hvals(j), vals(1), vals(2), vals(3), vals(4), vals(5), ...
            vals(6), vals(7), vals(8), vals(9), vals(10), vals(11));
    end
end

fprintf('\n=== CONFIG B ===\n');
for i = 1:nAR
    for j = 1:nh
        vals = squeeze(Res_B(i,j,:));
        fprintf('AR=%2.0f, h/c=%4.2f | BM=%6.2f | V=%5.2f | T=%5.2f | Mass=%6.2f | Areq=%6.4f | tWeb=%5.2f | tTor=%5.2f | tGov=%5.2f | sB=%6.1f | tau=%6.1f | VM=%6.1f\n', ...
            ARvals(i), hvals(j), vals(1), vals(2), vals(3), vals(4), vals(5), ...
            vals(6), vals(7), vals(8), vals(9), vals(10), vals(11));
    end
end

%% =========================================================
%% PLOTTING FUNCTION
%% =========================================================
plotSensitivity(ARvals, hvals, Res_A, 'Config A');
plotSensitivity(ARvals, hvals, Res_B, 'Config B');

%% =========================================================
%% A vs B COMPARISON FOR EACH METRIC
%% =========================================================
for k = 1:nOut
    figure('Name',['A vs B comparison - ' metricNames{k}]);
    tiledlayout(1,nh)

    for j = 1:nh
        nexttile
        plot(ARvals, squeeze(Res_A(:,j,k)), '-o', 'LineWidth', 2); hold on
        plot(ARvals, squeeze(Res_B(:,j,k)), '-s', 'LineWidth', 2);
        grid on
        xlabel('Aspect Ratio')
        ylabel(metricNames{k})
        title(sprintf('h/c = %.2f', hvals(j)))
        legend('Config A','Config B','Location','best')
    end
end

%% =========================================================
%% HEATMAPS FOR CONFIG B
%% =========================================================
for k = 1:nOut
    figure('Name',['Heatmap B - ' metricNames{k}]);
    imagesc(hvals, ARvals, squeeze(Res_B(:,:,k)))
    set(gca,'YDir','normal')
    colorbar
    xlabel('h/c')
    ylabel('Aspect Ratio')
    title(['Config B heatmap: ' metricNames{k}])
end

%% =========================================================
%% LOCAL FUNCTIONS
%% =========================================================
function plotSensitivity(ARvals, hvals, Res, cfgName)

    metricNames = { ...
        'Root BM [MNm]', ...
        'Root Shear [MN]', ...
        'Root Torque [MNm]', ...
        'Refined Mass [t]', ...
        'Required Cap Area [m^2]', ...
        'Required Web Thickness [mm]', ...
        'Required Torsion Thickness [mm]', ...
        'Governing Thickness [mm]', ...
        'Max Bending Stress [MPa]', ...
        'Max Shear Stress [MPa]', ...
        'Max von Mises [MPa]'};

    nOut = size(Res,3);

    % individual figures
    for k = 1:nOut
        figure('Name',[cfgName ' - ' metricNames{k}]);
        hold on
        for j = 1:length(hvals)
            plot(ARvals, squeeze(Res(:,j,k)), '-o', 'LineWidth', 2)
        end
        grid on
        xlabel('Aspect Ratio')
        ylabel(metricNames{k})
        title([cfgName ': ' metricNames{k} ' vs AR'])
        legend("h/c="+string(hvals), 'Location','best')
    end

    % overview figure
    figure('Name',[cfgName ' Overview']);
    tiledlayout(4,3)

    for k = 1:nOut
        nexttile
        hold on
        for j = 1:length(hvals)
            plot(ARvals, squeeze(Res(:,j,k)), '-o', 'LineWidth', 1.8)
        end
        grid on
        xlabel('Aspect Ratio')
        ylabel(metricNames{k})
        title(['Metric ' num2str(k)])
    end
end