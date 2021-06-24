%% determines the battery operation at given t
function [BattCharge,batteryoperation] = batop(BattCharge,t,appsched,appwatt, PVsched, MaxBattCharge, MinBattCharge, HighThresh, LowThresh)

%%for easy checking if code works
%clc,clear
%t=5;
%appsched= [1,0,1,0,1; 0,0,0,1,1];
%appwatt = [20;10];
%PVsched = [0,50,50,50,0];
%MaxBattCharge = 100;
%MinBattCharge = 0;
%HighThresh = 80;
%LowThresh = 20;
%BattCharge= 0;

%batteryoperation=zeros(1,t);
tempvar = appsched.*appwatt;
appenergy = sum(tempvar,1);
imbalance = PVsched-appenergy;

for a=1:t
  if (HighThresh<BattCharge)&&(BattCharge<=MaxBattCharge);
    if (imbalance(a)>0);
        [BattCharge, batteryoperation(a)] = charging(BattCharge,imbalance(a),MaxBattCharge);          %% charging
    elseif (imbalance(a)<0);
        [BattCharge, batteryoperation(a)] = discharging(BattCharge,imbalance(a),MinBattCharge,MaxBattCharge); %%discharging 
    elseif (imbalance(a)==0) ;
           batteryoperation(a)= 0;
    end
     
 elseif (LowThresh<BattCharge)&&(BattCharge<=HighThresh);
    if (imbalance(a)>0);
         [BattCharge, batteryoperation(a)] = charging(BattCharge,imbalance(a),MaxBattCharge);          %% charging
    elseif (imbalance(a)<0);
        [BattCharge, batteryoperation(a)] = discharging(BattCharge,imbalance(a),MinBattCharge,MaxBattCharge); %%discharging 
    else (imbalance(a)==0)     ;
          batteryoperation(a)= 0;
    end
 else (BattCharge<=LowThresh);
    if (imbalance(a)>0);
     [BattCharge, batteryoperation(a)] = charging(BattCharge,imbalance(a),MaxBattCharge);          %% charging
    elseif (imbalance(a)<0);
        batteryoperation(a)= 0;
    elseif (imbalance(a)==0)  ;
        batteryoperation(a)= 0;
    end
     
end
end
end

