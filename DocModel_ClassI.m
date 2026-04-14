function Out = DocModel_ClassI(In)
% DOCMODEL_CLASSI
% Class I Direct Operating Cost model for F1 cargo aircraft
% Uses specification-based costs and standard financial relations

%% -----------------------------
% 1) Constants from specification
%% -----------------------------
CrewAnnual_USD = 600000;          % 4 crew total per aircraft per year
LandingRate_USD_per_t = 25;       % $ per tonne MTOM
JetA1_USD_per_L = 1.0;            % $/L
SAF_USD_per_L   = 2.0;            % $/L
FuelDensity_kg_per_L = 0.8;       % kg/L

%% -----------------------------
% 2) Fuel cost
%% -----------------------------
FuelVolume_L = In.FuelBurn_kg / FuelDensity_kg_per_L;

if In.UseSAF == 1
    FuelPrice_USD_per_L = SAF_USD_per_L;
else
    FuelPrice_USD_per_L = JetA1_USD_per_L;
end

Fuel_USD = FuelVolume_L * FuelPrice_USD_per_L;

%% -----------------------------
% 3) Crew cost per flight
%% -----------------------------
Crew_USD = CrewAnnual_USD / In.FlightsPerSeason;

%% -----------------------------
% 4) Landing fee
%% -----------------------------
MTOM_t = In.MTOM_kg / 1000;
Landing_USD = MTOM_t * LandingRate_USD_per_t;

%% -----------------------------
% 5) Parking fee
%% -----------------------------
switch upper(In.AirportCode)
    case 'C'
        Parking_USD_per_day = 1000;
    case 'D'
        Parking_USD_per_day = 2000;
    case 'E'
        Parking_USD_per_day = 4000;
    case 'F'
        Parking_USD_per_day = 6000;
    otherwise
        error('AirportCode must be C, D, E, or F');
end

Parking_USD = Parking_USD_per_day * (In.RefuelStop_hr / 24);

%% -----------------------------
% 6) Hull value
%% -----------------------------
% Specification-based Class I hull value relation
Vhull_USD = 44880 * In.MTOM_kg^0.65;

%% -----------------------------
% 7) Maintenance
%% -----------------------------
Cm_fixed_USD_per_year = 0.03 * Vhull_USD;
Cm_var_USD_per_hr     = 5e-6 * Vhull_USD;

Maintenance_USD = (Cm_fixed_USD_per_year / In.FlightsPerSeason) + ...
                  (Cm_var_USD_per_hr * In.FlightTime_hr);

%% -----------------------------
% 8) Insurance
%% -----------------------------
Insurance_USD = 0.006 * Vhull_USD / In.FlightsPerSeason;

%% -----------------------------
% 9) Depreciation and Interest
%% -----------------------------
AnnualUtilisation_hr = In.FlightsPerSeason * In.FlightTime_hr;

Depreciation_USD = Vhull_USD / (14 * AnnualUtilisation_hr) * In.FlightTime_hr;
Interest_USD     = 0.05 * Vhull_USD / AnnualUtilisation_hr * In.FlightTime_hr;

%% -----------------------------
% 10) Navigation
%% -----------------------------
% Keep simple in Class I
Navigation_USD = 0;

%% -----------------------------
% 11) Total DOC
%% -----------------------------
DOC_flight_USD = Fuel_USD + Crew_USD + Landing_USD + Parking_USD + ...
                 Maintenance_USD + Insurance_USD + Depreciation_USD + ...
                 Interest_USD + Navigation_USD;

DOC_season_USD = DOC_flight_USD * In.FlightsPerSeason;
DOC_per_tonne_USD = DOC_flight_USD / (In.Payload_kg / 1000);

%% -----------------------------
% 12) Outputs
%% -----------------------------
Out.Fuel_USD = Fuel_USD;
Out.Crew_USD = Crew_USD;
Out.Landing_USD = Landing_USD;
Out.Parking_USD = Parking_USD;
Out.Maintenance_USD = Maintenance_USD;
Out.Insurance_USD = Insurance_USD;
Out.Depreciation_USD = Depreciation_USD;
Out.Interest_USD = Interest_USD;
Out.Navigation_USD = Navigation_USD;

Out.DOC_flight_USD = DOC_flight_USD;
Out.DOC_season_USD = DOC_season_USD;
Out.DOC_per_tonne_USD = DOC_per_tonne_USD;

Out.Vhull_USD = Vhull_USD;
Out.FuelVolume_L = FuelVolume_L;
end