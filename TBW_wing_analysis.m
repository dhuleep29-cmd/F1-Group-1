%% TBW Cargo Aircraft — Wing Analysis
%  Fixed span 80m, varying AR
%  Section data from VGK OAT15A viscous runs

clc; clear; close all;

% Inputs

% Aircraft
MTOM    = 300000;       % kg
g       = 9.81;         % m/s^2
W       = MTOM * g;     % N
N_eng   = 2;
WF      = 0.68;         % landing weight / MTOM

% Wing
b       = 80.0;         % m  fixed span
sweep   = 30.0;         % deg
taper   = 0.35;
d_fuse  = 6.5;          % m
e_bonus = 0.05;         % TBW Oswald bonus

% OAT15A from VGK (viscous, M=0.74)
CL_2D   = 0.533;
CDT_2D  = 0.00775;
a0      = 2*pi;

% Cruise FL370
M_cr    = 0.85;
rho_cr  = 0.3483;
V_cr    = 250.8;
q_cr    = 0.5 * rho_cr * V_cr^2;
M_sect  = M_cr * cosd(sweep);

% Sea level
rho_sl  = 1.225;
V_TO    = 74.0;

% High-lift
CL_max_TO   = 2.3;
CL_max_land = 2.7;

% CD0 per flight phase
CD0_cr   = 0.01564;
CD0_TO   = 0.04064;
CD0_land = 0.05564;

% Runway
s_TO    = 2500;
s_land  = 2500;

%% ========== ESDU FUNCTIONS ========

% ESDU 76035 — Oswald efficiency
e_fn = @(AR) min(1./(1 + 0.02*(taper-0.38).^2.*AR ...
       + 0.0145*sind(2*sweep).^2 ...
       + 0.1*(d_fuse/b) + 0.02) + e_bonus, 0.97);

% ESDU 70011 — 3D lift curve slope /rad
beta = sqrt(1 - M_sect^2);
a_fn = @(AR) (a0/beta)*cosd(sweep) ./ ...
       (sqrt(1 + (a0./(beta*pi*AR)).^2) + a0./(beta*pi*AR));

% Constraint analyss

AR_des  = 14;
e_des   = e_fn(AR_des);
K_TO    = 2.34;
CL_TO_g = 0.8 * CL_max_TO;

WS      = linspace(200, 900, 500);

TW_TO   = K_TO * WS ./ (rho_sl * CL_TO_g * s_TO);
TW_cr   = CD0_cr ./ ((WS*g)./q_cr) + (WS*g./q_cr)./(pi*e_des*AR_des);

gamma2  = 0.024;
CL2     = CL_max_TO / 1.44;
CD2     = CD0_TO + CL2^2/(pi*0.75*AR_des);
TW_OEI  = (N_eng/(N_eng-1)) * (CD2/CL2 + gamma2);

WS_stall = (0.5*rho_sl*(V_TO/1.2)^2*CL_max_TO) / g;
WS_land  = (s_land*rho_sl*CL_max_land*g*0.1697/g) / WF;

WS_des  = min(650, min(WS_stall, WS_land));
TW_des  = max([interp1(WS,TW_TO,WS_des), interp1(WS,TW_cr,WS_des), TW_OEI]);
S_des   = MTOM / WS_des;
T_eng   = TW_des * W / N_eng;

figure('Color','k');
hold on;
plot(WS, TW_TO, 'Color',[0.98 0.60 0.09], 'LineWidth',2);
plot(WS, TW_cr, 'Color',[0.38 0.65 0.98], 'LineWidth',2);
yline(TW_OEI,   'Color',[0.67 0.55 0.98], 'LineWidth',2, 'LineStyle','--');
xline(WS_stall, 'Color',[0.98 0.80 0.09], 'LineWidth',1.5, 'LineStyle',':');
xline(WS_land,  'Color',[0.94 0.27 0.27], 'LineWidth',1.5, 'LineStyle',':');
plot(WS_des, TW_des, 'wo', 'MarkerSize',10, 'MarkerFaceColor','w');
set(gca,'Color','k','XColor','w','YColor','w','FontSize',11, ...
    'GridColor',[0.3 0.3 0.3],'GridAlpha',0.4);
grid on; box on;
xlim([200 900]); ylim([0.05 0.45]);
xlabel('W/S  (kg/m^2)'); ylabel('T/W');
title('Constraint Analysis','Color','w');
legend({'Take-off','Cruise','OEI climb','Stall limit','Landing limit','Design point'}, ...
       'TextColor','w','Color',[0.1 0.1 0.1],'EdgeColor',[0.3 0.3 0.3], ...
       'Location','northeast','FontSize',9);

% Ouptut

AR_vec = 8:1:20;
nAR    = length(AR_vec);

S_v    = b^2 ./ AR_vec;
c_root = 2*S_v ./ (b*(1+taper));
c_tip  = taper * c_root;
c_mean = S_v / b;
WS_v   = MTOM ./ S_v;
CL_v   = W ./ (q_cr * S_v);
e_v    = arrayfun(e_fn, AR_vec);
CDi_v  = CL_v.^2 ./ (pi .* e_v .* AR_vec);
CD_v   = CD0_cr + CDi_v;
LD_v   = CL_v ./ CD_v;
D_v    = q_cr .* CD_v .* S_v / 1000;

