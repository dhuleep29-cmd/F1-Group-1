function Results = TBW_StructuralAnalysis(configName, n, opts)
% TBW_StructuralAnalysis
% Simple half-wing conceptual structural model
%   Config A = cantilever baseline
%   Config B = truss-braced wing (TBW)
%
% Includes:
% - spanwise lift / weight / fuel loading
% - strut reaction load sharing
% - shear, bending moment, torque
% - wingbox preliminary sizing
% - stress estimates
% - simplified static aeroelastic twist coupling
%
% Example:
%   R = TBW_StructuralAnalysis('B',2.5,struct('AR',14,'span',70,...
%       'lambda',0.28,'sweep',25,'enableAeroelastic',true));

    if nargin < 2 || isempty(n)
        n = 2.5;
    end
    if nargin < 3
        opts = struct();
    end

    %% ---------------- constants ----------------
    g = 9.81;
    N = 400;

    fuelFrac_default = 0.19;
    fuelSpanFrac_default = 0.70;

    %% ---------------- material: Aluminium 7050-T7451 ----------------
    rhoAl   = 2830;         % kg/m^3
    EAl     = 71.7e9;       % Pa
    GAl     = 27e9;         % Pa
    sigmaY  = 455e6;        % Pa
    tauY    = 0.58 * sigmaY; % Pa approx shear yield

    sigmaAllow_default = 280e6; % Pa
    tauAllow_default   = 130e6; % Pa

    %% ---------------- configuration defaults ----------------
    switch upper(configName)
        case 'A'
            b_default  = 64.0;
            AR_default = 12.0;
            lambda_default = 0.28;
            MTOM_default   = 360000; % kg

            hasStrut = false;
            yStrutFrac_default = NaN;
            strutShare_default = 0.0;
            kwing_default = 100;

        case 'B'
            b_default  = 70.0;
            AR_default = 14.0;
            lambda_default = 0.28;
            MTOM_default   = 360000; % kg

            hasStrut = true;
            yStrutFrac_default = 0.45;
            strutShare_default = 0.30;
            kwing_default = 100;

        otherwise
            error('configName must be ''A'' or ''B''.');
    end

    %% ---------------- overrides / options ----------------
    if isfield(opts,'AR');        AR = opts.AR;               else; AR = AR_default; end
    if isfield(opts,'span');      b = opts.span;              else; b = b_default; end
    if isfield(opts,'lambda');    lambda = opts.lambda;       else; lambda = lambda_default; end
    if isfield(opts,'MTOM');      MTOM = opts.MTOM;           else; MTOM = MTOM_default; end
    if isfield(opts,'kwing');     kwing = opts.kwing;         else; kwing = kwing_default; end

    if isfield(opts,'fuelFrac');      fuelFrac = opts.fuelFrac;           else; fuelFrac = fuelFrac_default; end
    if isfield(opts,'fuelSpanFrac');  fuelSpanFrac = opts.fuelSpanFrac;   else; fuelSpanFrac = fuelSpanFrac_default; end

    if isfield(opts,'hBoxRatio'); hBoxRatio = opts.hBoxRatio; else; hBoxRatio = 0.12; end
    if isfield(opts,'bBoxRatio'); bBoxRatio = opts.bBoxRatio; else; bBoxRatio = 0.50; end

    if isfield(opts,'sigmaAllow'); sigmaAllow = opts.sigmaAllow; else; sigmaAllow = sigmaAllow_default; end
    if isfield(opts,'tauAllow');   tauAllow   = opts.tauAllow;   else; tauAllow   = tauAllow_default; end

    if isfield(opts,'sweep'); sweep = opts.sweep; else; sweep = 26; end

    if isfield(opts,'enableAeroelastic')
        enableAeroelastic = opts.enableAeroelastic;
    else
        enableAeroelastic = false;
    end

    if isfield(opts,'kTheta')
        kTheta = opts.kTheta;
    else
        kTheta = 4.0;   % conceptual aeroelastic sensitivity
    end

    if isfield(opts,'G')
        Gmat = opts.G;
    else
        Gmat = GAl;
    end

    if hasStrut
        if isfield(opts,'strutShare'); strutShare = opts.strutShare; else; strutShare = strutShare_default; end
        if isfield(opts,'yStrutFrac'); yStrutFrac = opts.yStrutFrac; else; yStrutFrac = yStrutFrac_default; end
    else
        strutShare = 0.0;
        yStrutFrac = NaN;
    end


        if isfield(opts,'enableLandingCase')
        enableLandingCase = opts.enableLandingCase;
    else
        enableLandingCase = false;
    end

    if isfield(opts,'landingLoadFactor')
        landingLoadFactor = opts.landingLoadFactor;
    else
        landingLoadFactor = 2.5;
    end

    if isfield(opts,'yGearFrac')
        yGearFrac = opts.yGearFrac;
    else
        yGearFrac = 0.30;   % 30% of semi-span
    end

        if isfield(opts,'enableEngineLoad')
        enableEngineLoad = opts.enableEngineLoad;
    else
        enableEngineLoad = false;
    end

    if isfield(opts,'mEngine_kg')
        mEngine_kg = opts.mEngine_kg;
    else
        mEngine_kg = 8761;
    end

    if isfield(opts,'yEngineFrac')
        yEngineFrac = opts.yEngineFrac;
    else
        yEngineFrac = 0.25;
    end
    
        if isfield(opts,'ribPitch'); ribPitch = opts.ribPitch; else; ribPitch = 0.75; end   % m
    if isfield(opts,'kRib');     kRib     = opts.kRib;     else; kRib     = 0.005; end  % semi-empirical
    if isfield(opts,'tRefRib');  tRefRib  = opts.tRefRib;  else; tRefRib  = 0.010; end  % m

    if isfield(opts,'nonIdealFactor'); nonIdealFactor = opts.nonIdealFactor; else; nonIdealFactor = 0.12; end
    if isfield(opts,'jointPenalty');   jointPenalty   = opts.jointPenalty;   else; jointPenalty   = 0.03; end
    if isfield(opts,'manholePenalty'); manholePenalty = opts.manholePenalty; else; manholePenalty = 0.02; end
    if isfield(opts,'attachPenalty');  attachPenalty  = opts.attachPenalty;  else; attachPenalty  = 0.03; end
    if isfield(opts,'torsionPenalty'); torsionPenalty = opts.torsionPenalty; else; torsionPenalty = 0.04; end

     if isfield(opts,'strutFactor')
        strutFactor = opts.strutFactor;
    else
        strutFactor = 0.12;   % 8% of wing realistic mass
    end

    if isfield(opts,'hingeFactor')
        hingeFactor = opts.hingeFactor;
    else
        hingeFactor = 0.02;   % 2% of wing realistic mass
    end
    %% ---------------- derived geometry ----------------
    S = b^2 / AR;
    semiSpan = b/2;

    cr = 2*S/(b*(1+lambda));
    ct = lambda*cr;

    y  = linspace(0, semiSpan, N);
    dy = y(2)-y(1);

    c = cr - (cr-ct).*(y/semiSpan);

    %% ---------------- chordwise x positions ----------------
    x_LE = zeros(size(y));
    x_TE = c;
    x_QC = 0.25*c;
    x_front_spar = 0.13*c;
    x_rear_spar  = 0.73*c;

    %% ---------------- strut location ----------------
    if hasStrut
        y_strut = yStrutFrac * semiSpan;
    else
        y_strut = NaN;
    end

        %% ---------------- wingbox geometry ----------------
    hBox = hBoxRatio * cr;
    bBox = bBoxRatio * cr;

    % raw spanwise scaling
    hBox_y_raw = hBoxRatio * c;
    bBox_y_raw = bBoxRatio * c;

    % prevent unrealistically tiny outboard box dimensions
    hBox_min = 0.35 * hBox;
    bBox_min = 0.35 * bBox;

    hBox_y = max(hBox_y_raw, hBox_min);
    bBox_y = max(bBox_y_raw, bBox_min);

    Am_y = bBox_y .* hBox_y;
