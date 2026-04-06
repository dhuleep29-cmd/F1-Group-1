function [GeomObj, massObj] = fuselage(obj)
% TBW.geom.fuselage
% Simple top-view fuselage with cylindrical body and rounded nose/tail

    L = obj.FuselageLength;
    R = obj.CabinRadius;

    noseLen = 6.0;
    tailLen = 8.0;

    x1 = noseLen;
    x2 = L - tailLen;

    tN = linspace(pi/2, -pi/2, 40)';
    noseX = x1 - noseLen*cos(tN);
    noseY = R*sin(tN);

    tT = linspace(-pi/2, pi/2, 40)';
    tailX = x2 + tailLen*cos(tT);
    tailY = R*sin(tT);

    % Outer boundary in clockwise order
    X = [
        noseX;
        linspace(x1, x2, 40)';
        tailX;
        linspace(x2, x1, 40)'
    ];

    Y = [
        noseY;
        -R*ones(40,1);
        tailY;
        R*ones(40,1)
    ];

    Xs = [X, Y];

    GeomObj = cast.GeomObj(Name="Fuselage", Xs=Xs);

    mFuse = 40000;
    massObj = cast.MassObj(Name="Fuselage", m=mFuse, X=[L/2; 0]);
end