fprintf('\n%-4s  %-7s  %-6s  %-6s  %-6s  %-7s  %-7s  %-6s\n', ...
        'AR','S(m2)','W/S','CL','e','CDi','CD','L/D');
fprintf('%s\n', repmat('-',1,58));
for i = 1:nAR
    fprintf('%-4d  %-7.1f  %-6.1f  %-6.4f  %-6.4f  %-7.5f  %-7.5f  %-6.2f\n', ...
        AR_vec(i), S_v(i), WS_v(i), CL_v(i), e_v(i), CDi_v(i), CD_v(i), LD_v(i));
end

% DRAG POLARS 

CL_p  = linspace(0, 1.4, 300);
e14   = e_fn(14);
idx14 = find(AR_vec==14);

CD_p_cr   = CD0_cr   + CL_p.^2 ./ (pi * e14  * 14);
CD_p_TO   = CD0_TO   + CL_p.^2 ./ (pi * 0.75 * 14);
CD_p_land = CD0_land + CL_p.^2 ./ (pi * 0.70 * 14);

figure('Color','k');
hold on;
plot(CD_p_cr,   CL_p, 'Color',[0.38 0.65 0.98], 'LineWidth',2);
plot(CD_p_TO,   CL_p, 'Color',[0.98 0.60 0.09], 'LineWidth',2);
plot(CD_p_land, CL_p, 'Color',[0.38 0.85 0.60], 'LineWidth',2);
plot(CD_v(idx14), CL_v(idx14), 'wo', 'MarkerSize',8, 'MarkerFaceColor','w');
set(gca,'Color','k','XColor','w','YColor','w','FontSize',11, ...
    'GridColor',[0.3 0.3 0.3],'GridAlpha',0.4);
grid on; box on;
xlim([0 0.18]); ylim([0 1.4]);
xlabel('C_D'); ylabel('C_L');
title('Drag Polar  —  AR = 14,  b = 80m','Color','w');
legend({'Cruise','Take-off','Landing','Design point'}, ...
       'TextColor','w','Color',[0.1 0.1 0.1],'EdgeColor',[0.3 0.3 0.3], ...
       'Location','northwest','FontSize',9);

% TOTAL LIFT vs TOTAL DRAG 

AR_comp = [10, 14, 17];
cols    = {[0.58 0.64 0.65],[0.38 0.65 0.98],[0.38 0.85 0.60]};

figure('Color','k');
hold on;
for k = 1:3
    AR_k = AR_comp(k);
    S_k  = b^2 / AR_k;
    e_k  = e_fn(AR_k);
    CL_k = linspace(0.1, 1.2, 300);
    CD_k = CD0_cr + CL_k.^2./(pi*e_k*AR_k);
    plot(q_cr*CD_k.*S_k/1000, q_cr*CL_k.*S_k/1000, ...
         'Color',cols{k}, 'LineWidth',2, ...
         'DisplayName',sprintf('AR = %d',AR_k));
end
yline(W/1000, '--', 'Color',[0.98 0.80 0.09], 'LineWidth',1.5, ...
      'DisplayName','Min lift required');
set(gca,'Color','k','XColor','w','YColor','w','FontSize',11, ...
    'GridColor',[0.3 0.3 0.3],'GridAlpha',0.4);
grid on; box on;
xlabel('Total Drag  (kN)'); ylabel('Total Lift  (kN)');
title('Total Lift vs Total Drag  —  b = 80m','Color','w');
legend('TextColor','w','Color',[0.1 0.1 0.1],'EdgeColor',[0.3 0.3 0.3], ...
       'Location','northwest','FontSize',9);

% L/D vs AR 

figure('Color','k');
hold on;
plot(AR_vec, LD_v, 'Color',[0.38 0.65 0.98], 'LineWidth',2);
xline(10, '--', 'Color',[0.58 0.64 0.65], 'LineWidth',1.5);
xline(14, '--', 'Color',[0.38 0.85 0.60], 'LineWidth',1.5);
set(gca,'Color','k','XColor','w','YColor','w','FontSize',11, ...
    'GridColor',[0.3 0.3 0.3],'GridAlpha',0.4);
grid on; box on;
xlabel('Aspect Ratio'); ylabel('L/D');
title('L/D vs Aspect Ratio  —  b = 80m','Color','w');

% SUMMARY 

fprintf('\n========== DESIGN POINT ==========\n');
fprintf('W/S:           %.1f kg/m^2\n', WS_des);
fprintf('T/W:           %.4f\n',        TW_des);
fprintf('Wing area:     %.1f m^2\n',    S_des);
fprintf('Thrust/engine: %.0f kN\n',     T_eng/1000);
fprintf('Root chord:    %.2f m\n',      c_root(idx14));
fprintf('Tip chord:     %.2f m\n',      c_tip(idx14));
fprintf('L/D cruise:    %.2f\n',        LD_v(idx14));
fprintf('CL cruise:     %.4f\n',        CL_v(idx14));
fprintf('===================================\n');