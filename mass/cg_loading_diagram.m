% ================= CG LOADING DIAGRAM =================

clc;
clear;
close all;

% ---------------- UPDATED DATA ----------------
% Loading order: OEW -> MZFW -> Take-off
cg_mac = [31.9, 29.1, 14.8];
mass_t = [152.465, 244.465, 358.085];

% ---------------- PLOT ----------------
figure;
plot(cg_mac, mass_t, '-o', 'LineWidth', 1.5);
grid on;
hold on;

xlabel('CG (%MAC)');
ylabel('Mass (t)');
title('Updated Preliminary CG Loading Diagram');

% ---------------- POINT LABELS ----------------
text(cg_mac(1), mass_t(1), '  OEW');
text(cg_mac(2), mass_t(2), '  MZFW');
text(cg_mac(3), mass_t(3), '  Take-off');

% ---------------- CG LIMITS ----------------
xline(15, '--', 'Forward CG Limit');
xline(35, '--', 'Aft CG Limit');

% ---------------- LOADING LABELS ----------------
% OEW -> MZFW
text(30.0, 195, 'Payload Loading', 'FontSize', 10);

% MZFW -> Take-off
text(21.5, 300, 'Fuel Loading', 'FontSize', 10);

hold off;

% ================= REFERENCE VALUES =================
% MAC = 4.7 m
% LEMAC = 29.25 m
% Updated fuselage mass = 18,492.62 kg