%% ---------------- geometry-based fuel capacity ----------------
usableFrac = 0.73;   % usable tank fraction
rhoFuel = 0.80;      % kg/L

if isfield(opts,'centerTankSpan')
    centerTankSpan = opts.centerTankSpan;   % m, spanwise width of centre tank
else
    centerTankSpan = 8.0;   % initial guess
end

if isfield(opts,'centerTankAreaFactor')
    centerTankAreaFactor = opts.centerTankAreaFactor; % fraction of root box area
else
    centerTankAreaFactor = 0.90;
end

A_box_y = bBox_y .* hBox_y;   % wing box area along span

% only wet wing region should count as wing tank volume
wetMask = y <= fuelSpanFrac * semiSpan;

V_wing_half_m3  = trapz(y(wetMask), A_box_y(wetMask));
V_wing_total_m3 = 2 * usableFrac * V_wing_half_m3;

% simple centre tank model based on root box area
A_center_ref_m2  = centerTankAreaFactor * A_box_y(1);
V_centerTank_m3  = usableFrac * A_center_ref_m2 * centerTankSpan;

% total fuel capacity
V_fuel_total_m3 = V_wing_total_m3 + V_centerTank_m3;
V_fuel_total_L  = V_fuel_total_m3 * 1000;
mFuel           = V_fuel_total_L * rhoFuel;   % kg

