function [GeomObjs, MassObjs, wingData] = BuildGeometry(obj)
% TBW.BuildGeometry

    GeomObjs = cast.GeomObj.empty;
    MassObjs = cast.MassObj.empty;

    [gFuse, mFuse] = TBW.geom.fuselage(obj);
    GeomObjs(end+1) = gFuse;
    MassObjs(end+1) = mFuse;

    [gWing, mWing, wingData] = TBW.geom.wing(obj);
    GeomObjs(end+1) = gWing;
    MassObjs(end+1) = mWing;

    [gStrut, mStrut] = TBW.geom.strut(obj, wingData);
    if ~isempty(gStrut)
        GeomObjs(end+1) = gStrut;
    end
    if ~isempty(mStrut)
        MassObjs(end+1) = mStrut;
    end

    [gHTP, mHTP] = TBW.geom.htp(obj);
    GeomObjs(end+1) = gHTP;
    MassObjs(end+1) = mHTP;

    [gVTP, mVTP] = TBW.geom.vtp(obj);
    GeomObjs(end+1) = gVTP;
    MassObjs(end+1) = mVTP;
end