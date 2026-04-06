classdef ADP
    % TBW.ADP
    % Simple aircraft design parameter container for TBW concept

    properties
        % Top-level geometry
        Span = 70.0              % m
        WingArea = 350         % m^2
        AR = 14.0
        Taper = 0.35

         % Wing sweep
        SweepLE = 15           % deg

        % Tail
        HtpSpan = 20.0           % m
        HtpArea = 95.0           % m^2
        HtpTaper = 0.35
        HtpPos = 57.5           % m from nose

        VtpHeight = 10.0          % m
        VtpArea = 50.0           % m^2
        VtpPos = 56.5            % m from nose

        % Fuselage
        FuselageLength = 59.9    % m
        CabinRadius = 2.785        % m

        % Wing placement
        WingPos = 28.0    % m from nose

        % Strut geometry
        HasStrut = true
        StrutAttachY = 0.45 * (70.0/2)   % m, wing attachment station
        StrutAttachXWing = []            % optional override
        StrutAttachXFuselage = 20.0      % m
        StrutAttachZFuselage = -3.0      % m

        % Mass / load assumptions
        MTOM = 300000            % kg
        FuelFrac = 0.19
        kWing = 200              % kg/m^2
        LoadFactor = 2.5
        FuelSpanFrac = 0.60
        StrutShare = 0.25

        % Optional labels
        Name = "TBW"
    end

    methods
        function obj = ADP(varargin)
            % Allow name-value pair construction
            if mod(nargin,2) ~= 0
                error('TBW.ADP expects name-value pairs.');
            end
            for i = 1:2:nargin
                name = varargin{i};
                value = varargin{i+1};
                if isprop(obj, name)
                    obj.(name) = value;
                else
                    error('Unknown TBW.ADP property: %s', name);
                end
            end
        end
    end
end