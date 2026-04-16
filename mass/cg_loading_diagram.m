% ================= CG LOADING DIAGRAM =================

clc;
clear;
close all;

% ---------------- FINAL DATA ----------------
% Order: OEW -> MZFW -> Take-off
cg_mac = [34.9, 28.3, 15.3];
mass_t = [112.362, 204.362, 340.362];

% ---------------- PLOT ----------------
figure;
plot(cg_mac, mass_t, '-o', 'LineWidth', 1.5);
grid on;
hold on;

xlabel('CG (%MAC)');
ylabel('Mass (t)');
title('Final CG Loading Diagram');

% ---------------- POINT LABELS ----------------
text(cg_mac(1), mass_t(1), '  OEW');
text(cg_mac(2), mass_t(2), '  MZFW');
text(cg_mac(3), mass_t(3), '  Take-off');

% ---------------- CG LIMITS ----------------
xline(15, '--', 'Forward CG Limit');
xline(35, '--', 'Aft CG Limit');

% ---------------- LOADING LABELS ----------------
text(30.5, 150, 'Payload Loading', 'FontSize', 10);
text(21.5, 265, 'Fuel Loading', 'FontSize', 10);

hold off;

% ================= REFERENCE VALUES =================
% MAC = 4.7 m
% LEMAC = 29.45 m
% 25% MAC position = 30.63 m

% ================= MASS ASSUMPTIONS =================
% Wing structural mass = 31.66 t
% Fuselage mass = 18,830.41 kg
% HTP mass = 4000 kg
% VTP mass = 6900 kg
% Fuel mass = 136 t
% Payload = 92 t
% Systems = 22.7 t
% Landing gear = 10.75 t

