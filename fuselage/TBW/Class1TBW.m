%% CLASS I: TBW (geometry-based)
% Inputs (edit these):
L = 59.8;      % fuselage length [m]  (Config A)
D = 5.57;      % external diameter [m] (Config A)

% Empirical constant (kg per m^2 of wetted area)
% Start with something like 45 and tune later using a reference aircraft.
k = 45;       % [kg/m^2]

% Wetted area (cylinder approx)
S_wet = pi * D * L;   % [m^2]

% Class I fuselage mass estimate
m_fuse = k * S_wet;   % [kg]

% Display
fprintf('--- Class I Fuselage Mass Estimate ---\n');
fprintf('L = %.2f m, D = %.2f m\n', L, D);
fprintf('S_wet = %.1f m^2\n', S_wet);
fprintf('m_fuse = %.0f kg (using k = %.1f kg/m^2)\n', m_fuse, k);
