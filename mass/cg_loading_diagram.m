% CG Loading Diagram - Mass & Stability (Class II)
% Shows OEW, MZFW, and Take-off CG positions
% MAC = 4.7 m
% LEMAC = 29.25 m
% CG limits = 15% to 35% MAC

% ================= CG LOADING DIAGRAM =================

clc;
clear;
close all;

% ---------------- DATA ----------------
% Loading order: OEW -> MZFW -> Take-off
cg_mac = [33.6, 30.6, 16.8];           
mass_t  = [181.061, 273.061, 386.681]; 

% ---------------- PLOT ----------------
figure;
plot(cg_mac, mass_t, '-o', 'LineWidth', 1.5);
grid on;
hold on;

xlabel('CG (%MAC)');
ylabel('Mass (t)');
title('Preliminary CG Loading Diagram');

% ---------------- POINT LABELS ----------------
text(cg_mac(1), mass_t(1), '  OEW');
text(cg_mac(2), mass_t(2), '  MZFW');
text(cg_mac(3), mass_t(3), '  Take-off');

% ---------------- CG LIMITS ----------------
xline(15, '--', 'Forward CG Limit');
xline(35, '--', 'Aft CG Limit');

% ---------------- LOADING LABELS (FIXED) ----------------
% Payload loading (OEW -> MZFW)
text(31.5, 230, 'Payload Loading', 'FontSize', 10);

% Fuel loading (MZFW -> Take-off)
text(24, 320, 'Fuel Loading', 'FontSize', 10);

hold off;

% ================= END =================
