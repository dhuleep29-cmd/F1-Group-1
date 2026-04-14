clear
clc
close all

%% =========================================================
%% CRITICAL LOAD CASE COMPARISON
%% Final frozen TBW configuration
%% =========================================================

% Final frozen TBW design
baseOpts = struct();
baseOpts.AR = 14;
baseOpts.span = 70;
baseOpts.lambda = 0.35;
baseOpts.sweep = 15;
baseOpts.MTOM = 300000;

%% ---------------- define load cases ----------------
Cases = {};

% 1g
Cases{end+1} = struct( ...
    'name','1g manoeuvre', ...
    'n',1.0, ...
    'opts',baseOpts);

% 2.5g
Cases{end+1} = struct( ...
    'name','2.5g manoeuvre', ...
    'n',2.5, ...
    'opts',baseOpts);

% -1g
Cases{end+1} = struct( ...
    'name','-1g manoeuvre', ...
    'n',-1.0, ...
    'opts',baseOpts);

% up-gust
Cases{end+1} = struct( ...
    'name','Up-gust', ...
    'n',1.498, ...
    'opts',baseOpts);

% down-gust
Cases{end+1} = struct( ...
    'name','Down-gust', ...
    'n',0.502, ...
    'opts',baseOpts);

% landing case
optsLanding = baseOpts;
optsLanding.enableLandingCase = true;
optsLanding.landingLoadFactor = 2.5;
optsLanding.yGearFrac = 0.30;

Cases{end+1} = struct( ...
    'name','Landing case', ...
    'n',2.5, ...
    'opts',optsLanding);

% engine case
optsEngine = baseOpts;
optsEngine.enableEngineLoad = true;
optsEngine.mEngine_kg = 7000;
optsEngine.yEngineFrac = 0.25;

Cases{end+1} = struct( ...
    'name','Engine load case', ...
    'n',2.5, ...
    'opts',optsEngine);

% fuel-loaded emphasis case
optsFuel = baseOpts;
optsFuel.fuelFrac = 0.25;
optsFuel.fuelSpanFrac = 0.60;

Cases{end+1} = struct( ...
    'name','Heavy fuel case', ...
    'n',2.5, ...
    'opts',optsFuel);

nCases = length(Cases);

%% ---------------- storage ----------------
rootShear_MN  = zeros(1,nCases);
rootBM_MNm    = zeros(1,nCases);
rootTorque_MNm= zeros(1,nCases);
maxVM_MPa     = zeros(1,nCases);

ResultsAll = cell(1,nCases);

%% ---------------- run all cases ----------------
for i = 1:nCases
    R = TBW_StructuralAnalysis('B', Cases{i}.n, Cases{i}.opts);
    ResultsAll{i} = R;

    rootShear_MN(i)   = abs(R.RootShear_N)/1e6;
    rootBM_MNm(i)     = abs(R.RootBM_Nm)/1e6;
    rootTorque_MNm(i) = abs(R.RootTorque_Nm)/1e6;
    maxVM_MPa(i)      = max(R.sigmaVM_y(R.validMask))/1e6;
end

%% ---------------- identify governing cases ----------------
[~, iV]  = max(rootShear_MN);
[~, iBM] = max(rootBM_MNm);
[~, iT]  = max(rootTorque_MNm);
[~, iVM] = max(maxVM_MPa);

%% ---------------- print summary ----------------
fprintf('\n====================================================\n');
fprintf('CRITICAL LOAD CASE COMPARISON - TBW FINAL DESIGN\n');
fprintf('====================================================\n');

fprintf('\n%-18s | %10s | %10s | %10s | %10s\n', ...
    'Case','Root Shear','Root BM','Root Torque','Max VM');
fprintf('%s\n', repmat('-',1,72));

for i = 1:nCases
    fprintf('%-18s | %10.3f | %10.3f | %10.3f | %10.1f\n', ...
        Cases{i}.name, rootShear_MN(i), rootBM_MNm(i), ...
        rootTorque_MNm(i), maxVM_MPa(i));
end

fprintf('\nGoverning root shear case   : %s\n', Cases{iV}.name);
fprintf('Governing root BM case      : %s\n', Cases{iBM}.name);
fprintf('Governing root torque case  : %s\n', Cases{iT}.name);
fprintf('Governing max VM case       : %s\n', Cases{iVM}.name);

%% ---------------- bar charts ----------------
caseNames = string(cellfun(@(c) c.name, Cases, 'UniformOutput', false));

figure(1); clf;
tiledlayout(4,1)

nexttile
bar(rootShear_MN)
grid on
ylabel('Root Shear [MN]')
title('Critical load case comparison')
set(gca,'XTick',1:nCases,'XTickLabel',caseNames)
xtickangle(30)

nexttile
bar(rootBM_MNm)
grid on
ylabel('Root BM [MNm]')
set(gca,'XTick',1:nCases,'XTickLabel',caseNames)
xtickangle(30)

nexttile
bar(rootTorque_MNm)
grid on
ylabel('Root Torque [MNm]')
set(gca,'XTick',1:nCases,'XTickLabel',caseNames)
xtickangle(30)

nexttile
bar(maxVM_MPa)
grid on
ylabel('Max VM [MPa]')
set(gca,'XTick',1:nCases,'XTickLabel',caseNames)
xtickangle(30)

%% ---------------- overlay diagrams for selected key cases ----------------
% Compare the 4 most important cases:
% 2.5g, Up-gust, Landing, Engine
idxPlot = [2 4 6 7];

figure(2); clf;
tiledlayout(3,1)

nexttile
hold on
for k = 1:length(idxPlot)
    i = idxPlot(k);
    R = ResultsAll{i};
    plot(R.y(R.validMask), R.V(R.validMask)/1e6, 'LineWidth', 1.8)
end
grid on
xlabel('y [m]')
ylabel('Shear [MN]')
title('Selected critical cases: Shear')
legend(caseNames(idxPlot),'Location','best')

nexttile
hold on
for k = 1:length(idxPlot)
    i = idxPlot(k);
    R = ResultsAll{i};
    plot(R.y(R.validMask), R.M(R.validMask)/1e6, 'LineWidth', 1.8)
end
grid on
xlabel('y [m]')
ylabel('Bending Moment [MNm]')
title('Selected critical cases: Bending Moment')
legend(caseNames(idxPlot),'Location','best')

nexttile
hold on
for k = 1:length(idxPlot)
    i = idxPlot(k);
    R = ResultsAll{i};
    plot(R.y(R.validMask), R.T(R.validMask)/1e6, 'LineWidth', 1.8)
end
grid on
xlabel('y [m]')
ylabel('Torque [MNm]')
title('Selected critical cases: Torque')
legend(caseNames(idxPlot),'Location','best')