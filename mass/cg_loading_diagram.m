% ================= CG LOADING DIAGRAM =================

clc;
clear;
close all;

% ---------------- FINAL DATA ----------------
cg_mac = [34.7, 29.1, 17.7];
mass_t = [116.365, 208.365, 328.365];

% ---------------- PLOT ----------------
figure;
plot(cg_mac, mass_t, '-o', 'LineWidth', 1.5);
grid on;
hold on;

xlabel('CG (%MAC)');
ylabel('Mass (t)');
title('Final CG Loading Diagram');

% ---------------- LABELS ----------------
text(cg_mac(1), mass_t(1), '  OEW');
text(cg_mac(2), mass_t(2), '  MZFW');
text(cg_mac(3), mass_t(3), '  Take-off');

% ---------------- LIMITS ----------------
xline(15, '--', 'Forward CG Limit');
xline(35, '--', 'Aft CG Limit');

% ---------------- LOADING ----------------
text(31.5, 150, 'Payload Loading', 'FontSize', 10);
text(22.5, 260, 'Fuel Loading', 'FontSize', 10);

hold off;

% ================= NOTES =================
% MAC = 4.7 m
% LEMAC = 29.35 m
% 25% MAC = 30.53 m
% Wing mass = 36 t
% Tail masses updated
% Fuel = 120 t
