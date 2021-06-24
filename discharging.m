%discharging function for batop
function  [NewBattCharge, EnergyDischarged]= discharging(BattCharge, imbalance, MinBattCap, MaxBattCap)

if abs(imbalance)>MaxBattCap
    NewBattCharge= BattCharge-MaxBattCap;
else
    NewBattCharge= BattCharge-abs(imbalance);    
end

if (NewBattCharge<MinBattCap)
    NewBattCharge = MinBattCap;
end

EnergyDischarged = NewBattCharge -BattCharge;

return