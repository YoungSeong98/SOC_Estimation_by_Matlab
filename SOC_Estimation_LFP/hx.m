% This function Predicts Vt by Predicted State Variable and OCV-SOC LUT

function z_predict = hx(Cell_Data, SOC, Case)

% SOC = round(x_predic(1));       % Substitute Predicted SOC to variable

if SOC >= 100
    SOC = 100;
elseif SOC <= 0
    SOC = 0;
end

OCV_LUT = OCV_SOC_LUT_0_01C(SOC, Case, "OCV");

z_predict = OCV_LUT - Cell_Data.V1 - Cell_Data.R0 * Cell_Data.ik_noise;
% z_predict = OCV_LUT - Cell_Data.V1 - Cell_Data.R0 * Cell_Data.ik_nominal;

