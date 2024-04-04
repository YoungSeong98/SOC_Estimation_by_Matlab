% This function initializes the Cell related data, ECM parameters, and
% initial state variables

function cell = Init_Cell(Case, dt)

coulomb_effi = 1;                    
% coulomb_effi = 15.8261 / 15.0989; % Coulombic Efficiency = Q_Discharge / Q_Charge

% Define Initial SOC and Current Depending on CHG/ DHG Case
if Case == "DHG"
    SOC_Initial = OCV_SOC_LUT_0_01C(Discharge_Data_0_1C(1), "DHG", "SOC");
    ik_nominal = 0.41;              % Assume Discharge Current to Positive Sign
    Cn_Nominal = 4.32019;

    % Define ECM Parameters
    % These parameters were acquired by repetitive Discharge experiment
    R0 = 0.001884314;
    R1 = 0.045801322;
    C1 = 4846.080679; 

elseif Case == "CHG"
    % Start from SOC = 5%
    SOC_Initial = OCV_SOC_LUT_0_01C(Charge_Data_0_1C(1005), "CHG", "SOC");
    ik_nominal = -0.41;             % Assume Charge Current to Negative Sign
    Cn_Nominal = 4.07611;            % Nominal Capacity

    % Define ECM Parameters
    R0 = 0.00005884314;
    R1 = 0.01145801322;
    C1 = 4846.080679;
end

Cn = (Cn_Nominal * 3600) / 100;     % Convert Capacity Value to time domain    

% Calculate Initial V1 Value
V1_Initial = ik_nominal * R1 * (1-exp(-dt / (R1 * C1)));

esti_init = [SOC_Initial V1_Initial]; 

% Return Initialization Data
cell.SOC_Initial = SOC_Initial;
cell.V1_Initial = V1_Initial;
cell.coulomb_effi = coulomb_effi;
cell.ik_nominal = ik_nominal;
cell.Cn = Cn;
cell.R0 = R0;
cell.R1 = R1;
cell.C1 = C1;

cell.esti_init = esti_init;
