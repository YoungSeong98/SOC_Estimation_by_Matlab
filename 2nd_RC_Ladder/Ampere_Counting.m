% This code Estimates SOC by Amphere Counting
% Calculated SOC in this function will be used as Reference SOC Value

function SOC = Amphere_Counting(SOC_before, dt, Cell_Data, ik)

SOC = SOC_before - Cell_Data.coulomb_effi * dt * ik/Cell_Data.Cn;
