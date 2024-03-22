
CHG_EKF_RMSE = [0.071423951
0.124164282
0.073172548
0.300009363
0.182661484
0.237339298
0.155963265
0.111810472
0.074975425
0.292698592
0.108481201
0.20963807
0.072437565
0.150705888
0.172325257
0.188775427
0.15932412
0.097458497
0.082920353
0.194271915
];

CHG_AC_RMSE=[0.079729637
0.117609172
0.079255656
0.312815146
0.171770994
0.224621336
0.143511299
0.103598329
0.079808302
0.283302461
0.112974432
0.196108282
0.077904693
0.140304288
0.159905472
0.177594903
0.150877351
0.107437965
0.091652166
0.182454036
];

DHG_EKF_RMSE = [0.073941739
0.162111144
0.226342528
0.084069272
0.15442475
0.131444901
0.103382498
0.133807569
0.101239417
0.034009435
0.136961427
0.098215691
0.158425138
0.157496839
0.193657978
0.077624669
0.052416762
0.055301858
0.073909195
0.110623439
];

DHG_AC_RMSE=[0.05850169
0.141693682
0.246761972
0.10374424
0.141186476
0.110453274
0.118864979
0.152624566
0.119529319
0.033030221
0.154533554
0.079826798
0.178196979
0.139074085
0.211173195
0.069816245
0.056502775
0.053429227
0.085619424
0.127613167
];

% n = length(CHG_AC_RMSE);
% for k = 1 : n
%     Diff_CHG_RMSE(k) = CHG_AC_RMSE(k) - CHG_EKF_RMSE(k);
% end
% 
% subplot(2,1,1)
% hold on
% plot(CHG_EKF_RMSE, 'r')
% plot(CHG_AC_RMSE, 'b')
% legend("EKF RMSE", "Amphere Counting RMSE")
% xlim([1 20])
% 
% subplot(2,1,2)
% plot(Diff_CHG_RMSE)
% legend("RMSE Difference")
% xlim([1 20])

n = length(DHG_AC_RMSE);
for k = 1 : n
    Diff_DHG_RMSE(k) = DHG_AC_RMSE(k) - DHG_EKF_RMSE(k);
end

subplot(2,1,1)
hold on
plot(DHG_EKF_RMSE, 'r')
plot(DHG_AC_RMSE, 'b')
legend("EKF RMSE", "Amphere Counting RMSE")
xlim([1 20])

subplot(2,1,2)
plot(Diff_DHG_RMSE)
legend("RMSE Difference")
xlim([1 20])
