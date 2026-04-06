function Results = StructuralAnalysis(obj)
% TBW.StructuralAnalysis
% Beam-based conceptual structural model using TBW.ADP inputs

    g = 9.81;
    N = 400;

    b = obj.Span;
    S = obj.WingArea;
    lambda = obj.Taper;
    semiSpan = b/2;

    cr = 2*S/(b*(1+lambda));
    ct = lambda*cr;

    y = linspace(0, semiSpan, N);
    dy = y(2)-y(1);

    c = cr - (cr-ct).*(y/semiSpan);

    mWing = obj.kWing * S;
    mFuel = obj.FuelFrac * obj.MTOM;
    Wtot = obj.MTOM * g;

    % Triangular lift
    Ltot = obj.LoadFactor * Wtot;
    Lhalf = Ltot/2;
    phiL = 1 - y/semiSpan;
    qLift = Lhalf * phiL / trapz(y, phiL);

    % Structure weight
    WwingHalf = (mWing*g)/2;
    qStruct = WwingHalf * c / trapz(y, c);

    % Fuel
    fuelMask = y <= obj.FuelSpanFrac * semiSpan;
    phiFuel = c .* fuelMask;
    if any(phiFuel)
        WfuelHalf = (mFuel*g)/2;
        qFuel = WfuelHalf * phiFuel / trapz(y, phiFuel);
    else
        qFuel = zeros(size(y));
    end

    qNet_noStrut = qLift - qStruct - qFuel;

    pointLoad = zeros(size(y));
    strutReaction = 0;

    if obj.HasStrut
        totalHalfNet = trapz(y, qNet_noStrut);
        strutReaction = obj.StrutShare * totalHalfNet;

        [~, iStrut] = min(abs(y - obj.StrutAttachY));
        idx1 = max(1, iStrut-2);
        idx2 = min(length(y), iStrut+2);
        nPts = idx2 - idx1 + 1;

        pointLoad(idx1:idx2) = strutReaction / (nPts*dy);
    end

    qNet = qNet_noStrut - pointLoad;

    yRev = fliplr(y);
    qRev = fliplr(qNet);

    Vrev = -cumtrapz(yRev, qRev);
    Mrev = -cumtrapz(yRev, Vrev);

    V = fliplr(Vrev);
    M = fliplr(Mrev);

    RootShear = V(1);
    RootBM = M(1);

    sigmaAllow = 180e6;
    hBox = 0.12*cr;
    Areq_root = abs(RootBM)/(sigmaAllow*hBox);
    Areq_y = Areq_root * abs(M)/max(abs(RootBM),1e-9);

    rhoAl = 2800;
    capMassHalf = trapz(y, 2*Areq_y*rhoAl);
    mWingRefined = 2*capMassHalf*1.8;

    Results = struct();
    Results.Config = obj.Name;
    Results.n = obj.LoadFactor;

    Results.b = b;
    Results.S = S;
    Results.lambda = lambda;
    Results.cr = cr;
    Results.ct = ct;

    Results.y = y;
    Results.c = c;

    Results.qLift = qLift;
    Results.qStruct = qStruct;
    Results.qFuel = qFuel;
    Results.qNet_noStrut = qNet_noStrut;
    Results.qNet = qNet;

    Results.strutReaction_N = strutReaction;
    Results.V = V;
    Results.M = M;
    Results.RootShear_N = RootShear;
    Results.RootBM_Nm = RootBM;

    Results.mWing_ClassI_kg = mWing;
    Results.mWing_Refined_kg = mWingRefined;
    Results.hBox_root_m = hBox;
end