% This Function Predicts Present Step`s State Variables by Non Linear State Equation

function x = fx(xk_before, dt, Cell_Data)

A = [1 0;
     0 exp(-dt / (Cell_Data.R1 * Cell_Data.C1))];
B = [-Cell_Data.coulomb_effi*dt/Cell_Data.Cn; 
      Cell_Data.R1*(1-exp(-dt/(Cell_Data.R1*Cell_Data.C1)))];

x = A * xk_before + B * Cell_Data.ik_noise;
% x = A * xk_before + B * Cell_Data.ik_nominal;


