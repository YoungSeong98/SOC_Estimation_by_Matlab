%% Main Part of SOC Estimator by EKF. This Code Estimates SOC in Full Range while Charging

clear all; close all force;
% clc;
% tic

format long

% Flag to Distinguish Charge / Discharge Case
Case = "CHG";
% Case = "DHG";

% Initialization 
dt = 1;                   % Set Time interval 
last_time = dt * 34790;     % Estimate 1 Discharge Sequence (35796 Data)
% last_time = dt * 5;
t = 0: dt :last_time;

% last_time = dt * 5;     % Estimate 1 Discharge Sequence (35796 Data)
% t = 0: dt :last_time;

Nsamples = length(t);

Init = 0;       

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

for k = 1 : Nsamples
    if Init == 0
        % Get Initial State Variable Value
        Cell_Data = Init_Cell(Case, dt);

        % Assign Initial State Variables
        Estimation(k, :) = Cell_Data.esti_init;
        ActualSOC(k) = Estimation(k:1); % Save Initial SOC 
        AC_SOC(k) = Estimation(k:1);    % Set Amphere Counting`s Initial SOC
        EKFVt(k) = Charge_Data_0_1C(1);             % Set Predicted Vt`s Initial Value
        Measurement(k) = Charge_Data_0_1C(1005);       % Set Measured Vt`s Initial Value

        Init = 1;

% Estimate SOC while Charging
    else
        Temp = GetExperData(k, Cell_Data, dt, Case);
        Cell_Data.Vt = Temp.Vt;
        Cell_Data.V1 = Temp.V1;
        Cell_Data.ik_noise = Temp.ik_noise;
        
        % Estimate SOC and V1 after giving Measured Vt to EKF
        [SOC_k, V1_k] = SOCEKF(Cell_Data, dt, Case);
        Estimation(k, :) = [SOC_k V1_k];     % Save Estimated SOC and V1 by EKF
        
        % Save Calculated SOC by Amphere Counting which will be used as
        % Reference Value
        ActualSOC(k) = Amphere_Counting(ActualSOC(k-1), dt, Cell_Data, Cell_Data.ik_nominal);
        AC_SOC(k) = Amphere_Counting(AC_SOC(k-1), dt, Cell_Data, Cell_Data.ik_noise);
        % AC_SOC(k) = Amphere_Counting(AC_SOC(k-1), dt, Cell_Data, Cell_Data.ik_noise);
        EKFVt(k) = hx(Cell_Data,SOC_k, Case);          % Save Predicted Vt
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
Vt_RMSE = rmse(EKFVt, Measurement);
Current_RMSE = rmse(Cell_Data.ik_noise, Cell_Data.ik_nominal);

% toc
% plot(t, EKFVt, 'r')
% hold on
% plot(t, Measurement, 'b')
% legend('EKFVt', 'Measured Vt')

subplot(2,2,1)
hold on
plot(t, ActualSOC, 'g')
plot(t, Estimation(:,1), 'r')
plot(t, AC_SOC, 'b')
legend('Actual SOC','EKF SOC', 'AC SOC')
xlim([0 last_time])

subplot(2,2,2)
hold on
plot(t, EKFVt, 'r')
plot(t, Measurement, 'g')
legend('Estimated Vt', 'Measured Vt')
xlim([0 last_time])

subplot(2,2,3)
plot(t, abs(Error_Rate(:,1)), 'r')
hold on
plot(t, abs(Error_Rate(:,2)), 'b')
plot(t, abs(Error_Rate(:,3)), 'g')
legend('EKF Error Rate', 'AC Error Rate', 'Vt Error Rate')

subplot(2,2,4)
hold on
% plot(t, Estimation(:,2))
% legend("V1")
plot(t, Current_Noise, 'b')
legend('Discharge Current')
hold off
