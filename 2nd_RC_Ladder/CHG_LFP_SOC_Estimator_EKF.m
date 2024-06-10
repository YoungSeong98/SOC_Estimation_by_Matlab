% Main Part of SOC Estimator by EKF. This Code Estimates SOC in the Usable
% SOC while Charging about 3% -> 100% SOC

clear all; close all force; 
clc;
% tic

format long

% Case = "DHG";
Case = "CHG";

%% Initialization
dt = 10;                 % Set Time interval to 60 seconds     
t = 0: dt :dt * 1678-36;     % Set number of sampling
last_time = dt * 1678-36;

Init_Flag = 0;

Nsamples = length(t);

Estimation = zeros(Nsamples, 3);            % Create 3D Array to store Estimated SOC and V1
EKFVt = zeros(Nsamples, 1);                 % 1D Array to store Predicted Vt
Measurement = zeros(Nsamples, 1);           % 1D Array to store Measured Vt
ActualSOC = zeros(Nsamples, 1);             % 1D Array to store Reference SOC Value
AC_SOC = zeros(Nsamples, 1);                % 1D Array to store SOC Calculated by Amphere Counting
Current_Nominal = zeros(Nsamples, 1);       % 1D Array to store Nominal Charge Current
Current_Noise = zeros(Nsamples, 1);         % 1D Array to store Discharge Current Noise Added

Error_EKF = zeros(Nsamples, 1);
Error_AC = zeros(Nsamples, 1);
Error_Vt = zeros(Nsamples, 1);
Error_Rate = zeros(Nsamples, 3);

%% Estimate SOC While Charging
for k = 1 : Nsamples
    if Init_Flag == 0
        % Conduct Initialization
        Cell_Data = Init_Cell(Case, dt);               % Assign 11 Variables

        % Assign Initial State Variable Value : Added V2
        Estimation(k, :) = [Cell_Data.SOC_Initial Cell_Data.V1_Initial Cell_Data.V2_Initial];    
        ActualSOC(k) = Cell_Data.SOC_Initial;           % Save Initial SOC
        AC_SOC(k) = Cell_Data.SOC_Initial;              % Assign Amphere Counting`s Initial SOC 
        EKFVt(k) = Charge_Data_0_2C_10s(1+36);              % Assign Predicted Vt`s Initial Value
        Measurement(k) = Charge_Data_0_2C_10s(1+36);        % Assign Measured Vt`s Initial Value
        
        Init_Flag = 1;
    
    else
        Temp = GetExperData(k, Cell_Data, dt, Case);           % Get Cell`s Discharge Experimental Data
        Cell_Data.Vt = Temp.Vt;
        Cell_Data.V1 = Temp.V1;
        Cell_Data.V2 = Temp.V2;
        Cell_Data.ik_noise = Temp.ik_noise;
        Cell_Data.ik_before = Temp.ik_before;
        Cell_Data.esti_init = Temp.esti_init;

        % Estimate SOC and V1 after giving Measured Vt to EKF
        [SOC_k, V1_k, V2_k] = SOCEKF(Cell_Data, dt, Case);
        Estimation(k, :) = [SOC_k V1_k V2_k];     % Save Estimated SOC and V1 by EKF
        
        % Save Calculated SOC by Amphere Counting which will be used as
        % Reference Value
        ActualSOC(k) = Amphere_Counting(ActualSOC(k-1), dt, Cell_Data, Cell_Data.ik_nominal);
        AC_SOC(k) = Amphere_Counting(AC_SOC(k-1), dt, Cell_Data, Cell_Data.ik_noise);
        EKFVt(k) = hx(Cell_Data, SOC_k, Case);          % Save Predicted Vt
        Measurement(k) = Cell_Data.Vt;           % Save Measured Vt
        Current_Noise(k) = Cell_Data.ik_noise;
        Current_Nominal(k) = Cell_Data.ik_nominal;

        Error_EKF(k) = ActualSOC(k) - Estimation(k,1);
        Error_AC(k) = ActualSOC(k) - AC_SOC(k);
        Error_Vt(k) = Measurement(k) - EKFVt(k); 

        Error_Rate(k,1) = (ActualSOC(k) - Estimation(k,1)) / ActualSOC(k) * 100;  % EKF Error Rate
        Error_Rate(k,2) = (ActualSOC(k) - AC_SOC(k)) /  ActualSOC(k) * 100;       % AC Error Rate
        Error_Rate(k,3) = (Measurement(k) - EKFVt(k)) / Measurement(k) * 100;     % Vt Error Rate
    end
end

SOCSaved = Estimation(:,1);
V1Saved = Estimation(:,2);
Vt_RMSE = rmse(Measurement, EKFVt);
EKF_RMSE = rmse(ActualSOC, SOCSaved)
Amphere_Counting_RMSE = rmse(ActualSOC, AC_SOC)
Current_RMSE = rmse(Cell_Data.ik_noise, Cell_Data.ik_nominal)

% % toc
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

