clear
clc
close all

%% =========================================================
%% STATION TRACKING STUDY
%% Tracks structural response at:
%% Root / Mid / Outboard stations
%% =========================================================

%% ---------------- baseline values ----------------
AR0     = 14;
span0   = 70;
lambda0 = 0.28;
sweep0  = 25;
MTOM0   = 350000;

%% ---------------- parameter ranges ----------------
AR_list     = [8 10 12 14 16 18];
span_list   = [60 65 70 75 80 85];
lambda_list = [0.20 0.25 0.30 0.35 0.40 0.45];
sweep_list  = [0 10 20 30 40];

%% ---------------- station definitions ----------------
% relative position on semi-span
eta_root = 0.05;
eta_mid  = 0.50;
eta_out  = 0.85;

%% ---------------- metric order ----------------
% 1 sigmaBend
% 2 tauShear
% 3 sigmaVM
% 4 M
% 5 V
% 6 T

nMetrics = 6;

Track_AR_root   = zeros(length(AR_list), nMetrics);
Track_AR_mid    = zeros(length(AR_list), nMetrics);
Track_AR_out    = zeros(length(AR_list), nMetrics);

Track_span_root = zeros(length(span_list), nMetrics);
Track_span_mid  = zeros(length(span_list), nMetrics);
Track_span_out  = zeros(length(span_list), nMetrics);

Track_lam_root  = zeros(length(lambda_list), nMetrics);
Track_lam_mid   = zeros(length(lambda_list), nMetrics);
Track_lam_out   = zeros(length(lambda_list), nMetrics);

Track_sw_root   = zeros(length(sweep_list), nMetrics);
Track_sw_mid    = zeros(length(sweep_list), nMetrics);
Track_sw_out    = zeros(length(sweep_list), nMetrics);

%% =========================================================
%% helper function
%% =========================================================
extractAtStation = @(R, eta) getStationMetrics(R, eta);

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

    Track_AR_root(i,:) = extractAtStation(R, eta_root);
    Track_AR_mid(i,:)  = extractAtStation(R, eta_mid);
    Track_AR_out(i,:)  = extractAtStation(R, eta_out);
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

    Track_span_root(i,:) = extractAtStation(R, eta_root);
    Track_span_mid(i,:)  = extractAtStation(R, eta_mid);
    Track_span_out(i,:)  = extractAtStation(R, eta_out);
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

    Track_lam_root(i,:) = extractAtStation(R, eta_root);
    Track_lam_mid(i,:)  = extractAtStation(R, eta_mid);
    Track_lam_out(i,:)  = extractAtStation(R, eta_out);
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

    Track_sw_root(i,:) = extractAtStation(R, eta_root);
    Track_sw_mid(i,:)  = extractAtStation(R, eta_mid);
    Track_sw_out(i,:)  = extractAtStation(R, eta_out);
end

%% =========================================================
%% labels
%% =========================================================
metricNames = { ...
    'Bending Stress [MPa]', ...
    'Shear Stress [MPa]', ...
    'von Mises Stress [MPa]', ...
    'Bending Moment [MNm]', ...
    'Shear Force [MN]', ...
    'Torque [MNm]'};

%% =========================================================
%% plot all studies
%% =========================================================
plotStationSet(AR_list,     Track_AR_root,   Track_AR_mid,   Track_AR_out,   'Aspect Ratio', metricNames, 'AR');
plotStationSet(span_list,   Track_span_root, Track_span_mid, Track_span_out, 'Span [m]', metricNames, 'Span');
plotStationSet(lambda_list, Track_lam_root,  Track_lam_mid,  Track_lam_out,  'Taper Ratio', metricNames, 'Taper');
plotStationSet(sweep_list,  Track_sw_root,   Track_sw_mid,   Track_sw_out,   'Sweep [deg]', metricNames, 'Sweep');

%% =========================================================
%% local functions
%% =========================================================
function vals = getStationMetrics(R, eta)

    semiSpan = max(R.y);
    yTarget = eta * semiSpan;

    [~, idx] = min(abs(R.y - yTarget));

    vals = [ ...
        R.sigmaBend_y(idx)/1e6, ...
        R.tauTotal_y(idx)/1e6, ...
        R.sigmaVM_y(idx)/1e6, ...
        abs(R.M(idx))/1e6, ...
        abs(R.V(idx))/1e6, ...
        abs(R.T(idx))/1e6 ...
        ];
end

function plotStationSet(x, rootData, midData, outData, xlab, metricNames, tag)

    for k = 1:size(rootData,2)

        figure('Name',[tag ' Station Metric ' num2str(k)]);
        plot(x, rootData(:,k), '-o', 'LineWidth', 2); hold on
        plot(x, midData(:,k),  '-s', 'LineWidth', 2);
        plot(x, outData(:,k),  '-^', 'LineWidth', 2);

        grid on
        xlabel(xlab)
        ylabel(metricNames{k})
        title([metricNames{k} ' at Root / Mid / Outboard vs ' xlab])
        legend('Root','Mid-span','Outboard','Location','best')
    end

    % overview figure
    figure('Name',[tag ' Station Overview']);
    tiledlayout(3,2)

    for k = 1:size(rootData,2)
        nexttile
        plot(x, rootData(:,k), '-o', 'LineWidth', 1.8); hold on
        plot(x, midData(:,k),  '-s', 'LineWidth', 1.8);
        plot(x, outData(:,k),  '-^', 'LineWidth', 1.8);
        grid on
        xlabel(xlab)
        ylabel(metricNames{k})
        title(['Metric ' num2str(k)])
        legend('Root','Mid','Outboard','Location','best')
    end
end