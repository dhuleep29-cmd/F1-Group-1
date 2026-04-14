clear
clc
close all

%% Frozen TBW design
opts = struct();
opts.AR = 14;
opts.span = 70;
opts.lambda = 0.35;
opts.sweep = 15;
opts.MTOM = 280350000;

R = TBW_StructuralAnalysis('B', 2.5, opts);

%% Fuel data
fuelFrac = 0.19;
rhoFuel = 800;          % kg/m^3
usableFrac = 0.60;      % usable fraction of wingbox area
fuelSpanFrac = 0.60;    % tank extends to 60% semi-span

mFuel_total = fuelFrac * R.MTOM_kg;
mFuel_half  = 0.5 * mFuel_total;

Vfuel_req_half = mFuel_half / rhoFuel;

%% Tank region
tankMask = R.y <= fuelSpanFrac * R.semiSpan;

% usable box area
Afuel_y = usableFrac .* R.bBox_y .* R.hBox_y;

% integrate half-wing tank volume
Vfuel_avail_half = trapz(R.y(tankMask), Afuel_y(tankMask));

fprintf('\n====================================================\n');
fprintf('FUEL TANK SIZING\n');
fprintf('====================================================\n');
fprintf('Total fuel mass        = %.1f kg\n', mFuel_total);
fprintf('Half-wing fuel mass    = %.1f kg\n', mFuel_half);
fprintf('Required half volume   = %.2f m^3\n', Vfuel_req_half);
fprintf('Available half volume  = %.2f m^3\n', Vfuel_avail_half);

if Vfuel_avail_half >= Vfuel_req_half
    fprintf('Fuel tank sizing check : PASS\n');
else
    fprintf('Fuel tank sizing check : FAIL\n');
end

fprintf('Tank span limit        = %.2f m\n', fuelSpanFrac * R.semiSpan);

figure(1); clf;
plot(R.y, R.bBox_y .* R.hBox_y, 'LineWidth', 1.8); hold on
plot(R.y(tankMask), Afuel_y(tankMask), 'LineWidth', 1.8)
grid on
xlabel('y [m]')
ylabel('Area [m^2]')
legend('Gross wingbox area','Usable fuel area','Location','best')
title('Fuel tank area distribution')