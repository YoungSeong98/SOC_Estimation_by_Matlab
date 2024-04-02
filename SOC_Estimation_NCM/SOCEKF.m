% This Function Receives Measured Vt and Time interval as input
% And returns EKF process output

function [SOC_k, V1_k] = SOCEKF(Cell_Data, dt, Case)
persistent F Q R P H K P_before
persistent x_esti x_esti_before Init_EKF

if isempty(Init_EKF)
    F = [1 0;                       % Linearized State Equation
         0 exp(-dt/(Cell_Data.R1 * Cell_Data.C1))];

    if Case == "CHG"
        Q = [0.0000001 0;           % System Noise. Estimation Value`s Variance Increases if Q Increased
              0 0.0000001];               

        R = 8000.0;                 % Measurement Noise
    
        P_before = [3000 0;
                    0 3000];        % Estimation Error Covariance

        % P_before = 1 * eye(2);
    elseif Case == "DHG"
        Q = [0.000001 0;            % System Noise
              0 0.000001];               

        R = 8000.0;                 % Measurement Noise
    
        P_before = [5000 0;
                    0 5000];        % Estimation Error Covariance
    end
        % Initialize State Variable
        x_esti_before = Cell_Data.esti_init';

    Init_EKF = 1;
end

%% Extended Kalman Filter Process
% Predict Step
x_predic = fx(x_esti_before, dt, Cell_Data);
P_predic = F * P_before * F' + Q;

% Get Linearized Measurement Matrix H
H = Hk(x_predic(1), x_esti_before(1), Case);

% Update Step
K = P_predic * H' / (H * P_predic * H' + R);

x_esti = x_predic + K * (Cell_Data.Vt - hx(Cell_Data, x_predic(1), Case));
P = P_predic - K * H * P_predic;

SOC_k = x_esti(1);
V1_k = x_esti(2);

x_esti_before = x_esti;
P_before = P;
