%% CLASS II: TBW Fuselage Mass Estimate (Raymer)
% Result from Raymer equation is in pounds, then converted to kg

clear; clc;

%% ---------------- INPUTS ----------------
% Geometry
Lf_m   = 59.8;       % fuselage length [m]
D_m    = 5.57;       % fuselage diameter [m]
Sf_m2  = 1046.4;     % fuselage wetted area [m^2]

% Aircraft weight
MTOM_kg = 386618;    % design gross weight / MTOM [kg]
Mdg_kg  = MTOM_kg;   % for Class II, take design gross weight = MTOM

% Load / correction factors
nz   = 3.75;         % ultimate load factor
Kd   = 1.0;          % damage factor
Klg  = 1.0;          % landing gear factor

% Wing geometry inputs for Kws
b_m      = 70.0;     % wing span [m]
sweep_deg = 15.0;    % wing sweep [deg]
lambda    = 0.35;    % taper ratio [-]

%% ---------------- UNIT CONVERSIONS ----------------
m_to_ft    = 3.28084;
m2_to_ft2  = 10.7639;
kg_to_lb   = 2.20462;

Lf_ft   = Lf_m  * m_to_ft;
D_ft    = D_m   * m_to_ft;
Sf_ft2  = Sf_m2 * m2_to_ft2;
Mdg_lb  = Mdg_kg * kg_to_lb;
b_ft    = b_m * m_to_ft;

%% ---------------- WING SWEEP INFLUENCE ----------------
% Raymer-style wing sweep influence term
Kws = 0.75 * ((1 + 2*lambda) / (1 + lambda)) * (b_ft / Lf_ft) * tand(sweep_deg);

%% ---------------- RAYMER FUSELAGE EQUATION ----------------
% W_fus in pounds
Wfus_lb = 0.328 * Kd * Klg * sqrt(Mdg_lb * nz) ...
          * (Lf_ft^0.25) ...
          * (Sf_ft2^0.302) ...
          * ((1 + Kws)^0.04) ...
          * ((Lf_ft / D_ft)^0.10);

% Convert to kg
Wfus_kg = Wfus_lb / kg_to_lb;

%% ---------------- OUTPUTS ----------------
fprintf('--- CLASS II FUSELAGE MASS (RAYMER) ---\n');
fprintf('Fuselage length, Lf           = %.2f m\n', Lf_m);
fprintf('Fuselage diameter, D          = %.2f m\n', D_m);
fprintf('Fuselage wetted area, Sf      = %.2f m^2\n', Sf_m2);
fprintf('Design gross weight, Mdg      = %.0f kg\n', Mdg_kg);
fprintf('Ultimate load factor, nz      = %.2f\n', nz);
fprintf('Damage factor, Kd             = %.2f\n', Kd);
fprintf('Landing gear factor, Klg      = %.2f\n', Klg);
fprintf('Wing sweep influence, Kws     = %.4f\n', Kws);
fprintf('---------------------------------------\n');
fprintf('Fuselage weight               = %.2f lb\n', Wfus_lb);
fprintf('Fuselage mass                 = %.2f kg\n', Wfus_kg);
