 %% used to display the monthly savings of the household
clc,clear

%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler24(1);
%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler24(2);
%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler48(3);
[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]=scheduler48(4);
    
Batt__Charge=0;   
    
batoperation = zeros(n,t);
solsum = sum(solution.*app_TW);
imbalance = PV-solsum;

%[Batt__Charge,batoperation] = batop(Batt__Charge,t,solution,app_TW, PV, MaxBattCharge, MinBattCharge, HighThresh, LowThresh);

Singhouse_netLoad = sum(solsum,1)-sum(PV,1) + sum(batoperation,1); %gets net wattage consumed per hr
