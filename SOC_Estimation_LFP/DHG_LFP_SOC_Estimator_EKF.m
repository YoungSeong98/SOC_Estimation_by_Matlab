%% Main Part of SOC Estimator by EKF. This Code Estimates SOC Usable 100% ~ 3%
clear all; close all force; 
clc;
% tic

format long

Case = "DHG";
% Case = "CHG";

%% Initialization
dt = 5;                   % Set Time interval to 1 second
t = 0: dt :dt * 3411;     % Set number of sampling(3392 Discharging Data)
last_time = dt * 3411;

Init = 0;

Nsamples = length(t);

Estimation = zeros(Nsamples, 2);    % Create 2D Array to store Estimated SOC and V1
EKFVt = zeros(Nsamples, 1);         % 1D Array to store Predicted Vt
Measurement = zeros(Nsamples, 1);   % 1D Array to store Measured Vt
ActualSOC = zeros(Nsamples, 1);     % 1D Array to store Reference SOC Value
AC_SOC = zeros(Nsamples, 1);        % 1D Array to store SOC Calculated by Amphere Counting
Current_Nominal = zeros(Nsamples, 1);       % 1D Array to store Nominal Discharge Current
Current_Noise = zeros(Nsamples, 1);       % 1D Array to store Discharge Current Noise Added

Error_EKF = zeros(Nsamples, 1);
Error_AC = zeros(Nsamples, 1);
Error_Vt = zeros(Nsamples, 1);
Error_Rate = zeros(Nsamples, 3);

%% Estimate SOC While Discharging
for k = 1 : Nsamples
    if Init == 0
        % Conduct Initialization
        Cell_Data = Init_Cell(Case, dt);               % Assign 8 Variables

        Estimation(k, :) = [Cell_Data.SOC_Initial Cell_Data.V1_Initial];    % Assign Initial State Variable ValueActualSOC(k) = Cell_Data.SOC_Initial;           % Save Initial SOC
        ActualSOC(k) = Cell_Data.SOC_Initial;           % Save Initial SOC
        AC_SOC(k) = Cell_Data.SOC_Initial;              % Assign Amphere Counting`s Initial SOC 
        EKFVt(k) = Discharge_Data_0_2C_5s(1);              % Assign Predicted Vt`s Initial Value
        Measurement(k) = Discharge_Data_0_2C_5s(1);        % Assign Measured Vt`s Initial Value
        
        Init = 1;
    
    else
        Temp = GetExperData(k, Cell_Data, dt, Case);           % Get Cell`s Discharge Experimental Data
        Cell_Data.Vt = Temp.Vt;
        Cell_Data.V1 = Temp.V1;
        Cell_Data.ik_noise = Temp.ik_noise;
        Cell_Data.esti_init = Temp.esti_init;

        % Estimate SOC and V1 after giving Measured Vt to EKF
        [SOC_k, V1_k] = SOCEKF(Cell_Data, dt, Case);
        Estimation(k, :) = [SOC_k V1_k];     % Save Estimated SOC and V1 by EKF
        
        % Save Calculated SOC by Amphere Counting which will be used as
        % Reference Value
        ActualSOC(k) = Amphere_Counting(ActualSOC(k-1), dt, Cell_Data, Cell_Data.ik_nominal);
        AC_SOC(k) = Amphere_Counting(AC_SOC(k-1), dt, Cell_Data, Cell_Data.ik_noise);
        EKFVt(k) = hx(Cell_Data, SOC_k, Case);          % Save Predicted Vt
        Measurement(k) = Cell_Data.Vt;           % Save Measured Vt
        Current_Nominal(k) = Cell_Data.ik_nominal;
        Current_Noise(k) = Cell_Data.ik_noise;

        Error_EKF(k) = ActualSOC(k) - Estimation(k,1);
        Error_AC(k) = ActualSOC(k) - AC_SOC(k);
        Error_Vt(k) = Measurement(k) - EKFVt(k); 

        Error_Rate(k,1) = (ActualSOC(k) - Estimation(k,1)) / ActualSOC(k) * 100;  % EKF Error Rate
        Error_Rate(k,2) = (ActualSOC(k) - AC_SOC(k)) /  ActualSOC(k) * 100;       % AC Error Rate
        Error_Rate(k,3) = (Measurement(k) - EKFVt(k)) / Measurement(k) * 100;     % Vt Error Rate
    end
end

EKFSOC = Estimation(:,1);
V1Saved = Estimation(:,2);
EKF_RMSE = rmse(ActualSOC, EKFSOC)
Amphere_Counting_RMSE = rmse(ActualSOC, AC_SOC)
Current_RMSE = rmse(Cell_Data.ik_noise, Cell_Data.ik_nominal)
% Vt_RMSE = rmse(Measurement, EKFVt)

% toc
% plot(t, EKFVt, 'r')
% hold on
% plot(t, Measurement, 'b')
% legend('EKFVt', 'Measured Vt')

% subplot(2,2,1)
% hold on
% plot(t, ActualSOC, 'g')
% plot(t, Estimation(:,1), 'r')
% plot(t, AC_SOC, 'b')
% legend('Actual SOC','EKF SOC', 'AC SOC')
% xlim([0 last_time])
% 
% subplot(2,2,2)
% hold on
% plot(t, EKFVt, 'r')
% plot(t, Measurement, 'g')
% legend('Estimated Vt', 'Measured Vt')
% xlim([0 last_time])
% 
% subplot(2,2,3)
% plot(t, abs(Error_Rate(:,1)), 'r')
% hold on
% plot(t, abs(Error_Rate(:,2)), 'b')
% plot(t, abs(Error_Rate(:,3)), 'g')
% legend('EKF Error Rate', 'AC Error Rate', 'Vt Error Rate')
% 
% subplot(2,2,4)
% hold on
% plot(t, Current_Noise, 'b')
% legend('Discharge Current')
% hold off

