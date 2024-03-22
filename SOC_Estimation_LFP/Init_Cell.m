% This function initialize the simulation
% Initialize Cell`s Parameter Assuming that SOC is 100%

function cell = Init_Cell(Case, dt)

coulomb_effi = 1;                   % Coulombic Efficiency = Q_Discharge / Q_Charge
% coulomb_effi = 14.64938 / 14.84937;

% Define Initial SOC and Current Depending on CHG/ DHG Case
if Case == "DHG"
    SOC_Initial = OCV_SOC_LUT_0_01C(Discharge_Data_0_2C_5s(1), "DHG", "SOC");
    ik_nominal = 3;
    Cn_Nominal = 14.6533;
    
    R0 = 0.00837939;                    % Equivalent Circuit Model Parameters
    R1 = 0.00037329;
    C1 = 300.42379407;

elseif Case == "CHG"
    SOC_Initial = OCV_SOC_LUT_0_01C(Charge_Data_0_2C_10s(1+36), "CHG", "SOC");
    ik_nominal = -3;
    Cn_Nominal = 14.42395;

    R0 = 0.0037939;                    % Equivalent Circuit Model Parameters
    R1 = 0.0077329;
    C1 = 200.42379407;
end

Cn = (Cn_Nominal * 3600) / 100;     % Convert Capacity Value to time domain                    

% Calculate Initial V1 Value
V1_Initial = ik_nominal * R1 * (1-exp(-dt / (R1 * C1)));

% Return Initialization Data
cell.SOC_Initial = SOC_Initial;
cell.V1_Initial = V1_Initial;
cell.coulomb_effi = coulomb_effi;
cell.ik_nominal = ik_nominal;
cell.Cn = Cn;
cell.R0 = R0;
cell.R1 = R1;
cell.C1 = C1;

