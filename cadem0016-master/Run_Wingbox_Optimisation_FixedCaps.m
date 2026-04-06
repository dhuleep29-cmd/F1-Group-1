clear
clc
close all

%% =========================================================
%% WINGBOX OPTIMISATION - FIXED SPAR CAP AREA FORMULATION
%%
%% Goal:
%%   Reduce bending stress toward 300 MPa by changing:
%%   - hBoxRatio
%%   - bBoxRatio
%%   - root spar-cap area
%%
%% Frozen TBW design:
%%   AR = 14
%%   span = 70 m
%%   sweep = 15 deg
%%   taper = 0.35
%% =========================================================

%% ---------------- target ----------------
sigmaTarget_MPa = 300;
sigmaTol_MPa    = 25;

%% ---------------- frozen TBW geometry ----------------
baseOpts = struct();
baseOpts.AR = 14;
baseOpts.span = 70;
baseOpts.lambda = 0.35;
baseOpts.sweep = 15;
baseOpts.MTOM = 280000;

%% ---------------- material ----------------
rhoAl = 2830;        % kg/m^3
sigmaY = 455e6;      % Pa

%% ---------------- design variables ----------------
hList = 0.10:0.01:0.22;       % box depth ratio
bList = 0.45:0.02:0.65;       % box width ratio
AcapList = 0.040:0.005:0.090; % root cap area [m^2]

nh = length(hList);
nb = length(bList);
na = length(AcapList);

%% storage for best
best.score = inf;

%% sweep all combinations
for ia = 1:na
    Acap_root = AcapList(ia);

    for ih = 1:nh
        for ib = 1:nb

            opts = baseOpts;
            opts.hBoxRatio = hList(ih);
            opts.bBoxRatio = bList(ib);

            R = TBW_StructuralAnalysis('B', 2.5, opts);

            % ---------------- chosen spanwise cap area distribution ----------------
            % scale with bending moment ratio
            Acap_y = Acap_root .* abs(R.M) ./ max(abs(R.RootBM_Nm),1e-9);

            % practical minimum outboard cap area to avoid collapse to zero
            Acap_min = 0.20 * Acap_root;
            Acap_y = max(Acap_y, Acap_min);

            % ---------------- section inertia approximation ----------------
            % two caps separated by hBox_y:
            % I ~ 2*A*(h/2)^2 = A*h^2/2
            Iyy_y = 0.5 .* Acap_y .* R.hBox_y.^2;

            % ---------------- bending stress from chosen geometry ----------------
            sigmaBend_y = abs(R.M) .* (R.hBox_y/2) ./ max(Iyy_y,1e-12);

            % ---------------- crude mass estimate ----------------
            capMassHalf = trapz(R.y, 2 .* Acap_y * rhoAl);  % two caps on half wing

            % approximate web mass
            tWeb_assumed = max(R.tGov_req_m, 0.004);        % min 4 mm
            webMassHalf = trapz(R.y, 2 .* R.hBox_y .* tWeb_assumed .* rhoAl);

            % approximate skin mass
            tSkin_assumed = max(R.tSkin_y_m, 0.003);        % min 3 mm
            skinMassHalf = trapz(R.y, 2 .* R.bBox_y .* tSkin_assumed .* rhoAl);

            mWingApprox = 2 * (capMassHalf + webMassHalf + skinMassHalf); % both wings
            mWingApprox_t = mWingApprox / 1e3;

            % ---------------- metrics ----------------
            maxBend_MPa = max(sigmaBend_y(R.validMask))/1e6;
            rootBend_MPa = sigmaBend_y(1)/1e6;

            % objective
            stressErr = abs(maxBend_MPa - sigmaTarget_MPa) / sigmaTarget_MPa;
            massNorm  = mWingApprox_t / 40;
            score = stressErr + 0.20*massNorm;

            if score < best.score
                best.score = score;
                best.hBoxRatio = hList(ih);
                best.bBoxRatio = bList(ib);
                best.Acap_root = Acap_root;
                best.maxBend_MPa = maxBend_MPa;
                best.rootBend_MPa = rootBend_MPa;
                best.mass_t = mWingApprox_t;
                best.R = R;
                best.Acap_y = Acap_y;
                best.Iyy_y = Iyy_y;
                best.sigmaBend_y = sigmaBend_y;
            end
        end
    end
end

%% =========================================================
%% print results
%% =========================================================
fprintf('\n====================================================\n');
fprintf('FIXED-CAP WINGBOX OPTIMISATION RESULTS\n');
fprintf('====================================================\n');

fprintf('\nBest design:\n');
fprintf('hBoxRatio           = %.3f\n', best.hBoxRatio);
fprintf('bBoxRatio           = %.3f\n', best.bBoxRatio);
fprintf('Root spar-cap area  = %.4f m^2\n', best.Acap_root);
fprintf('Max bending stress  = %.1f MPa\n', best.maxBend_MPa);
fprintf('Root bending stress = %.1f MPa\n', best.rootBend_MPa);
fprintf('Approx wing mass    = %.2f t\n', best.mass_t);

fprintf('\nRoot geometry:\n');
fprintf('Root chord          = %.3f m\n', best.R.cr);
fprintf('Tip chord           = %.3f m\n', best.R.ct);
fprintf('Root wingbox width  = %.3f m\n', best.R.bBox_root_m);
fprintf('Root wingbox height = %.3f m\n', best.R.hBox_root_m);
fprintf('Front spar x        = %.3f m\n', best.R.x_front_spar(1));
fprintf('Rear spar x         = %.3f m\n', best.R.x_rear_spar(1));

if abs(best.maxBend_MPa - sigmaTarget_MPa) <= sigmaTol_MPa
    fprintf('\nTarget stress band achieved.\n');
else
    fprintf('\nTarget stress band NOT achieved exactly, but best available case is reported.\n');
end

%% =========================================================
%% plots for best design
%% =========================================================
R = best.R;

figure(1); clf;
tiledlayout(4,1)

nexttile
plot(R.y(R.validMask), best.sigmaBend_y(R.validMask)/1e6, 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('Bending stress [MPa]')
title('Best design: spanwise bending stress')
yline(sigmaTarget_MPa, '--', '300 MPa target', 'LineWidth', 1.5)

nexttile
plot(R.y(R.validMask), best.Acap_y(R.validMask), 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('Cap area [m^2]')
title('Best design: spanwise spar-cap area')

nexttile
plot(R.y(R.validMask), best.Iyy_y(R.validMask), 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('I_{yy} [m^4]')
title('Best design: spanwise second moment of area')

nexttile
plot(R.y(R.validMask), R.hBox_y(R.validMask), 'LineWidth', 2); hold on
plot(R.y(R.validMask), R.bBox_y(R.validMask), 'LineWidth', 2)
grid on
xlabel('y [m]')
ylabel('Length [m]')
title('Best design: spanwise wingbox dimensions')
legend('hBox','bBox','Location','best')