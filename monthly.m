 %% used to display the monthly savings of the household
clc,clear

[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler24(1);
%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler24(2);
%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler48(3);
%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]=scheduler48(4);
    
Batt__Charge=0;
ctr = 30;
 solution30 = zeros(ctr,t);
PV30 = zeros(ctr,t);        
    
batoperation = zeros(ctr,t);
solsum = sum(solution.*app_TW);
imbalance = PV-solsum;


for (a=1:ctr)
solution30(a,:) = solsum;
PV30(a,:) = PV;
[Batt__Charge,batoperation(a,:)] = batop(Batt__Charge,t,solution,app_TW, PV, MaxBattCharge, MinBattCharge, HighThresh, LowThresh);
end
        
TW_consumed = sum(solution30,"all");

Singhouse_netLoad = sum(solution30,1)-sum(PV30,1) + sum(batoperation,1); %gets net wattage consumed per hr

NetLoadTot = sum(Singhouse_netLoad,"all");
Singhouse_CostBat= zeros(1,t);

for (a=1:t)
Singhouse_CostBat(a) = Singhouse_netLoad(a) * price(price_code,a);    %gets cost of consumed per hr
end

Singhouse_Costs = sum(Singhouse_CostBat);