

%% Representative Class I mission inputs
In.MTOM_kg = 300000;
In.FuelBurn_kg = 60000;
In.FlightTime_hr = 11;
In.Payload_kg = 100000;
In.FlightsPerSeason = 75;
In.AirportCode = 'E';
In.RefuelStop_hr = 0;
In.UseSAF = 1;

%% Run DOC model
Out = DocModel_ClassI(In);

%% Display results
disp('--- CLASS I DOC RESULTS ---')
fprintf('Fuel cost:        $%.0f\n', Out.Fuel_USD);
fprintf('Crew cost:        $%.0f\n', Out.Crew_USD);
fprintf('Landing fee:      $%.0f\n', Out.Landing_USD);
fprintf('Parking fee:      $%.0f\n', Out.Parking_USD);
fprintf('Maintenance cost: $%.0f\n', Out.Maintenance_USD);
fprintf('Insurance cost:   $%.0f\n', Out.Insurance_USD);
fprintf('Depreciation:     $%.0f\n', Out.Depreciation_USD);
fprintf('Interest:         $%.0f\n', Out.Interest_USD);
fprintf('-----------------------------\n');
fprintf('DOC per flight:   $%.0f\n', Out.DOC_flight_USD);
fprintf('DOC per tonne:    $%.0f/t\n', Out.DOC_per_tonne_USD);
fprintf('DOC per season:   $%.0f\n', Out.DOC_season_USD);