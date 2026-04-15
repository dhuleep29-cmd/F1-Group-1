clear
clc
close all

%% =========================================================
%% SECTION TRADE STUDY FOR MDO / STABILITY SUPPORT
%% Frozen TBW geometry:
%%   AR = 14
%%   span = 70
%%   sweep = 15
%%   taper = 0.35
%%
%% Study 1: vary hBoxRatio
%% Study 2: vary bBoxRatio
%% Study 3: vary root spar-cap area
%% =========================================================

%% ---------------- frozen aircraft ----------------
baseOpts = struct();
baseOpts.AR = 14;
baseOpts.span = 70;
baseOpts.lambda = 0.35;
baseOpts.sweep = 26;
baseOpts.MTOM = 350000;

%% ---------------- constants ----------------
rhoAl = 2830;       % kg/m^3
EAl   = 71.7e9;     % Pa
sigmaTarget = 300;  % MPa

%% =========================================================
%% STUDY 1: hBoxRatio effect
%% =========================================================
hList = 0.10:0.01:0.22;
bFixed = 0.45;
AcapFixed = 0.070;   % m^2

Res_h = zeros(length(hList), 6);
% columns:
% 1 root Iyy [m^4]
% 2 root EI [Nm^2]
% 3 root GJ [Nm^2]
% 4 max bending stress [MPa]
% 5 approx mass [t]
% 6 root box height [m]

for i = 1:length(hList)

    opts = baseOpts;
    opts.hBoxRatio = hList(i);
    opts.bBoxRatio = bFixed;

    R = TBW_StructuralAnalysis('B', 2.5, opts);

    Acap_y = AcapFixed .* abs(R.M) ./ max(abs(R.RootBM_Nm),1e-9);
    Acap_y = max(Acap_y, 0.20*AcapFixed);

    Iyy_y = 0.5 .* Acap_y .* R.hBox_y.^2;
    EI_y  = EAl .* Iyy_y;

    sigmaBend_y = abs(R.M) .* (R.hBox_y/2) ./ max(Iyy_y,1e-12);

    capMassHalf  = trapz(R.y, 2 .* Acap_y * rhoAl);
    webMassHalf  = trapz(R.y, 2 .* R.hBox_y .* max(R.tGov_req_m,0.004) .* rhoAl);
    skinMassHalf = trapz(R.y, 2 .* R.bBox_y .* max(R.tSkin_y_m,0.003) .* rhoAl);

    mApprox_t = 2*(capMassHalf + webMassHalf + skinMassHalf)/1e3;

    Res_h(i,1) = Iyy_y(1);
    Res_h(i,2) = EI_y(1);
    Res_h(i,3) = R.GJ_y_Nm2(1);
    Res_h(i,4) = max(sigmaBend_y(R.validMask))/1e6;
    Res_h(i,5) = mApprox_t;
    Res_h(i,6) = R.hBox_root_m;
end

%% =========================================================
%% STUDY 2: bBoxRatio effect
%% =========================================================
bList = 0.35:0.02:0.65;
hFixed = 0.20;
AcapFixed = 0.070;

Res_b = zeros(length(bList), 6);

for i = 1:length(bList)

    opts = baseOpts;
    opts.hBoxRatio = hFixed;
    opts.bBoxRatio = bList(i);

    R = TBW_StructuralAnalysis('B', 2.5, opts);

    Acap_y = AcapFixed .* abs(R.M) ./ max(abs(R.RootBM_Nm),1e-9);
    Acap_y = max(Acap_y, 0.20*AcapFixed);

    Iyy_y = 0.5 .* Acap_y .* R.hBox_y.^2;
    EI_y  = EAl .* Iyy_y;

    sigmaBend_y = abs(R.M) .* (R.hBox_y/2) ./ max(Iyy_y,1e-12);

    capMassHalf  = trapz(R.y, 2 .* Acap_y * rhoAl);
    webMassHalf  = trapz(R.y, 2 .* R.hBox_y .* max(R.tGov_req_m,0.004) .* rhoAl);
    skinMassHalf = trapz(R.y, 2 .* R.bBox_y .* max(R.tSkin_y_m,0.003) .* rhoAl);

    mApprox_t = 2*(capMassHalf + webMassHalf + skinMassHalf)/1e3;

    Res_b(i,1) = Iyy_y(1);
    Res_b(i,2) = EI_y(1);
    Res_b(i,3) = R.GJ_y_Nm2(1);
    Res_b(i,4) = max(sigmaBend_y(R.validMask))/1e6;
    Res_b(i,5) = mApprox_t;
    Res_b(i,6) = R.bBox_root_m;
end

%% =========================================================
%% STUDY 3: root cap area effect
%% =========================================================
AcapList = 0.040:0.005:0.090;
hFixed = 0.20;
bFixed = 0.45;

Res_A = zeros(length(AcapList), 6);