% keep separate masses
mFuel_center_kg     = V_centerTank_m3 * 1000 * rhoFuel;
mFuel_wing_total_kg = V_wing_total_m3 * 1000 * rhoFuel;
    %% ---------------- masses ----------------
    mWing = kwing * S;
    Wtot  = MTOM * g;

    %% ---------------- distributed loads ----------------
    Ltot  = n * Wtot;
    Lhalf = Ltot / 2;

    % triangular lift
    phiL  = 1 - y/semiSpan;
    qLift = Lhalf * phiL / trapz(y,phiL);   % upward

    % structural weight
    WwingHalf = (mWing * g) / 2;
    phiW = c;
    qStruct = WwingHalf * phiW / trapz(y,phiW); % downward

  % wing fuel only should be distributed along the wing
fuelMask = y <= fuelSpanFrac * semiSpan;
phiFuel = c .* fuelMask;

if any(phiFuel)
    WfuelHalf = (mFuel_wing_total_kg * g) / 2;
    qFuel = WfuelHalf * phiFuel / trapz(y,phiFuel); % downward
else
    qFuel = zeros(size(y));
end
qNet_noStrut = qLift - qStruct - qFuel;

    %% ---------------- strut load sharing ----------------
    pointLoad = zeros(size(y));
    strutReaction = 0;

    if hasStrut
        totalHalfNet = trapz(y, qNet_noStrut);
        strutReaction = strutShare * totalHalfNet;

        [~, iStrut] = min(abs(y - y_strut));
        idx1 = max(1, iStrut-2);
        idx2 = min(length(y), iStrut+2);
        nPts = idx2 - idx1 + 1;

        pointLoad(idx1:idx2) = strutReaction / (nPts * dy);
    end

    qNet = qNet_noStrut - pointLoad;

        %% ---------------- engine load ----------------
    enginePointLoad = zeros(size(y));
    engineWeight = 0;
    y_engine = NaN;

    if enableEngineLoad
        y_engine = yEngineFrac * semiSpan;
        engineWeight = mEngine_kg * g;

        [~, iEng] = min(abs(y - y_engine));

        idx1e = max(1, iEng-2);
        idx2e = min(length(y), iEng+2);
        nPtse = idx2e - idx1e + 1;

        enginePointLoad(idx1e:idx2e) = engineWeight / (nPtse * dy);

        % engine acts downward on the wing
        qNet = qNet - enginePointLoad;
    end

        %% ---------------- landing gear load ----------------
    gearPointLoad = zeros(size(y));
    gearReaction = 0;
    y_gear = NaN;

    if enableLandingCase
        y_gear = yGearFrac * semiSpan;

        % total landing reaction shared by 2 main gears
        gearReaction = 0.5 * landingLoadFactor * Wtot;

        [~, iGear] = min(abs(y - y_gear));

        idx1g = max(1, iGear-2);
        idx2g = min(length(y), iGear+2);
        nPtsg = idx2g - idx1g + 1;

        gearPointLoad(idx1g:idx2g) = gearReaction / (nPtsg * dy);

        % gear load acts downward on the wing
        qNet = qNet - gearPointLoad;
    end

    %% ---------------- sweep effect on torsional arm ----------------
    Lambda = deg2rad(sweep);
    sweepFactor = 1 + 0.35*tan(Lambda);

    %% ---------------- torsional load model ----------------
    eLift   = (0.15 * c) * sweepFactor;
    eStruct = (0.05 * c) * sweepFactor;
    eFuel   = (0.08 * c) * sweepFactor;

    qTorque = qLift .* eLift - qStruct .* eStruct - qFuel .* eFuel;

        if enableEngineLoad
        eEngine = 0.20 * cr;   % conceptual engine offset
        qTorque = qTorque - enginePointLoad * eEngine;
    end

        if enableLandingCase
        eGear = 0.10 * cr;   % conceptual gear moment arm
        qTorque = qTorque - gearPointLoad * eGear;
    end

    if hasStrut
        eStrut = (0.10 * cr) * sweepFactor;
        qTorque = qTorque - pointLoad * eStrut;
    end

    %% ---------------- initial shear / bending / torque ----------------
    yRev = fliplr(y);

    qRev = fliplr(qNet);
    Vrev = -cumtrapz(yRev, qRev);
    Mrev = -cumtrapz(yRev, Vrev);

    V = fliplr(Vrev);
    M = fliplr(Mrev);

    qTrev = fliplr(qTorque);
    Trev  = -cumtrapz(yRev, qTrev);
    T     = fliplr(Trev);

    RootShear  = V(1);
    RootBM     = M(1);
    RootTorque = T(1);





    %% ---------------- preliminary torsional stiffness ----------------
    tRef0 = 0.006;   % 6 mm conceptual reference thickness
    J_y = (2 .* bBox_y.^2 .* hBox_y.^2 .* tRef0) ./ max(bBox_y + hBox_y, 1e-9);
    GJ_y = Gmat .* J_y;

    %% ---------------- static aeroelastic correction ----------------
    theta_y = zeros(size(y));

    if enableAeroelastic
        yRev2  = fliplr(y);
        TRev2  = fliplr(T);
        GJRev2 = fliplr(GJ_y);

        dtheta_dy_rev = TRev2 ./ max(GJRev2, 1e-9);
        thetaRev = cumtrapz(yRev2, dtheta_dy_rev);
        theta_y = fliplr(thetaRev);

        % simple lift reduction due to twist
        aeroFactor = max(0.70, 1 + kTheta * theta_y);

        qLift_aero = qLift .* aeroFactor;

        qNet_noStrut_aero = qLift_aero - qStruct - qFuel;
        qNet_aero = qNet_noStrut_aero - pointLoad;

        qTorque_aero = qLift_aero .* eLift - qStruct .* eStruct - qFuel .* eFuel;
        if hasStrut
            qTorque_aero = qTorque_aero - pointLoad * eStrut;
        end

        % update V and M
        qRev = fliplr(qNet_aero);
        Vrev = -cumtrapz(yRev, qRev);
        Mrev = -cumtrapz(yRev, Vrev);

        V = fliplr(Vrev);
        M = fliplr(Mrev);

        % update T
        qTrev = fliplr(qTorque_aero);
        Trev  = -cumtrapz(yRev, qTrev);
        T     = fliplr(Trev);

        RootShear  = V(1);
        RootBM     = M(1);
        RootTorque = T(1);

        qLift = qLift_aero;
        qNet_noStrut = qNet_noStrut_aero;
        qNet = qNet_aero;
        qTorque = qTorque_aero;
    end

    %% ---------------- sizing ----------------
