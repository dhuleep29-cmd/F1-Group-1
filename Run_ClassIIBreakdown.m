clear; clc;

%% =========================
% SETTINGS
%% =========================
UseSAF = 1;              % 1 = SAF, 0 = Jet-A1
FleetSize = 10;          % assumed fleet size
NavRate = 0;             % set to 0 for now

%% =========================
% READ EXCEL FILE
%% =========================
T = readtable('parameters.xlsx','Sheet','Flights');

disp('Original MATLAB variable names:')
disp(T.Properties.VariableNames)

%% =========================
% RENAME COLUMNS CLEANLY
% These names come from your imported Excel
%% =========================
T.TripFuel_kg     = T.TripFuel_kg_;
T.ReleaseFuel_kg  = T.ReleaseFuel_kg_;
T.AirTime_hr      = T.AirTime_kg_;      % values are hours, despite messy name
T.Payload_kg      = T.Payload_kg_;
T.ZFW_kg          = T.ZFW_kg_;
T.TOW_kg          = T.TOW_kg_;

% Distance column: your file uses flight plan distance in nautical miles
T.Distance_km = T.("FlightplanDist_nm_") * 1.852;

%% =========================
% CONVERT AIR TIME IF NEEDED
%% =========================
if iscell(T.AirTime_hr) || isstring(T.AirTime_hr)
    txt = string(T.AirTime_hr);
    parts = split(txt, ':');
    hrs = str2double(parts(:,1));
    mins = str2double(parts(:,2));
    T.AirTime_hr = hrs + mins/60;
end

%% =========================
% BASIC SEASON SETTINGS
%% =========================
n = height(T);
AvgTime = mean(T.AirTime_hr, 'omitnan');

%% =========================
% PREALLOCATE RESULT ARRAYS
%% =========================
DOC_all = zeros(n,1);
DOC_per_tonne_all = NaN(n,1);

Fuel_all = zeros(n,1);
Crew_all = zeros(n,1);
Landing_all = zeros(n,1);
Parking_all = zeros(n,1);
Navigation_all = zeros(n,1);
Maint_all = zeros(n,1);
Insurance_all = zeros(n,1);
Dep_all = zeros(n,1);
Int_all = zeros(n,1);

%% =========================
% LOOP THROUGH EACH FLIGHT
%% =========================
for i = 1:n

    In = struct();

    In.MTOM_kg = T.TOW_kg(i);
    In.FuelBurn_kg = T.TripFuel_kg(i);
    In.FlightTime_hr = T.AirTime_hr(i);
    In.Payload_kg = T.Payload_kg(i);
    In.Distance_km = T.Distance_km(i);

    In.AirportCode = 'E';      % default taxi code
    In.RefuelStop_hr = 0;      % default

    In.UseSAF = UseSAF;
    In.FlightsPerSeason = 75;
    In.AvgFlightTime_hr = AvgTime;
    In.NavRate_USD_per_km = NavRate;

    Out = DocModel_ClassIIBreakdown(In);

    DOC_all(i) = Out.DOC_flight_USD;
    DOC_per_tonne_all(i) = Out.DOC_per_tonne_USD;

    Fuel_all(i) = Out.Fuel;
    Crew_all(i) = Out.Crew;
    Landing_all(i) = Out.Landing;
    Parking_all(i) = Out.Parking;
    Navigation_all(i) = Out.Navigation;
    Maint_all(i) = Out.Maint;
    Insurance_all(i) = Out.Insurance;
    Dep_all(i) = Out.Dep;
    Int_all(i) = Out.Int;
end

%% =========================
% TOTAL RESULTS
%% =========================
Total_DOC = sum(DOC_all, 'omitnan');
Avg_DOC = mean(DOC_all, 'omitnan');

TotalFuel = sum(Fuel_all, 'omitnan');
TotalCrew = sum(Crew_all, 'omitnan');
TotalLanding = sum(Landing_all, 'omitnan');
TotalParking = sum(Parking_all, 'omitnan');
TotalNavigation = sum(Navigation_all, 'omitnan');
TotalMaint = sum(Maint_all, 'omitnan');
TotalInsurance = sum(Insurance_all, 'omitnan');
TotalDep = sum(Dep_all, 'omitnan');
TotalInt = sum(Int_all, 'omitnan');

%% =========================
% PRINT RESULTS TO COMMAND WINDOW
%% =========================
fprintf('\n--- CLASS II RESULTS ---\n')
fprintf('Total Season DOC = $%.0f\n', Total_DOC)
fprintf('Average DOC per flight = $%.0f\n', Avg_DOC)

fprintf('\n--- COST BREAKDOWN ---\n')
fprintf('Fuel total = $%.0f\n', TotalFuel)
fprintf('Crew total = $%.0f\n', TotalCrew)
fprintf('Landing total = $%.0f\n', TotalLanding)
fprintf('Parking total = $%.0f\n', TotalParking)
fprintf('Navigation total = $%.0f\n', TotalNavigation)
fprintf('Maintenance total = $%.0f\n', TotalMaint)
fprintf('Insurance total = $%.0f\n', TotalInsurance)
fprintf('Depreciation total = $%.0f\n', TotalDep)
fprintf('Interest total = $%.0f\n', TotalInt)

%% =========================
% SAVE RESULTS INTO TABLE
%% =========================
T.DOC_flight_USD = DOC_all;
T.DOC_per_tonne_USD = DOC_per_tonne_all;

T.Fuel_USD = Fuel_all;
T.Crew_USD = Crew_all;
T.Landing_USD = Landing_all;
T.Parking_USD = Parking_all;
T.Navigation_USD = Navigation_all;
T.Maint_USD = Maint_all;
T.Insurance_USD = Insurance_all;
T.Dep_USD = Dep_all;
T.Int_USD = Int_all;

writetable(T, 'ClassII_DOC_Results.xlsx');