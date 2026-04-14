function Out = DocModel_ClassIIBreakdown(In)
% DOCMODEL_CLASSII
% Class II DOC model for F1 cargo aircraft
% Uses per-flight mission data from Excel

%% Constants
CrewAnnual_USD = 600000;      % 4 crew total per aircraft per year
FuelDensity_kg_per_L = 0.8;   % kg/L
LandingRate_USD_per_t = 25;   % $/tonne MTOM

if In.UseSAF == 1
    FuelPrice_USD_per_L = 2.0;
else
    FuelPrice_USD_per_L = 1.0;
end

%% Fuel
FuelVolume_L = In.FuelBurn_kg / FuelDensity_kg_per_L;
FuelCost = FuelVolume_L * FuelPrice_USD_per_L;

%% Crew
CrewCost = CrewAnnual_USD / In.FlightsPerSeason;

%% Landing
Landing = (In.MTOM_kg / 1000) * LandingRate_USD_per_t;

%% Parking
switch upper(string(In.AirportCode))
    case "C"
        Parking_USD_per_day = 1000;
    case "D"
        Parking_USD_per_day = 2000;
    case "E"
        Parking_USD_per_day = 4000;
    case "F"
        Parking_USD_per_day = 6000;
    otherwise
        Parking_USD_per_day = 4000; % default
end

Parking = Parking_USD_per_day * (In.RefuelStop_hr / 24);

%% Navigation
Navigation = In.NavRate_USD_per_km * In.Distance_km;

%% Hull value
Vhull = 44880 * In.MTOM_kg^0.65;

%% Maintenance
Maint_fixed = (0.03 * Vhull) / In.FlightsPerSeason;
Maint_var = 5e-6 * Vhull * In.FlightTime_hr;
Maint = Maint_fixed + Maint_var;

%% Insurance
Insurance = 0.006 * Vhull / In.FlightsPerSeason;

%% Financial costs
Util = In.FlightsPerSeason * In.AvgFlightTime_hr;

Dep = Vhull / (14 * Util) * In.FlightTime_hr;
Int = 0.05 * Vhull / Util * In.FlightTime_hr;

%% Total DOC
DOC = FuelCost + CrewCost + Landing + Parking + Navigation + ...
      Maint + Insurance + Dep + Int;

%% Per tonne
if In.Payload_kg > 0
    DOC_per_tonne = DOC / (In.Payload_kg / 1000);
else
    DOC_per_tonne = NaN;
end

%% Outputs
Out.Fuel = FuelCost;
Out.Crew = CrewCost;
Out.Landing = Landing;
Out.Parking = Parking;
Out.Navigation = Navigation;
Out.Maint = Maint;
Out.Insurance = Insurance;
Out.Dep = Dep;
Out.Int = Int;

Out.DOC_flight_USD = DOC;
Out.DOC_per_tonne_USD = DOC_per_tonne;
end