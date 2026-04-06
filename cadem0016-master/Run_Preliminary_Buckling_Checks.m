clear
clc

%% Material
E  = 71.7e9;   % Pa
nu = 0.33;

%% ---------------- Upper skin compression buckling ----------------
k_comp = 4.0;      % simply supported plate approx
t_skin = 0.006;    % 6 mm
b_skin = 0.25;     % upper skin stringer spacing [m]

sigma_cr = k_comp * (pi^2 * E) / (12*(1-nu^2)) * (t_skin/b_skin)^2;

%% ---------------- Spar web shear buckling ----------------
k_shear = 5.34;    % simply supported web panel approx
t_web   = 0.006;   % 6 mm
b_web   = 0.50;    % effective stiffened web panel width [m]

tau_cr = k_shear * (pi^2 * E) / (12*(1-nu^2)) * (t_web/b_web)^2;

%% ---------------- print ----------------
fprintf('\n====================================================\n');
fprintf('PRELIMINARY BUCKLING CHECKS\n');
fprintf('====================================================\n');

fprintf('\nUpper skin compression buckling:\n');
fprintf('Skin thickness          = %.1f mm\n', t_skin*1e3);
fprintf('Stringer spacing        = %.0f mm\n', b_skin*1e3);
fprintf('Critical buckling stress= %.1f MPa\n', sigma_cr/1e6);

fprintf('\nSpar web shear buckling:\n');
fprintf('Web thickness           = %.1f mm\n', t_web*1e3);
fprintf('Effective panel width   = %.0f mm\n', b_web*1e3);
fprintf('Critical shear buckling = %.1f MPa\n', tau_cr/1e6);