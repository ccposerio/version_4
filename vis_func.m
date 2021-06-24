%plots the solution only value of 1 or zero
clc,clear


%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler24(1);
%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler24(2);
[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler48(3);
%[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler48(4);

x =1:t;

app1 = solution(1,:);
app2 = solution(2,:);
app3 = solution(3,:);
app4 = solution(4,:);
app5 = solution(5,:);
app6 = solution(6,:);
app7 = solution(7,:);
app8 = solution(8,:);
app9 = solution(9,:);

tiledlayout(9,1);

bar1 =nexttile;
bar(bar1,x, app1);
title(bar1, 'Appliance 1 Consumption');

bar2 =nexttile;
bar(bar2, x, app2);
title(bar2, 'Appliance 2 Consumption');

bar3 =nexttile;
bar(bar3, x, app3);
title(bar3, 'Appliance 3 Consumption');

bar4 =nexttile;
bar(bar4, x, app4);
title(bar4, 'Appliance 4 Consumption');

bar5 =nexttile;
bar(bar5, x, app5);
title(bar5, 'Appliance 5 Consumption');

bar6 =nexttile;
bar(bar6, x, app6);
title(bar6, 'Appliance 6 Consumption');

bar7 =nexttile;
bar(bar7, x, app7);
title(bar7, 'Appliance 7 Consumption');

bar8 =nexttile;
bar(bar8, x, app8);
title(bar8, 'Appliance 8 Consumption');

bar9 =nexttile;
bar(bar9, x, app9);
title(bar9, 'Appliance 9 Consumption');