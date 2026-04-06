function [GeomObj, massObj] = htp(obj)
% TBW.geom.htp
% Simple horizontal tail in top view

    b = obj.HtpSpan;
    S = obj.HtpArea;
    lambda = obj.HtpTaper;

    semiSpan = b/2;
    cr = 2*S/(b*(1+lambda));
    ct = lambda*cr;

    sweepLE = 32;   % deg
    xLE_root = obj.HtpPos - 0.25*cr;
    xLE_tip  = xLE_root + tand(sweepLE)*semiSpan;

    Xs = [
        xLE_tip + ct, -semiSpan;
        xLE_tip,      -semiSpan;
        xLE_root,      0;
        xLE_tip,       semiSpan;
        xLE_tip + ct,  semiSpan;
        xLE_root + cr, 0
    ];

    GeomObj = cast.GeomObj(Name="HTP", Xs=Xs);

    mHTP = 5000;
    massObj = cast.MassObj(Name="HTP", m=mHTP, X=[obj.HtpPos; 0]);
end