Areq_y = abs(M) ./ max(sigmaAllow .* hBox_y, 1e-9);
Areq_root = Areq_y(1);

    tWeb_req = abs(RootShear) / (2 * tauAllow * hBox);
    Am_root  = bBox * hBox;
    tTorsion_req = abs(RootTorque) / (2 * Am_root * tauAllow);
    tGov_req = max(tWeb_req, tTorsion_req);

    % spanwise thickness distributions
    tWeb_y_raw     = abs(V) ./ max(2 * tauAllow .* hBox_y, 1e-9);
    tTorsion_y_raw = abs(T) ./ max(2 * tauAllow .* Am_y,   1e-9);

    tMin_web  = 0.005; % 4 mm
    tMin_skin = 0.005; % 4 mm

    tWeb_y     = max(tWeb_y_raw, tMin_web);
    tTorsion_y = max(tTorsion_y_raw, tMin_skin);
    tSkin_y    = max(tWeb_y, tTorsion_y);

    %% ---------------- stress estimates ----------------
    Areq_min = 0.15 * Areq_root;
    Aeff_y   = max(Areq_y, Areq_min);

    sigmaBend_y = abs(M) ./ max(Aeff_y .* hBox_y, 1e-9);
    tauShear_y  = abs(V) ./ max(2 .* hBox_y .* tSkin_y, 1e-9);
    tauTorsion_y = abs(T) ./ max(2 .* Am_y .* tSkin_y, 1e-9);

    tauTotal_y = tauShear_y + tauTorsion_y;
    sigmaVM_y  = sqrt(sigmaBend_y.^2 + 3*tauTotal_y.^2);

    validMask = y <= 0.95 * semiSpan;

    sigmaBend_max = max(sigmaBend_y(validMask));
    tauTotal_max  = max(tauTotal_y(validMask));
    sigmaVM_max   = max(sigmaVM_y(validMask));

    %% ---------------- stiffness distributions ----------------
