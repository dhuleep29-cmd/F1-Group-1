function [GeomObj, massObj] = strut(obj, wingData)
% TBW.geom.strut
% Draw left and right struts in top view

    if ~obj.HasStrut
        GeomObj = cast.GeomObj.empty;
        massObj = cast.MassObj.empty;
        return;
    end

    yWing = obj.StrutAttachY;

    frac = yWing / wingData.semiSpan;
    cAttach = wingData.cr + (wingData.ct - wingData.cr) * frac;
    xLE_attach = wingData.xLE_root + (wingData.xLE_tip - wingData.xLE_root)*frac;
    xWing = xLE_attach + 0.25*cAttach;

    xFuse = obj.StrutAttachXFuselage;

    Xs = [
        xFuse, 0;
        xWing,  yWing;
        NaN, NaN;
        xFuse, 0;
        xWing, -yWing
    ];

    GeomObj = cast.GeomObj(Name="TBW Strut", Xs=Xs);

    mStrut = 1500;
    massObj = cast.MassObj(Name="TBW Strut", m=mStrut, X=[(xFuse+xWing)/2; 0]);
end