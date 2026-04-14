clear; clc;

%% SETTINGS
UseSAF = 1;
FlightsPerSeason = 75;
NavRate = 0; % keep 0 for now

%% READ EXCEL
T = readtable('parameters.xlsx','Sheet','Flights');

%% SHOW MATLAB COLUMN NAMES
disp('Original MATLAB variable names:')
disp(T.Properties.VariableNames)

%% RENAME COLUMNS TO CLEAN NAMES
T.TripFuel_kg  = T.TripFuel_kg_;
T.ReleaseFuel_kg = T.ReleaseFuel_kg_;
T.AirTime_hr   = T.AirTime_kg_;     % values are hours, name is just messy
T.Payload_kg   = T.Payload_kg_;
T.ZFW_kg       = T.ZFW_kg_;
T.TOW_kg       = T.TOW_kg_;

% Distance columns from your sheet
T.Distance_km  = T.FlightplanDist_nm_ * 1.852;

%% CHECK IF AIR TIME IS TEXT LIKE '12:15'
if iscell(T.AirTime_hr) || isstring(T.AirTime_hr)
    txt = string(T.AirTime_hr);
    parts = split(txt, ':');
    hrs = str2double(parts(:,1));
    mins = str2double(parts(:,2));
    T.AirTime_hr = hrs + mins/60;
end

%% AVERAGE TIME FOR FINANCIAL CALC
AvgTime = mean(T.AirTime_hr, 'omitnan');

%% PREALLOCATE
n = height(T);
DOC = zeros(n,1);

%% LOOP THROUGH EACH FLIGHT
for i = 1:n

    In = struct();

    In.MTOM_kg = T.TOW_kg(i);
    In.FuelBurn_kg = T.TripFuel_kg(i);
    In.FlightTime_hr = T.AirTime_hr(i);
    In.Payload_kg = T.Payload_kg(i);
    In.Distance_km = T.Distance_km(i);

    In.AirportCode = 'E';
    In.RefuelStop_hr = 0;

    In.UseSAF = UseSAF;
    In.FlightsPerSeason = FlightsPerSeason;
    In.AvgFlightTime_hr = AvgTime;
    In.NavRate_USD_per_km = NavRate;

    Out = DocModel_ClassII(In);

    DOC(i) = Out.DOC_flight_USD;
end

%% RESULTS
Total_DOC = sum(DOC,'omitnan');
Avg_DOC = mean(DOC,'omitnan');

fprintf('Total Season DOC = $%.0f\n', Total_DOC)
fprintf('Average DOC per flight = $%.0f\n', Avg_DOC)