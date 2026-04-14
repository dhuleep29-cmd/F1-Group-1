function Out = DocModel_ClassII(In)

%% CONSTANTS
CrewAnnual = 600000;
FuelDensity = 0.8;

if In.UseSAF == 1
    FuelPrice = 2;
else
    FuelPrice = 1;
end

%% FUEL
Fuel_L = In.FuelBurn_kg / FuelDensity;
FuelCost = Fuel_L * FuelPrice;

%% CREW
CrewCost = CrewAnnual / In.FlightsPerSeason;

%% LANDING
Landing = (In.MTOM_kg/1000) * 25;

%% PARKING
Parking = 0;

%% HULL
Vhull = 44880 * In.MTOM_kg^0.65;

%% MAINTENANCE
Maint = (0.03 * Vhull)/In.FlightsPerSeason + ...
        (5e-6 * Vhull * In.FlightTime_hr);

%% INSURANCE
Insurance = 0.006 * Vhull / In.FlightsPerSeason;

%% FINANCIAL
Util = In.FlightsPerSeason * In.AvgFlightTime_hr;

Dep = Vhull / (14 * Util) * In.FlightTime_hr;
Int = 0.05 * Vhull / Util * In.FlightTime_hr;

%% TOTAL DOC
DOC = FuelCost + CrewCost + Landing + Parking + ...
      Maint + Insurance + Dep + Int;

Out.DOC_flight_USD = DOC;
end