% Approximate spar-cap dominated bending stiffness
% Iyy ~ 2*A_cap*(h/2)^2 = A_cap*h^2/2
Iyy_y = 0.5 .* Aeff_y .* hBox_y.^2;

% Bending stiffness
EI_y = EAl .* Iyy_y;

% Torsional stiffness already based on thin-walled closed box
% GJ_y already computed above from J_y
    %% ---------------- Class II structural weight build-up ----------------
    % Bending material weight from effective spar-cap area
    W_bending_half_kg = trapz(y, 2 .* Aeff_y .* rhoAl);

    % Shear web weight (2 webs)
    W_shearWeb_half_kg = trapz(y, 2 .* hBox_y .* tWeb_y .* rhoAl);

    % Torsion/skin weight (closed box cover contribution)
    perim_y = 2 .* (bBox_y + hBox_y);
    W_torsion_half_kg = trapz(y, perim_y .* tSkin_y .* rhoAl);

    % Ideal primary half-wing structural weight
    W_ideal_half_kg = W_bending_half_kg + W_shearWeb_half_kg + W_torsion_half_kg;

    % ---------------- inertia relief factors ----------------
    % simple conceptual factors, mainly for reporting and interpretation
    y_cp = trapz(y, y .* qLift) / max(trapz(y, qLift), 1e-9);
    y_wg = trapz(y, y .* qStruct) / max(trapz(y, qStruct), 1e-9);

    if any(qFuel > 0)
        y_fuel = trapz(y, y .* qFuel) / max(trapz(y, qFuel), 1e-9);
    else
        y_fuel = 0;
    end

    Rin_wing = (y_wg / max(y_cp,1e-9)) * (mWing / MTOM);

    if mFuel > 0
        Rin_fuel = (y_fuel / max(y_cp,1e-9)) * (mFuel / MTOM);
    else
        Rin_fuel = 0;
    end

    if enableEngineLoad
        Rin_engine = (y_engine / max(y_cp,1e-9)) * (mEngine_kg / MTOM);
    else
        Rin_engine = 0;
    end

    Rin_total = Rin_wing + Rin_fuel + Rin_engine;

    % ---------------- rib weight ----------------
    nRibs_half = max(2, ceil(semiSpan / ribPitch) + 1);
    tMean_box = 0.5 * (mean(tWeb_y(validMask)) + mean(tSkin_y(validMask)));
    W_rib_total_kg = rhoAl * kRib * S * (tRefRib + tMean_box);
    W_rib_half_kg = 0.5 * W_rib_total_kg;

    % ---------------- non-ideal penalties ----------------
    W_nonIdeal_half_kg = W_ideal_half_kg * nonIdealFactor;

    % optional explicit split for reporting
    W_joint_half_kg   = W_ideal_half_kg * jointPenalty;
    W_manhole_half_kg = W_ideal_half_kg * manholePenalty;
    W_attach_half_kg  = W_ideal_half_kg * attachPenalty;
    W_torsionPenalty_half_kg = W_ideal_half_kg * torsionPenalty;

    % if explicit split exceeds generic non-ideal factor, use explicit sum
    W_nonIdeal_explicit_half_kg = W_joint_half_kg + W_manhole_half_kg + ...
                                  W_attach_half_kg + W_torsionPenalty_half_kg;

    if W_nonIdeal_explicit_half_kg > W_nonIdeal_half_kg
        W_nonIdeal_half_kg = W_nonIdeal_explicit_half_kg;
    end

    % ---------------- total Class II structural weight ----------------
    W_classII_total_kg = 2 * (W_ideal_half_kg + W_rib_half_kg + W_nonIdeal_half_kg);

        %% ---------------- secondary structure allowance ----------------
    if isfield(opts,'secondaryFactor')
        secondaryFactor = opts.secondaryFactor;
    else
        secondaryFactor = 0.30;
    end

    W_secondary_total_kg = secondaryFactor * W_classII_total_kg;
    W_wing_realistic_total_kg = W_classII_total_kg + W_secondary_total_kg;

    % keep old refined mass indicator too
    capMassHalf = trapz(y, 2 * Aeff_y * rhoAl);
    mWingRefined = 2 * capMassHalf * 1.8;

           %% ---------------- TBW strut / hinge allowance ----------------
    if hasStrut
        W_strut_total_kg = strutFactor * W_wing_realistic_total_kg;
        W_hinge_total_kg = hingeFactor * W_wing_realistic_total_kg;
    else
        W_strut_total_kg = 0.0;
        W_hinge_total_kg = 0.0;
    end

    W_TBW_extra_total_kg = W_strut_total_kg + W_hinge_total_kg;

        %% ---------------- loaded wing mass ----------------
    % structure + total fuel carried in wing-related tanks
   W_loaded_wing_total_kg = W_wing_realistic_total_kg + W_TBW_extra_total_kg + mFuel;

        %% ---------------- fuel mass distribution ----------------
    rhoFuel = 0.80;   % kg/L, conceptual jet fuel density

    % total fuel already defined as mFuel


 mFuel_total_kg = mFuel;

