%% CLASS II.5 FUSELAGE MODEL - ULTIMATE LOAD CASE
% TBW Configuration A
% First physics-based fuselage beam + skin sizing model

clear; clc; close all;

%% ---------------- GEOMETRY ----------------
Lf = 59.8;              % fuselage length [m]
D  = 5.57;              % fuselage diameter [m]
r  = D/2;               % fuselage radius [m]
Sf = pi * D * Lf;       % fuselage wetted area [m^2]

%% ---------------- MASSES ----------------
m_fus = 14508.29;       % fuselage mass from Class II [kg]
m_payload = 92000;      % payload per aircraft [kg]

%% ---------------- CONSTANTS ----------------
g = 9.81;               % gravity [m/s^2]
n_limit = 2.5;          % limit load factor
SF_ult  = 1.5;          % ultimate safety factor
n = n_limit * SF_ult;   % ultimate load factor = 3.75

%% ---------------- POSITIONS ----------------
% Cargo region
x_cargo_start = 5.0;    % [m]
x_cargo_end   = 55.8;   % [m]
L_cargo       = x_cargo_end - x_cargo_start;

% Main load points (first assumptions)
x_wing  = 0.45 * Lf;    % wing box location [m]
x_truss = 0.38 * Lf;    % TBW truss location [m]
x_tail  = 0.90 * Lf;    % tail load location [m]

%% ---------------- DISCRETISATION ----------------
Nx = 1000;
x = linspace(0, Lf, Nx);
dx = x(2) - x(1);

%% ---------------- AUXILIARY FUEL LOAD REPRESENTATION ----------------
% Auxiliary fuel represented as a distributed underfloor load
% Tank region provided by Mass & Stability team

x_atank_start = 23.0;                 % [m]
x_atank_end   = 33.0;                 % [m]
L_atank       = x_atank_end - x_atank_start;      % [m]
x_atank_centre = 0.5 * (x_atank_start + x_atank_end);

m_fuel_aux = 30000;                   % [kg] auxiliary fuel mass
rho_fuel = 800;                       % [kg/m^3] Jet-A1
V_fuel_aux = m_fuel_aux / rho_fuel;   % [m^3]

A_atank_use = V_fuel_aux / L_atank;   % [m^2] equivalent required area
m_tank_integration = 800;    % [kg] structural allowance for auxiliary tank system

%% ---------------- DISTRIBUTED LOADS ----------------
% Fuselage self-weight distributed over entire fuselage
w_fus = (m_fus * g * n) / Lf;      % [N/m]

% Payload distributed only over cargo region
payload_per_m = (m_payload * g * n) / L_cargo;   % [N/m]

w_pay = zeros(size(x));
w_pay(x >= x_cargo_start & x <= x_cargo_end) = payload_per_m;

% Auxiliary fuel distributed over auxiliary tank region
aux_fuel_per_m = (m_fuel_aux * g * n) / L_atank;   % [N/m]

w_afuel = zeros(size(x));
w_afuel(x >= x_atank_start & x <= x_atank_end) = aux_fuel_per_m;

% Total distributed load (downward)
w_total = w_fus + w_pay + w_afuel;   % [N/m]

%% ---------------- TOTAL DOWNWARD LOAD ----------------
W_total = trapz(x, w_total);       % [N]

% Resultant location of distributed load
x_resultant = trapz(x, w_total .* x) / W_total;   % [m]

%% ---------------- POINT LOADS ----------------
% First-pass assumption: truss carries 20% of total downward load
F_truss = 0.20 * W_total;    % upward [N]

% Solve for F_wing and F_tail using:
% 1) Sum of vertical forces = 0
% 2) Sum of moments about nose = 0
%
% F_wing + F_tail + F_truss = W_total
% F_wing*x_wing + F_tail*x_tail + F_truss*x_truss = W_total*x_resultant

A = [1 1;
     x_wing x_tail];

b = [W_total - F_truss;
     W_total * x_resultant - F_truss * x_truss];

sol = A \ b;

F_wing = sol(1);   % [N]
F_tail = sol(2);   % [N]

%% ---------------- SHEAR FORCE ----------------
V = zeros(size(x));

for i = 2:length(x)
    % distributed load contribution (downward)
    V(i) = V(i-1) - w_total(i) * dx;

    % add point loads when crossing locations
    if x(i-1) < x_truss && x(i) >= x_truss
        V(i) = V(i) + F_truss;
    end

    if x(i-1) < x_wing && x(i) >= x_wing
        V(i) = V(i) + F_wing;
    end

    if x(i-1) < x_tail && x(i) >= x_tail
        V(i) = V(i) + F_tail;
    end
end

%% ---------------- BENDING MOMENT ----------------
M = zeros(size(x));

