%charging function used in batop

function [NewBattCharge, EnergyCharged]=charging(BattCharge, imbalance, MaxBattCap)

if abs(imbalance)>MaxBattCap
    NewBattCharge= BattCharge+MaxBattCap;
else
    NewBattCharge= BattCharge+abs(imbalance);
end

if (NewBattCharge>MaxBattCap)
   NewBattCharge=MaxBattCap;
end

EnergyCharged = NewBattCharge-BattCharge;
return