% keep a simple wing split only if you need reporting
innerFuelFrac_wing = 0.70;
outerFuelFrac_wing = 0.30;

mFuel_inner_kg = innerFuelFrac_wing * mFuel_wing_total_kg;
mFuel_outer_kg = outerFuelFrac_wing * mFuel_wing_total_kg;

    % corresponding volumes
    VFuel_total_L  = mFuel_total_kg / rhoFuel;
    VFuel_center_L = mFuel_center_kg / rhoFuel;
    VFuel_inner_L  = mFuel_inner_kg  / rhoFuel;
    VFuel_outer_L  = mFuel_outer_kg  / rhoFuel;


    %% ---------------- outputs ----------------
    Results = struct();

    Results.Config = upper(configName);
    Results.n = n;

    Results.b = b;
    Results.AR = AR;
    Results.S = S;
    Results.lambda = lambda;
    Results.sweep_deg = sweep;
    Results.MTOM_kg = MTOM;

    Results.kwing = kwing;
    Results.fuelFrac = fuelFrac;
    Results.fuelSpanFrac = fuelSpanFrac;

    Results.cr = cr;
    Results.ct = ct;
    Results.y = y;
    Results.dy = dy;
    Results.c = c;
    Results.semiSpan = semiSpan;

    Results.x_LE = x_LE;
    Results.x_TE = x_TE;
    Results.x_QC = x_QC;
    Results.x_front_spar = x_front_spar;
    Results.x_rear_spar  = x_rear_spar;

    Results.mWing_ClassI_kg = mWing;
    Results.mFuel_kg = mFuel;

    Results.qLift = qLift;
    Results.qStruct = qStruct;
    Results.qFuel = qFuel;
    Results.qNet_noStrut = qNet_noStrut;
    Results.qNet = qNet;
    Results.qTorque = qTorque;

    Results.hasStrut = hasStrut;
    Results.y_strut = y_strut;
    Results.yStrutFrac = yStrutFrac;
    Results.strutShare = strutShare;
    Results.strutReaction_N = strutReaction;
    Results.pointLoad = pointLoad;

    Results.V = V;
    Results.M = M;
    Results.T = T;

    Results.RootShear_N = RootShear;
    Results.RootBM_Nm = RootBM;
    Results.RootTorque_Nm = RootTorque;

    Results.hBoxRatio = hBoxRatio;
    Results.bBoxRatio = bBoxRatio;

    Results.hBox_root_m = hBox;
    Results.bBox_root_m = bBox;
    Results.hBox_y = hBox_y;
    Results.bBox_y = bBox_y;
    Results.usableFrac = usableFrac;
