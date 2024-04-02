% Main Part of SOC Estimator by EKF. This Code Estimates SOC in the Usable
% SOC while Discharging about 100% -> 7% SOC

clear all; close all force;
% clc;
% tic

format long

% Flag to Distinguish Charge / Discharge Case
% Case = "CHG";
Case = "DHG";

% Initialization
dt = 1;                     % Set Sampling Time
last_time = dt * 35000;     % Set Number of Samples
t = 0: dt :last_time;       % t = dt x Number_of_Samples

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

for k = 1 : Nsamples                % Iterate as Number of Samples
    if Init == 0
        % Get Initial State Variable Value
        Cell_Data = Init_Cell(Case, dt);
        
        % Assign Initial State Variable
        % Estimation(k, :) = [Cell_Data.SOC_Initial Cell_Data.V1_Initial];   
        Estimation(k, :) = Cell_Data.esti_init;  

        ActualSOC(k) = Estimation(k:1); % Save Initial SOC 
        AC_SOC(k) = Estimation(k:1);    % Set Amphere Counting`s Initial SOC
        EKFVt(k) = Discharge_Data_0_1C(1);             % Set Predicted Vt`s Initial Value
        Measurement(k) = Discharge_Data_0_1C(1);       % Set Measured Vt`s Initial Value

        Init = 1;

    else
        Temp = GetExperData(k, Cell_Data, dt, Case);
        Cell_Data.Vt = Temp.Vt;
        Cell_Data.V1 = Temp.V1;
        Cell_Data.ik_noise = Temp.ik_noise;
        % Cell_Data.esti_init = Temp.esti_init;

        % Estimate SOC and V1 after giving Measured Vt to EKF
        [SOC_k, V1_k] = SOCEKF(Cell_Data, dt, Case);
        Estimation(k, :) = [SOC_k V1_k];     % Save Estimated SOC and V1 by EKF
        
        % Save Calculated SOC by Amphere Counting which will be used as
        % Reference Value
        ActualSOC(k) = Amphere_Counting(ActualSOC(k-1), dt, Cell_Data, Cell_Data.ik_nominal);
        AC_SOC(k) = Amphere_Counting(AC_SOC(k-1), dt, Cell_Data, Cell_Data.ik_noise);
        % AC_SOC(k) = Amphere_Counting(AC_SOC(k-1), dt, Cell_Data, Cell_Data.ik_nominal);
        EKFVt(k) = hx(Cell_Data,SOC_k, Case);          % Save Predicted Vt
        Measurement(k) = Cell_Data.Vt;           % Save Measured Vt
        Current_Nominal(k) = Cell_Data.ik_nominal;
        Current_Noise(k) = Cell_Data.ik_noise;

        Error_EKF(k) = ActualSOC(k) - Estimation(k,1);
        Error_AC(k) = ActualSOC(k) - AC_SOC(k);
        Error_Vt(k) = Measurement(k) - EKFVt(k); 

        Error_Rate(k,1) = abs((ActualSOC(k) - Estimation(k,1))) / ActualSOC(k) * 100;  % EKF Error Rate
        Error_Rate(k,2) = abs((ActualSOC(k) - AC_SOC(k))) /  ActualSOC(k) * 100;       % AC Error Rate
        Error_Rate(k,3) = abs((Measurement(k) - EKFVt(k))) / Measurement(k) * 100;     % Vt Error Rate

    end
end

EKFSOC = Estimation(:,1);
V1Saved = Estimation(:,2);
EKF_RMSE = rmse(ActualSOC, EKFSOC)
Amphere_Counting_RMSE = rmse(ActualSOC, AC_SOC)
Vt_RMSE = rmse(EKFVt, Measurement);
Current_RMSE = rmse(Current_Nominal, Current_Noise)

% toc
% plot(t, EKFVt, 'r')
% hold on
% plot(t, Measurement, 'b')
% legend('EKFVt', 'Measured Vt')
% 
% 
% plot(t, ActualSOC)
% legend("Actual SOC")

subplot(2,2,1)
hold on
plot(t, ActualSOC, 'g')
plot(t, Estimation(:,1), 'r')
plot(t, AC_SOC, 'b')
legend('Actual SOC','EKF SOC', 'AC SOC')
xlabel('Time [s]')
ylabel('SOC [%]')
xlim([0 last_time])

subplot(2,2,2)
hold on
plot(t, EKFVt, 'r')
plot(t, Measurement, 'g')
legend('Estimated Vt', 'Measured Vt')
xlabel('Time [s]')
ylabel('Voltage [V]')
xlim([0 last_time])

subplot(2,2,3)
plot(t, abs(Error_Rate(:,1)), 'r')
hold on
plot(t, abs(Error_Rate(:,2)), 'b')
plot(t, abs(Error_Rate(:,3)), 'g')
xlabel('Time [s]')
ylabel('Error Rate [%]')
legend('EKF Error Rate', 'AC Error Rate', 'Vt Error Rate')

subplot(2,2,4)
hold on
plot(t, Current_Noise, 'b')
xlabel('Time [s]')
ylabel('Amphere [A]')
legend('Current')
hold off
