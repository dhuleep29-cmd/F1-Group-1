clear
clc
close all

%% Sweep range
sweepList = [0 10 20 30 40];

nCases = length(sweepList);

RootTorque = zeros(1,nCases);
MaxShear   = zeros(1,nCases);
MaxVM      = zeros(1,nCases);
tTorsion   = zeros(1,nCases);

%% Loop over sweep values
for i = 1:nCases
    
    sweep = sweepList(i);
    
    opts = struct();
    opts.sweep = sweep;
    
    R = TBW_StructuralAnalysis('B',2.5,opts);
    
    RootTorque(i) = abs(R.RootTorque_Nm)/1e6;
    MaxShear(i)   = max(R.tauTotal_y)/1e6;
    MaxVM(i)      = max(R.sigmaVM_y)/1e6;
    tTorsion(i)   = R.tTorsion_req_m*1000;
    
    Results{i} = R;
    
end

%% =========================================================
%% 1 ROOT TORQUE VS SWEEP
figure
plot(sweepList,RootTorque,'-o','LineWidth',2)
grid on
xlabel('Sweep angle [deg]')
ylabel('Root torque [MNm]')
title('Root torque vs sweep')

%% =========================================================
%% 2 MAX TORSIONAL SHEAR VS SWEEP
figure
plot(sweepList,MaxShear,'-o','LineWidth',2)
grid on
xlabel('Sweep angle [deg]')
ylabel('Max shear stress [MPa]')
title('Max torsional shear stress vs sweep')

%% =========================================================
%% 3 MAX VON MISES VS SWEEP
figure
plot(sweepList,MaxVM,'-o','LineWidth',2)
grid on
xlabel('Sweep angle [deg]')
ylabel('Max von Mises stress [MPa]')
title('Max von Mises stress vs sweep')

%% =========================================================
%% 4 REQUIRED TORSION THICKNESS VS SWEEP
figure
plot(sweepList,tTorsion,'-o','LineWidth',2)
grid on
xlabel('Sweep angle [deg]')
ylabel('Required torsion thickness [mm]')
title('Required torsion thickness vs sweep')

%% =========================================================
%% 5 TORQUE DISTRIBUTION ALONG SPAN
figure
hold on

colors = lines(nCases);

for i = 1:nCases
    
    R = Results{i};
    
    plot(R.y,R.T/1e6,'LineWidth',2,'Color',colors(i,:))
    
end

grid on
xlabel('y [m]')
ylabel('Torque [MNm]')
title('Spanwise torque distribution for different sweep angles')

legend('0°','10°','20°','30°','40°')