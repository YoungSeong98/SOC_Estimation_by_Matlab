%% This function Calculates Linearized Measurement Matrix H

function H_k = Hk(SOC_predic, SOC_before, Case)

% Substitute Predicted SOC and Estimated SOC in Last Step to variable

if SOC_predic >= 100
    SOC_predic = 100;
elseif SOC_predic <= 0
    SOC_predic = 0;
end

% Assign Corresponding OCV using OCV-SOC LUT
OCV_LUT = OCV_SOC_LUT_0_01C(SOC_predic, Case, "OCV");
OCV_LUT_before = OCV_SOC_LUT_0_01C(SOC_before, Case, "OCV");

% Calculate OCV-SOC LUT`s Slope at Predicted SOC
H_k = [(OCV_LUT - OCV_LUT_before) / (SOC_predic - SOC_before) -1];

% Check if the Present SOC and Previous SOC is Same to Prevent H from becoming Nan
if SOC_predic == SOC_before
    H_k = [0 -1];
end