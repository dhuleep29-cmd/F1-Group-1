function [GeomObj, massObj] = vtp(obj)
% TBW.geom.vtp
% Simple top-view proxy for vertical tail

    S = obj.VtpArea;
    h = obj.VtpHeight;

    rootChord = 6.0;
    tipChord  = 2.5;
    spanProxy = 3.0;  % only for top-view width impression

    xLE_root = obj.VtpPos - 0.25*rootChord;
    xLE_tip  = xLE_root + 2.0;

    Xs = [
        xLE_root + rootChord, -spanProxy;
        xLE_root,             0;
        xLE_tip,              spanProxy;
        xLE_tip + tipChord,   spanProxy;
        xLE_root + rootChord, 0
    ];

    GeomObj = cast.GeomObj(Name="VTP", Xs=Xs);

    mVTP = 3000;
    massObj = cast.MassObj(Name="VTP", m=mVTP, X=[obj.VtpPos; 0]);
end