for i = 2:length(x)
    M(i) = M(i-1) + V(i) * dx;
end
%% ---------------- TORSION LOAD CASE ----------------
% Simple first-pass torsion case representing asymmetric wing/truss loading

T = zeros(size(x));

T_applied = 3.0e6;    % [Nm] first-pass torsional moment

for i = 1:length(x)
    if x(i) >= x_truss && x(i) <= x_wing
        T(i) = T_applied;
    elseif x(i) > x_wing && x(i) <= x_tail
        T(i) = 0.5 * T_applied;
    else
        T(i) = 0;
    end
end

[Tmax, idxT] = max(abs(T));
x_Tmax = x(idxT);
%% ---------------- CHECKS ----------------
sumF = F_wing + F_tail + F_truss - W_total;
sumM = F_wing*x_wing + F_tail*x_tail + F_truss*x_truss - W_total*x_resultant;

%% ---------------- RESULTS ----------------
[Vmax, idxV] = max(abs(V));
[Mmax, idxM] = max(abs(M));

x_Vmax = x(idxV);
x_Mmax = x(idxM);

fprintf('\n--- Ultimate Load Fuselage Beam Model (3.75g) ---\n');
fprintf('Fuselage length              = %.2f m\n', Lf);
fprintf('Fuselage diameter            = %.2f m\n', D);
fprintf('Fuselage mass                = %.2f kg\n', m_fus);
fprintf('Payload mass                 = %.2f kg\n', m_payload);
fprintf('Total downward load          = %.2f MN\n', W_total/1e6);
fprintf('Distributed load resultant   = %.2f m\n', x_resultant);
fprintf('Wing reaction                = %.2f MN\n', F_wing/1e6);
fprintf('Truss reaction               = %.2f MN\n', F_truss/1e6);
fprintf('Tail load                    = %.2f MN\n', F_tail/1e6);
fprintf('Maximum shear force          = %.2f MN at x = %.2f m\n', Vmax/1e6, x_Vmax);
fprintf('Maximum bending moment       = %.2f MNm at x = %.2f m\n', Mmax/1e6, x_Mmax);
fprintf('Maximum torsional moment     = %.2f MNm at x = %.2f m\n', Tmax/1e6, x_Tmax);
fprintf('Force balance check          = %.6f N\n', sumF);
fprintf('Moment balance check         = %.6f Nm\n', sumM);
fprintf('Shear at end                 = %.6f N\n', V(end));
fprintf('Moment at end                = %.6f Nm\n', M(end));