for i = 1:length(AcapList)

    opts = baseOpts;
    opts.hBoxRatio = hFixed;
    opts.bBoxRatio = bFixed;

    R = TBW_StructuralAnalysis('B', 2.5, opts);

    Acap_root = AcapList(i);
    Acap_y = Acap_root .* abs(R.M) ./ max(abs(R.RootBM_Nm),1e-9);
    Acap_y = max(Acap_y, 0.20*Acap_root);

    Iyy_y = 0.5 .* Acap_y .* R.hBox_y.^2;
    EI_y  = EAl .* Iyy_y;

    sigmaBend_y = abs(R.M) .* (R.hBox_y/2) ./ max(Iyy_y,1e-12);

    capMassHalf  = trapz(R.y, 2 .* Acap_y * rhoAl);
    webMassHalf  = trapz(R.y, 2 .* R.hBox_y .* max(R.tGov_req_m,0.004) .* rhoAl);
    skinMassHalf = trapz(R.y, 2 .* R.bBox_y .* max(R.tSkin_y_m,0.003) .* rhoAl);

    mApprox_t = 2*(capMassHalf + webMassHalf + skinMassHalf)/1e3;

    Res_A(i,1) = Iyy_y(1);
    Res_A(i,2) = EI_y(1);
    Res_A(i,3) = R.GJ_y_Nm2(1);
    Res_A(i,4) = max(sigmaBend_y(R.validMask))/1e6;
    Res_A(i,5) = mApprox_t;
    Res_A(i,6) = Acap_root;
end

%% =========================================================
%% PRINT TABLES
%% =========================================================
fprintf('\n====================================================\n');
fprintf('TRADE STUDY: EFFECT OF WINGBOX PARAMETERS\n');
fprintf('====================================================\n');

fprintf('\n--- Study 1: hBoxRatio effect ---\n');
fprintf('h/c   | Root Iyy [m^4] | Root EI [e10] | Root GJ [e10] | Max sigB [MPa] | Mass [t] | Root h [m]\n');
fprintf('%s\n', repmat('-',1,100));
for i = 1:length(hList)
    fprintf('%.3f | %13.4f | %13.3f | %13.3f | %14.1f | %8.2f | %8.3f\n', ...
        hList(i), Res_h(i,1), Res_h(i,2)/1e10, Res_h(i,3)/1e10, Res_h(i,4), Res_h(i,5), Res_h(i,6));
end

fprintf('\n--- Study 2: bBoxRatio effect ---\n');
fprintf('b/c   | Root Iyy [m^4] | Root EI [e10] | Root GJ [e10] | Max sigB [MPa] | Mass [t] | Root b [m]\n');
fprintf('%s\n', repmat('-',1,100));
for i = 1:length(bList)
    fprintf('%.3f | %13.4f | %13.3f | %13.3f | %14.1f | %8.2f | %8.3f\n', ...
        bList(i), Res_b(i,1), Res_b(i,2)/1e10, Res_b(i,3)/1e10, Res_b(i,4), Res_b(i,5), Res_b(i,6));
end

fprintf('\n--- Study 3: cap area effect ---\n');
fprintf('Acap  | Root Iyy [m^4] | Root EI [e10] | Root GJ [e10] | Max sigB [MPa] | Mass [t]\n');
fprintf('%s\n', repmat('-',1,90));
for i = 1:length(AcapList)
    fprintf('%.3f | %13.4f | %13.3f | %13.3f | %14.1f | %8.2f\n', ...
        AcapList(i), Res_A(i,1), Res_A(i,2)/1e10, Res_A(i,3)/1e10, Res_A(i,4), Res_A(i,5));
end

%% =========================================================
%% PLOTS
%% =========================================================

% Study 1: h effect
figure(1); clf;
tiledlayout(3,1)

nexttile
plot(hList, Res_h(:,1), '-o', 'LineWidth', 2)
grid on
xlabel('hBoxRatio')
ylabel('Root I_{yy} [m^4]')
title('Effect of box depth on second moment of area')

nexttile
plot(hList, Res_h(:,4), '-o', 'LineWidth', 2)
grid on
xlabel('hBoxRatio')
ylabel('Max bending stress [MPa]')
title('Effect of box depth on bending stress')
yline(sigmaTarget, '--', '300 MPa target', 'LineWidth', 1.5)

nexttile
plot(hList, Res_h(:,5), '-o', 'LineWidth', 2)
grid on
xlabel('hBoxRatio')
ylabel('Approx wing mass [t]')
title('Effect of box depth on mass')

% Study 2: b effect
figure(2); clf;
tiledlayout(3,1)

nexttile
plot(bList, Res_b(:,3), '-o', 'LineWidth', 2)
grid on
xlabel('bBoxRatio')
ylabel('Root GJ [N m^2]')
title('Effect of box width on torsional stiffness')

nexttile
plot(bList, Res_b(:,4), '-o', 'LineWidth', 2)
grid on
xlabel('bBoxRatio')
ylabel('Max bending stress [MPa]')
title('Effect of box width on bending stress')
yline(sigmaTarget, '--', '300 MPa target', 'LineWidth', 1.5)

nexttile
plot(bList, Res_b(:,5), '-o', 'LineWidth', 2)
grid on
xlabel('bBoxRatio')
ylabel('Approx wing mass [t]')
title('Effect of box width on mass')

% Study 3: cap area effect
figure(3); clf;
tiledlayout(3,1)

nexttile
plot(AcapList, Res_A(:,1), '-o', 'LineWidth', 2)
grid on
xlabel('Root spar-cap area [m^2]')
ylabel('Root I_{yy} [m^4]')
title('Effect of cap area on second moment of area')

nexttile
plot(AcapList, Res_A(:,4), '-o', 'LineWidth', 2)
grid on
xlabel('Root spar-cap area [m^2]')
ylabel('Max bending stress [MPa]')
title('Effect of cap area on bending stress')
yline(sigmaTarget, '--', '300 MPa target', 'LineWidth', 1.5)

nexttile
plot(AcapList, Res_A(:,5), '-o', 'LineWidth', 2)
grid on
xlabel('Root spar-cap area [m^2]')
ylabel('Approx wing mass [t]')
title('Effect of cap area on mass')