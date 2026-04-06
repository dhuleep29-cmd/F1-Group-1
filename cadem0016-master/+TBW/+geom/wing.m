function [GeomObj, massObj, wingData] = wing(obj)
% TBW.geom.wing
% Simple swept trapezoidal wing in top view

    b = obj.Span;
    S = obj.WingArea;
    lambda = obj.Taper;
    sweepLE = obj.SweepLE;

    semiSpan = b/2;
    cr = 2*S/(b*(1+lambda));
    ct = lambda*cr;

    % Root and tip leading-edge x-locations
    xLE_root = obj.WingPos - 0.25*cr;
    xLE_tip  = xLE_root + tand(sweepLE)*semiSpan;

    % Outer boundary points in correct order around the wing
    Xs = [
        xLE_tip + ct, -semiSpan;   % left trailing edge
        xLE_tip,      -semiSpan;   % left leading edge
        xLE_root,      0;          % root leading edge
        xLE_tip,       semiSpan;   % right leading edge
        xLE_tip + ct,  semiSpan;   % right trailing edge
        xLE_root + cr, 0           % root trailing edge
    ];

    GeomObj = cast.GeomObj(Name="TBW Wing", Xs=Xs);

    % Class-I wing mass
    mWing = obj.kWing * S;
    massObj = cast.MassObj(Name="TBW Wing", m=mWing, X=[obj.WingPos; 0]);

    wingData = struct();
    wingData.cr = cr;
    wingData.ct = ct;
    wingData.semiSpan = semiSpan;
    wingData.xLE_root = xLE_root;
    wingData.xLE_tip = xLE_tip;
end