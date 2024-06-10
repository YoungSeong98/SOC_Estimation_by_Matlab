% This function returns Experimental Data measured while charging or
% discharging

function cell = GetExperData(k, Cell_Data, dt, Case)

persistent ik_nominal ik_before ik_noise V1 V1_before V2 V2_before Init_Cell

if isempty(Init_Cell)
    V1_before = Cell_Data.V1_Initial;       % Assign Initial V1
    V2_before = Cell_Data.V2_Initial;       % Assign Initial V2
    ik_nominal = Cell_Data.ik_nominal;       % Discharge Current (0.2C) 
    ik_before = ik_nominal;

    Init_Cell = 1;
end

ik_noise = ik_nominal + (1.*rand-0.5);      % Add Random Noise to Charge / Discharge Current Value
% Error_Current = (ik_nominal - ik_noise) / ik_nominal * 100

% Calculate V1 in Discrete Time
% V1 = V1_before * exp(-dt/(Cell_Data.R1*Cell_Data.C1)) + Cell_Data.R1*(1 - exp(-dt /(Cell_Data.R1 * Cell_Data.C1)))*ik_before;
% V2 = V2_before * exp(-dt/(Cell_Data.R2*Cell_Data.C2)) + Cell_Data.R2*(1 - exp(-dt /(Cell_Data.R2 * Cell_Data.C2)))*ik_before;
V1 = V1_before * exp(-dt/(Cell_Data.R1*Cell_Data.C1)) + Cell_Data.R1*(1 - exp(-dt /(Cell_Data.R1 * Cell_Data.C1)))*ik_noise;
V2 = V2_before * exp(-dt/(Cell_Data.R2*Cell_Data.C2)) + Cell_Data.R2*(1 - exp(-dt /(Cell_Data.R2 * Cell_Data.C2)))*ik_noise;


if Case == "CHG"
    cell.Vt = Charge_Data_0_2C_10s(k+36);
elseif Case == "DHG"
    cell.Vt = Discharge_Data_0_2C_5s(k);
end

cell.V1 = V1;
cell.V2 = V2;
cell.ik_nominal = ik_nominal;
cell.ik_noise = ik_noise;
cell.ik_before = ik_before;
cell.esti_init = [Cell_Data.SOC_Initial; Cell_Data.V1_Initial; Cell_Data.V2_Initial];

% Assign Present Step`s Data to Previous Step`s Data 
V1_before = V1;
V2_before = V2;
ik_before = ik_noise;
% ik_before = ik_nominal;
