% This function returns Experimental Data measured while charging or
% discharging

function cell = GetExperData(k, Cell_Data, dt, Case)

persistent ik_nominal ik_before ik_noise V1 V1_before Init_Cell

if isempty(Init_Cell)
    V1_before = Cell_Data.V1_Initial;       % Assign Initial V1
    ik_before = Cell_Data.ik_nominal;       % Discharge Current (0.1C) 
    ik_nominal = ik_before;                           
    % cell.esti_init = [Cell_Data.SOC_Initial; Cell_Data.V1_Initial];

    Init_Cell = 1;
end

% Calculate V1 in Discrete Time
V1 = V1_before * exp(-dt/(Cell_Data.R1*Cell_Data.C1)) + Cell_Data.R1*(1 - exp(-dt /(Cell_Data.R1 * Cell_Data.C1)))*ik_before;

if Case == "CHG" 
    cell.Vt = Charge_Data_0_1C(k + 1005);
elseif Case == "DHG"
    cell.Vt = Discharge_Data_0_1C(k);
end

% ik_noise = ik_nominal + (1.*rand-0.5);      

% Add Random Noise to Discharge Current Value
ik_noise = ik_nominal + (1.5.*rand-0.75);   

% Error_Current = (ik_nominal - ik_noise) / ik_nominal * 100

cell.V1 = V1;
cell.ik_nominal = ik_nominal;
cell.ik_noise = ik_noise;

% Assign Present Step`s Data to Previous Step`s Data 
V1_before = V1;
ik_before = ik_noise;
% ik_before = ik_nominal;
