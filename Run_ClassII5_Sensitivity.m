clear; clc;

%% =========================
% READ TABLE
%% =========================
T = readtable('parameters.xlsx','Sheet','Flights');

% Rename imported columns
T.TripFuel_kg    = T.TripFuel_kg_;
T.ReleaseFuel_kg = T.ReleaseFuel_kg_;
T.AirTime_hr     = T.AirTime_kg_;      % values are hours
T.Payload_kg     = T.Payload_kg_;
T.ZFW_kg         = T.ZFW_kg_;
T.TOW_kg         = T.TOW_kg_;

% Distance column from nautical miles to km
T.Distance_km = T.("FlightplanDist_nm_") * 1.852;

% Convert airtime if text like '12:15'
if iscell(T.AirTime_hr) || isstring(T.AirTime_hr)
    txt = string(T.AirTime_hr);
    parts = split(txt, ':');
    hrs = str2double(parts(:,1));
    mins = str2double(parts(:,2));
    T.AirTime_hr = hrs + mins/60;
end

%% =========================
% GLOBAL SETTINGS
%% =========================
UseSAF = 1;
NavRate = 0;
FleetSize = 8;                 % as requested
TotalFlights = height(T);
FlightsPerAircraft = TotalFlights / FleetSize;
AvgTime = mean(T.AirTime_hr,'omitnan');

%% =========================
% SENSITIVITY CASES
% Choose one driver to vary
%% =========================
Case(1).Name = 'Baseline';
Case(1).FuelBurnScale = 1.00;
Case(1).MTOMScale = 1.00;
Case(1).PayloadScale = 1.00;

Case(2).Name = 'Fuel Burn +5%';
Case(2).FuelBurnScale = 1.05;
Case(2).MTOMScale = 1.00;
Case(2).PayloadScale = 1.00;

Case(3).Name = 'Fuel Burn -5%';
Case(3).FuelBurnScale = 0.95;
Case(3).MTOMScale = 1.00;
Case(3).PayloadScale = 1.00;

Case(4).Name = 'Payload +10%';
Case(4).FuelBurnScale = 1.00;
Case(4).MTOMScale = 1.00;
Case(4).PayloadScale = 1.10;

Case(5).Name = 'Payload -10%';
Case(5).FuelBurnScale = 1.00;
Case(5).MTOMScale = 1.00;
Case(5).PayloadScale = 0.90;

%% =========================
% PREALLOCATE SUMMARY STORAGE
%% =========================
nCase = numel(Case);

SeasonDOC       = zeros(nCase,1);
AvgDOC          = zeros(nCase,1);

FuelTotal       = zeros(nCase,1);
CrewTotal       = zeros(nCase,1);
LandingTotal    = zeros(nCase,1);
ParkingTotal    = zeros(nCase,1);
NavigationTotal = zeros(nCase,1);
MaintTotal      = zeros(nCase,1);
InsuranceTotal  = zeros(nCase,1);
DepTotal        = zeros(nCase,1);
IntTotal        = zeros(nCase,1);

%% =========================
% RUN EACH SENSITIVITY CASE
%% =========================
for c = 1:nCase

    n = height(T);

    DOC_vec        = zeros(n,1);
    Fuel_vec       = zeros(n,1);
    Crew_vec       = zeros(n,1);
    Landing_vec    = zeros(n,1);
    Parking_vec    = zeros(n,1);
    Navigation_vec = zeros(n,1);
    Maint_vec      = zeros(n,1);
    Insurance_vec  = zeros(n,1);
    Dep_vec        = zeros(n,1);
    Int_vec        = zeros(n,1);

    for i = 1:n

        In = struct();

        In.MTOM_kg = T.TOW_kg(i) * Case(c).MTOMScale;
        In.FuelBurn_kg = T.TripFuel_kg(i) * Case(c).FuelBurnScale;
        In.FlightTime_hr = T.AirTime_hr(i);
        In.Payload_kg = T.Payload_kg(i) * Case(c).PayloadScale;
        In.Distance_km = T.Distance_km(i);

        In.AirportCode = 'E';
        In.RefuelStop_hr = 0;

        In.UseSAF = UseSAF;
        In.FlightsPerSeason = FlightsPerAircraft;
        In.AvgFlightTime_hr = AvgTime;
        In.NavRate_USD_per_km = NavRate;

        Out = DocModel_ClassIIBreakdown(In);

        DOC_vec(i)        = Out.DOC_flight_USD;
        Fuel_vec(i)       = Out.Fuel;
        Crew_vec(i)       = Out.Crew;
        Landing_vec(i)    = Out.Landing;
        Parking_vec(i)    = Out.Parking;
        Navigation_vec(i) = Out.Navigation;
        Maint_vec(i)      = Out.Maint;
        Insurance_vec(i)  = Out.Insurance;
        Dep_vec(i)        = Out.Dep;
        Int_vec(i)        = Out.Int;
    end

    SeasonDOC(c)       = sum(DOC_vec,'omitnan');
    AvgDOC(c)          = mean(DOC_vec,'omitnan');

    FuelTotal(c)       = sum(Fuel_vec,'omitnan');
    CrewTotal(c)       = sum(Crew_vec,'omitnan');
    LandingTotal(c)    = sum(Landing_vec,'omitnan');
    ParkingTotal(c)    = sum(Parking_vec,'omitnan');
    NavigationTotal(c) = sum(Navigation_vec,'omitnan');
    MaintTotal(c)      = sum(Maint_vec,'omitnan');
    InsuranceTotal(c)  = sum(Insurance_vec,'omitnan');
    DepTotal(c)        = sum(Dep_vec,'omitnan');
    IntTotal(c)        = sum(Int_vec,'omitnan');
end

%% =========================
% PRINT RESULTS
%% =========================
disp('--- CLASS II.5 SENSITIVITY BREAKDOWN ---')
fprintf('Fleet size = %d aircraft\n', FleetSize)

for c = 1:nCase
    fprintf('\n%s\n', Case(c).Name)
    fprintf('Season DOC = $%.0f\n', SeasonDOC(c))
    fprintf('Average DOC/flight = $%.0f\n', AvgDOC(c))

    fprintf('Fuel total = $%.0f\n', FuelTotal(c))
    fprintf('Crew total = $%.0f\n', CrewTotal(c))
    fprintf('Landing total = $%.0f\n', LandingTotal(c))
    fprintf('Parking total = $%.0f\n', ParkingTotal(c))
    fprintf('Navigation total = $%.0f\n', NavigationTotal(c))
    fprintf('Maintenance total = $%.0f\n', MaintTotal(c))
    fprintf('Insurance total = $%.0f\n', InsuranceTotal(c))
    fprintf('Depreciation total = $%.0f\n', DepTotal(c))
    fprintf('Interest total = $%.0f\n', IntTotal(c))
end

%% =========================
% SAVE SUMMARY TABLE
%% =========================
Summary = table( ...
    string({Case.Name})', ...
    repmat(FleetSize,nCase,1), ...
    SeasonDOC, AvgDOC, ...
    FuelTotal, CrewTotal, LandingTotal, ParkingTotal, NavigationTotal, ...
    MaintTotal, InsuranceTotal, DepTotal, IntTotal, ...
    'VariableNames', {'Case','FleetSize','SeasonDOC_USD','AvgDOCperFlight_USD', ...
    'Fuel_USD','Crew_USD','Landing_USD','Parking_USD','Navigation_USD', ...
    'Maintenance_USD','Insurance_USD','Depreciation_USD','Interest_USD'});

writetable(Summary, 'ClassII5_SensitivityBreakdown.xlsx');