%% ---------------- PLOTS ----------------
figure;
plot(x, w_total/1e3, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('Distributed load [kN/m]');
title('Ultimate Load (3.75g) Distributed Load Along Fuselage');

figure;
plot(x, V/1e6, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('Shear force [MN]');
title('Ultimate Load (3.75g) Shear Force Diagram');

figure;
plot(x, M/1e6, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('Bending moment [MNm]');
title('Ultimate Load (3.75g) Bending Moment Diagram');

figure;
plot(x, T/1e6, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('Torsional moment [MNm]');
title('Ultimate Load (3.75g) Torsional Moment Distribution');

%% ---------------- STRESS, THICKNESS & PRESSURISATION ----------------
% More conservative structural assumptions
K_d = 1.12;                    % damage factor
sigma_allow_base = 100e6;      % base allowable stress [Pa]
sigma_allow = sigma_allow_base / K_d;   % effective allowable stress [Pa]
delta_p = 70e3;                % cabin pressure difference [Pa]

% Bending thickness distribution
M_abs = abs(M);
t_bending = M_abs ./ (pi * r^2 * sigma_allow);

% Pressurisation thickness (constant along fuselage)
t_press = (delta_p * r) / sigma_allow;
t_press_dist = t_press * ones(size(x));
% Torsion thickness distribution (thin-walled circular tube)
T_abs = abs(T);
t_torsion = T_abs ./ (2 * pi * r^2 * sigma_allow);

% Minimum manufacturing thickness
t_min = 1.5e-3;   % 1.5 mm

% Final required thickness
t_req = max([t_bending; t_press_dist; t_torsion], [], 1);
t_req(t_req < t_min) = t_min;

% Key outputs
fprintf('\n--- Thickness Results ---\n');
fprintf('Damage factor K_d            = %.2f\n', K_d);
fprintf('Effective allowable stress   = %.2f MPa\n', sigma_allow/1e6);
fprintf('Max bending thickness        = %.2f mm\n', max(t_bending)*1000);
fprintf('Pressurisation thickness     = %.2f mm\n', t_press*1000);
fprintf('Max torsion thickness        = %.2f mm\n', max(t_torsion)*1000);
fprintf('Final thickness              = %.2f mm\n', max(t_req)*1000);
%% ---------------- BUCKLING CHECK (ULTIMATE LOAD CASE) ----------------
% Simple flat-panel buckling approximation for fuselage skin between stiffeners

E = 73.1e9;        % Young's modulus for Al 2024-T3 [Pa]
nu = 0.33;         % Poisson's ratio [-]
k_buckling = 4.0;  % simple buckling coefficient
b_panel = 0.15;    % assumed panel width between stiffeners [m]

% Use governing thickness from ultimate load case 
t_panel = max(t_req);   % [m]

% Critical buckling stress
sigma_cr = k_buckling * (pi^2 * E / (12 * (1 - nu^2))) * (t_panel / b_panel)^2;

% Actual maximum bending stress using governing thickness
I_shell = pi * r^3 * t_panel;          % thin circular shell approximation
sigma_actual = Mmax * r / I_shell;     % [Pa]

fprintf('\n--- Buckling Check ---\n');
fprintf('Assumed panel width b        = %.3f m\n', b_panel);
fprintf('Panel thickness t            = %.3f mm\n', t_panel*1000);
fprintf('Critical buckling stress     = %.2f MPa\n', sigma_cr/1e6);
fprintf('Actual bending stress        = %.2f MPa\n', sigma_actual/1e6);

if sigma_cr > sigma_actual
    fprintf('Buckling check               = PASS\n');
else
    fprintf('Buckling check               = FAIL\n');
end
%% ---------------- BENDING & TORSIONAL STIFFNESS ----------------
% Thin circular shell approximations
% Material: Aluminum 2024-T3

E  = 73.1e9;     % [Pa] Young's modulus
nu = 0.33;       % [-] Poisson's ratio
G  = 28.0e9;     % [Pa] shear modulus for AI 2024-T3 

% Distribution using final required thickness
I_dist = pi * r^3 .* t_req;        % second moment of area [m^4]
J_dist = 2 * pi * r^3 .* t_req;    % torsional constant [m^4]

EI_dist = E .* I_dist;             % bending stiffness [N m^2]
GJ_dist = G .* J_dist;             % torsional stiffness [N m^2]

% Governing / representative values
EI_max = max(EI_dist);
EI_min = min(EI_dist);
GJ_max = max(GJ_dist);
GJ_min = min(GJ_dist);

fprintf('\n--- Stiffness Results ---\n');
fprintf('Shear modulus G              = %.2e Pa\n', G);
fprintf('Maximum EI                   = %.2e N m^2\n', EI_max);
fprintf('Minimum EI                   = %.2e N m^2\n', EI_min);
fprintf('Maximum GJ                   = %.2e N m^2\n', GJ_max);
fprintf('Minimum GJ                   = %.2e N m^2\n', GJ_min);

% Representative stiffness at critical section (where bending moment is max)
I_crit = pi * r^3 * t_req(idxM);
J_crit = 2 * pi * r^3 * t_req(idxM);

EI_crit = E * I_crit;
GJ_crit = G * J_crit;

fprintf('Critical-section EI          = %.2e N m^2\n', EI_crit);
fprintf('Critical-section GJ          = %.2e N m^2\n', GJ_crit);

%% ---------------- STIFFNESS PLOTS ----------------
figure;
plot(x, EI_dist, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('EI [N m^2]');
title('Bending Stiffness Distribution Along Fuselage');

figure;
plot(x, GJ_dist, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('GJ [N m^2]');
title('Torsional Stiffness Distribution Along Fuselage');
%% ---------------- THICKNESS PLOTS ----------------
figure;
plot(x, t_bending*1000, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('Thickness [mm]');
title('Bending Thickness Distribution Ultimate Load (3.75g)');

figure;
plot(x, t_req*1000, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('Thickness [mm]');
title('Final Fuselage Thickness (Ultimate Load (3.75g): Bending + Pressure + Torsion)');
%% ---------------- DOOR MODEL (CARGO-BASED) ----------------

x_door_start = 8.0;      % [m]
x_door_end   = 13.2;     % [m]

door_length  = x_door_end - x_door_start;   % ~5.2 m
door_width   = 2.7;      % [m]
door_height  = 2.0;      % [m]

door_side = 'Left';   % cargo door location (industry standard)

% Structural mass estimates
m_door_panel = 400;    % [kg]
m_door_reinf = 600;    % [kg]
m_door_total = m_door_panel + m_door_reinf;

fprintf('\n--- Door Model ---\n');
fprintf('Door location            = %.2f m to %.2f m\n', x_door_start, x_door_end);
fprintf('Door length              = %.2f m\n', door_length);
fprintf('Door size (W x H)        = %.2f m x %.2f m\n', door_width, door_height);
fprintf('Door side                = %s\n', door_side);
fprintf('Door mass added          = %.2f kg\n', m_door_total);

fprintf('\n--- Auxiliary Fuel Load Representation ---\n');
fprintf('Auxiliary tank start         = %.2f m\n', x_atank_start);
fprintf('Auxiliary tank end           = %.2f m\n', x_atank_end);
fprintf('Auxiliary tank length        = %.2f m\n', L_atank);
fprintf('Auxiliary tank centre        = %.2f m\n', x_atank_centre);
fprintf('Auxiliary fuel mass          = %.2f kg\n', m_fuel_aux);
fprintf('Auxiliary fuel volume        = %.2f m^3\n', V_fuel_aux);
fprintf('Equivalent required area     = %.2f m^2\n', A_atank_use);

%% ---------------- MASS CALCULATION ----------------
rho = 2780;                     % aluminium density [kg/m^3]
circumference = 2 * pi * r;     % [m]

% Skin-only mass
dm = rho * circumference .* t_req * dx;
m_fus_skin = sum(dm);

fprintf('\n--- Mass Result ---\n');
fprintf('Class II.5 skin-only fuselage mass = %.2f kg\n', m_fus_skin);

frame_spacing = 0.5;      % [m]
stringer_spacing = 0.15;  % [m]

%% ---------------- DIRECT STRUCTURAL MASS BUILD-UP ----------------

% ---------- STRINGERS ----------
N_stringers = round((2*pi*r) / stringer_spacing);
A_stringer = 1.5e-4;    % [m^2]
L_stringer = 0.90 * Lf;

m_stringers = N_stringers * A_stringer * L_stringer * rho;

% ---------- LONGERONS ----------
N_longerons = 4;
A_longeron = 8.0e-4;     % [m^2]
L_longeron = 0.90 * Lf;

m_longerons = N_longerons * A_longeron * L_longeron * rho;

% ---------- FRAMES / CIRCULAR RINGS ----------
N_frames = floor(Lf / frame_spacing) + 1;
m_per_frame = 20;        % [kg]

m_frames = N_frames * m_per_frame;

% ---------- BULKHEADS ----------
N_bulkheads = 3;
m_per_bulkhead = 120;    % [kg]

m_bulkheads = N_bulkheads * m_per_bulkhead;

% ---------- CARGO FLOOR ----------
m_floor_panel = 1000;      % [kg] floor panels + pallet rails
m_floor_support = 800;     % [kg] floor beams + supports + attachments
m_floor = m_floor_panel + m_floor_support;

% ---------- LOCAL REINFORCEMENT ----------
m_truss_reinf = 250;
m_wingbox_reinf = 350;
m_tail_reinf = 150;

m_local_reinf = m_truss_reinf + m_wingbox_reinf + m_tail_reinf;

% ---------- TOTAL FUSELAGE MASS ----------
m_fus_total = m_fus_skin + m_stringers + m_longerons + m_frames + m_bulkheads + m_floor + m_door_total + m_local_reinf + m_tank_integration;

fprintf('\n--- Direct Structural Mass Build-Up ---\n');
fprintf('Assumed frame spacing              = %.2f m\n', frame_spacing);
fprintf('Assumed stringer spacing           = %.2f m\n', stringer_spacing);
fprintf('Skin mass                          = %.2f kg\n', m_fus_skin);
fprintf('Stringer mass                      = %.2f kg\n', m_stringers);
fprintf('Longeron mass                      = %.2f kg\n', m_longerons);
fprintf('Frame mass                         = %.2f kg\n', m_frames);
fprintf('Bulkhead mass                      = %.2f kg\n', m_bulkheads);
fprintf('Cargo floor panel mass             = %.2f kg\n', m_floor_panel);
fprintf('Cargo floor support mass           = %.2f kg\n', m_floor_support);
fprintf('Total cargo floor mass             = %.2f kg\n', m_floor);
fprintf('Door + door reinforcement mass     = %.2f kg\n', m_door_total);
fprintf('Local reinforcement mass           = %.2f kg\n', m_local_reinf);
fprintf('Fuel tank integration mass         = %.2f kg\n', m_tank_integration);
fprintf('Direct total fuselage mass         = %.2f kg\n', m_fus_total);
%% ---------------- OPTIONAL MASS DISTRIBUTION PLOTS ----------------
m_per_length = rho * circumference .* t_req;   % kg/m
m_cumulative = cumsum(dm);                     % kg

figure;
plot(x, m_per_length, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('Mass per unit length [kg/m]');
title('Fuselage Mass Distribution Along Length');

figure;
plot(x, m_cumulative, 'LineWidth', 1.8);
grid on;
xlabel('x along fuselage [m]');
ylabel('Cumulative mass [kg]');
title('Cumulative Fuselage Mass Along Length');