Results.V_wing_total_m3 = V_wing_total_m3;
Results.V_centerTank_m3 = V_centerTank_m3;
Results.V_fuel_total_m3 = V_fuel_total_m3;
Results.V_fuel_total_L  = V_fuel_total_L;
    Results.Areq_root_m2 = Areq_root;
    Results.Areq_y_m2 = Areq_y;
    Results.Aeff_y_m2 = Aeff_y;

    Results.tWeb_req_m = tWeb_req;
    Results.tTorsion_req_m = tTorsion_req;
    Results.tGov_req_m = tGov_req;

    Results.tWeb_y_m = tWeb_y;
    Results.tTorsion_y_m = tTorsion_y;
    Results.tSkin_y_m = tSkin_y;

    Results.mWing_Refined_kg = mWingRefined;

    Results.rhoAl = rhoAl;
    Results.EAl_Pa = EAl;
    Results.G_Pa = Gmat;
    Results.sigmaY_Pa = sigmaY;
    Results.tauY_Pa = tauY;
    Results.sigmaAllow_Pa = sigmaAllow;
    Results.tauAllow_Pa = tauAllow;

    Results.J_y = J_y;
    Results.GJ_y = GJ_y;

    Results.enableAeroelastic = enableAeroelastic;
    Results.kTheta = kTheta;
    Results.theta_y_rad = theta_y;
    Results.theta_y_deg = theta_y * 180/pi;

    Results.sigmaBend_y = sigmaBend_y;
    Results.tauShear_y = tauShear_y;
    Results.tauTorsion_y = tauTorsion_y;
    Results.tauTotal_y = tauTotal_y;
    Results.sigmaVM_y = sigmaVM_y;

    Results.sigmaBend_max_Pa = sigmaBend_max;
    Results.tauTotal_max_Pa  = tauTotal_max;
    Results.sigmaVM_max_Pa   = sigmaVM_max;

    Results.validMask = validMask;

    Results.Iyy_y_m4 = Iyy_y;
Results.EI_y_Nm2 = EI_y;
Results.GJ_y_Nm2 = GJ_y;


    Results.enableLandingCase = enableLandingCase;
    Results.landingLoadFactor = landingLoadFactor;
    Results.yGearFrac = yGearFrac;
    Results.y_gear = y_gear;
    Results.gearReaction_N = gearReaction;
    Results.gearPointLoad = gearPointLoad;

        Results.enableEngineLoad = enableEngineLoad;
    Results.mEngine_kg = mEngine_kg;
    Results.yEngineFrac = yEngineFrac;
    Results.y_engine = y_engine;
    Results.engineWeight_N = engineWeight;
    Results.enginePointLoad = enginePointLoad;
     Results.y_cp_m = y_cp;
    Results.y_wingCG_m = y_wg;
    Results.y_fuelCG_m = y_fuel;

    Results.Rin_wing = Rin_wing;
    Results.Rin_fuel = Rin_fuel;
    Results.Rin_engine = Rin_engine;
    Results.Rin_total = Rin_total;

    Results.nRibs_half = nRibs_half;
    Results.ribPitch_m = ribPitch;
    Results.kRib = kRib;
    Results.tRefRib_m = tRefRib;

    Results.W_bending_half_kg = W_bending_half_kg;
    Results.W_shearWeb_half_kg = W_shearWeb_half_kg;
    Results.W_torsion_half_kg = W_torsion_half_kg;
    Results.W_ideal_half_kg = W_ideal_half_kg;

    Results.W_joint_half_kg = W_joint_half_kg;
    Results.W_manhole_half_kg = W_manhole_half_kg;
    Results.W_attach_half_kg = W_attach_half_kg;
    Results.W_torsionPenalty_half_kg = W_torsionPenalty_half_kg;
    Results.W_nonIdeal_half_kg = W_nonIdeal_half_kg;

    Results.W_rib_half_kg = W_rib_half_kg;
    Results.W_classII_total_kg = W_classII_total_kg;

    Results.nonIdealFactor = nonIdealFactor;
    Results.jointPenalty = jointPenalty;
    Results.manholePenalty = manholePenalty;
    Results.attachPenalty = attachPenalty;
    Results.torsionPenalty = torsionPenalty;
        Results.secondaryFactor = secondaryFactor;
    Results.W_secondary_total_kg = W_secondary_total_kg;
    Results.W_wing_realistic_total_kg = W_wing_realistic_total_kg;

        Results.rhoFuel_kg_per_L = rhoFuel;

    Results.mFuel_total_kg  = mFuel_total_kg;
    Results.mFuel_center_kg = mFuel_center_kg;
    Results.mFuel_inner_kg  = mFuel_inner_kg;
    Results.mFuel_outer_kg  = mFuel_outer_kg;

    Results.VFuel_total_L  = VFuel_total_L;
    Results.VFuel_center_L = VFuel_center_L;
    Results.VFuel_inner_L  = VFuel_inner_L;
    Results.VFuel_outer_L  = VFuel_outer_L;

    Results.W_loaded_wing_total_kg = W_loaded_wing_total_kg;
 
end
   