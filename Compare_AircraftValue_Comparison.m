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

%% =========================================================
% AIRCRAFT VALUE / FINANCIAL COST COMPARISON
% Concept A, A350F ref, Concept B, B777F ref, X-66A, NASA SUGAR
%
% NOTES:
% 1) "Aircraft value" here is an empirical hull-value estimate:
%       Vhull = 44880 * MTOM_kg^0.65
%    This is a conceptual economics model, not a market list price.
%
% 2) For X-66A and NASA SUGAR, use them as technology/configuration
%    reference points only, not direct freighter market equivalents.
%
% 3) Update the two "our concept" rows with your final MTOM values.
%% =========================================================

%% -----------------------------
% USER INPUTS
%% -----------------------------
FlightsPerSeason = 75;     % baseline utilisation assumption
AvgFlightTime_hr = 11;     % representative long-haul mission time
Util_hr = FlightsPerSeason * AvgFlightTime_hr;

%% -----------------------------
% AIRCRAFT DEFINITIONS
% Replace Concept A / Concept B MTOM with your final values
%% -----------------------------
Aircraft(1).Name = 'Concept A (our baseline)';
Aircraft(1).Type = 'Our design';
Aircraft(1).MTOM_kg = 300000;      % <-- EDIT if needed
Aircraft(1).Comment = 'Conventional baseline similar to A350F/777F class';

Aircraft(2).Name = 'A350F reference';
Aircraft(2).Type = 'Reference aircraft';
Aircraft(2).MTOM_kg = 319000;
Aircraft(2).Comment = 'Published A350F MTOW reference';

Aircraft(3).Name = 'Concept B (our TBW)';
Aircraft(3).Type = 'Our design';
Aircraft(3).MTOM_kg = 309000;      % <-- EDIT if needed
Aircraft(3).Comment = 'Preferred truss-braced wing concept';

Aircraft(4).Name = 'B777F reference';
Aircraft(4).Type = 'Reference aircraft';
Aircraft(4).MTOM_kg = 347800;
Aircraft(4).Comment = '777F-class reference';

Aircraft(5).Name = 'X-66A reference point';
Aircraft(5).Type = 'Technology reference';
Aircraft(5).MTOM_kg = 280000;      % placeholder reference point
Aircraft(5).Comment = 'NASA/Boeing TTBW technology reference only';

Aircraft(6).Name = 'NASA SUGAR reference point';
Aircraft(6).Type = 'Technology reference';
Aircraft(6).MTOM_kg = 270000;      % placeholder reference point
Aircraft(6).Comment = 'NASA SUGAR TBW reference only';

n = numel(Aircraft);

%% -----------------------------
% PREALLOCATE
%% -----------------------------
MTOM_kg = zeros(n,1);
AircraftValue_USD = zeros(n,1);
Dep_per_hr_USD = zeros(n,1);
Dep_per_flight_USD = zeros(n,1);
Interest_per_flight_USD = zeros(n,1);
Insurance_per_flight_USD = zeros(n,1);

%% -----------------------------
% CALCULATIONS
%% -----------------------------
for i = 1:n

    MTOM_kg(i) = Aircraft(i).MTOM_kg;

    % Hull / aircraft value model
    AircraftValue_USD(i) = 44880 * MTOM_kg(i)^0.65;

    % Depreciation per hour and per flight
    Dep_per_hr_USD(i) = AircraftValue_USD(i) / (14 * Util_hr);
    Dep_per_flight_USD(i) = Dep_per_hr_USD(i) * AvgFlightTime_hr;

    % Interest per flight
    Interest_per_flight_USD(i) = ...
        (0.05 * AircraftValue_USD(i) / Util_hr) * AvgFlightTime_hr;

    % Insurance per flight
    Insurance_per_flight_USD(i) = ...
        (0.006 * AircraftValue_USD(i)) / FlightsPerSeason;
end

%% -----------------------------
% BUILD TABLE
%% -----------------------------
Name = strings(n,1);
Type = strings(n,1);
Comment = strings(n,1);

for i = 1:n
    Name(i) = string(Aircraft(i).Name);
    Type(i) = string(Aircraft(i).Type);
    Comment(i) = string(Aircraft(i).Comment);
end

Results = table( ...
    Name, ...
    Type, ...
    MTOM_kg, ...
    AircraftValue_USD, ...
    Dep_per_hr_USD, ...
    Dep_per_flight_USD, ...
    Interest_per_flight_USD, ...
    Insurance_per_flight_USD, ...
    Comment, ...
    'VariableNames', { ...
    'Aircraft', ...
    'Category', ...
    'MTOM_kg', ...
    'AircraftValue_USD', ...
    'Depreciation_per_hr_USD', ...
    'Depreciation_per_flight_USD', ...
    'Interest_per_flight_USD', ...
    'Insurance_per_flight_USD', ...
    'Notes'});

%% -----------------------------
% DISPLAY RESULTS
%% -----------------------------
disp(' ')
disp('=== AIRCRAFT VALUE / FINANCIAL COST COMPARISON ===')
disp(Results)

%% -----------------------------
% SAVE TO EXCEL
%% -----------------------------
OutputFile = 'AircraftValue_Comparison_Table.xlsx';
writetable(Results, OutputFile, 'Sheet', 'Comparison');

disp(' ')
fprintf('Excel file saved as: %s\n', OutputFile);