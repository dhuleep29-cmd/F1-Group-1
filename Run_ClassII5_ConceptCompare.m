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

% Distance column from flight plan distance in nautical miles
T.Distance_km = T.("FlightplanDist_nm_") * 1.852;

% Convert airtime if needed
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
FlightsPerSeason = 75;   % keep fixed for clean Class II.5 comparison

AvgTime = mean(T.AirTime_hr,'omitnan');

%% =========================
% CONCEPT DEFINITIONS
%% =========================
Concept(1).Name = 'Concept A';
Concept(1).FuelBurnScale = 1.00;
Concept(1).MTOMScale = 1.00;

Concept(2).Name = 'Concept B -5%';
Concept(2).FuelBurnScale = 0.95;
Concept(2).MTOMScale = 1.02;

Concept(3).Name = 'Concept B -10%';
Concept(3).FuelBurnScale = 0.90;
Concept(3).MTOMScale = 1.03;

%% =========================
% PREALLOCATE SUMMARY STORAGE
%% =========================
nConcept = numel(Concept);

SeasonDOC      = zeros(nConcept,1);
AvgDOC         = zeros(nConcept,1);

FuelTotal      = zeros(nConcept,1);
CrewTotal      = zeros(nConcept,1);
LandingTotal   = zeros(nConcept,1);
ParkingTotal   = zeros(nConcept,1);
NavigationTotal= zeros(nConcept,1);
MaintTotal     = zeros(nConcept,1);
InsuranceTotal = zeros(nConcept,1);
DepTotal       = zeros(nConcept,1);
IntTotal       = zeros(nConcept,1);

%% =========================
% RUN EACH CONCEPT
%% =========================
for c = 1:nConcept

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

        In.MTOM_kg = T.TOW_kg(i) * Concept(c).MTOMScale;
        In.FuelBurn_kg = T.TripFuel_kg(i) * Concept(c).FuelBurnScale;
        In.FlightTime_hr = T.AirTime_hr(i);
        In.Payload_kg = T.Payload_kg(i);
        In.Distance_km = T.Distance_km(i);

        In.AirportCode = 'E';
        In.RefuelStop_hr = 0;

        In.UseSAF = UseSAF;
        In.FlightsPerSeason = FlightsPerSeason;
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
disp('--- CLASS II.5 CONCEPT COMPARISON ---')

for c = 1:nConcept
    fprintf('\n%s\n', Concept(c).Name)
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
    string({Concept.Name})', ...
    SeasonDOC, AvgDOC, ...
    FuelTotal, CrewTotal, LandingTotal, ParkingTotal, NavigationTotal, ...
    MaintTotal, InsuranceTotal, DepTotal, IntTotal, ...
    'VariableNames', {'Concept','SeasonDOC_USD','AvgDOCperFlight_USD', ...
    'Fuel_USD','Crew_USD','Landing_USD','Parking_USD','Navigation_USD', ...
    'Maintenance_USD','Insurance_USD','Depreciation_USD','Interest_USD'});

writetable(Summary, 'ClassII5_ConceptComparison.xlsx');