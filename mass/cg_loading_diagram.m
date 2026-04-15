
% ================= CG LOADING DIAGRAM =================

clc;
clear;
close all;

% ---------------- FINAL DATA ----------------
% Order: OEW -> MZFW -> Take-off
cg_mac = [35.2, 29.5, 17.4];
mass_t = [115.402, 207.402, 327.402];

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
text(31.5, 150, 'Payload Loading', 'FontSize', 10);
text(22.5, 260, 'Fuel Loading', 'FontSize', 10);

hold off;

% ================= REFERENCE VALUES =================
% MAC = 4.7 m
% LEMAC = 29.35 m
% 25% MAC position = 30.53 m

% ================= MASS ASSUMPTIONS =================
% Wing mass = 34.7 t (structural incl. TBW extras)
% Fuselage mass = 18,830.41 kg
% HTP mass = 4000 kg
% VTP mass = 6900 kg
% Fuel = 120 t
% Payload = 92 t
