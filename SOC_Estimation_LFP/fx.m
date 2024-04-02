% This Function Predicts Present Step`s State Variables by Non Linear State Equation

function x = fx(xk_before, dt, Exper_Data)

A = [1 0;
     0 exp(-dt / (Exper_Data.R1 * Exper_Data.C1))];
B = [-Exper_Data.coulomb_effi*dt/Exper_Data.Cn; 
      Exper_Data.R1*(1-exp(-dt/(Exper_Data.R1*Exper_Data.C1)))];

x = A * xk_before + B * Exper_Data.ik_noise;
% x = A * xk_before + B * Exper_Data.ik_nominal;