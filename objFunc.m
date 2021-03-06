% objectivefunction for t = 24
function OF = objFunc(n, t, sched, price, usage, tw, duration, tA, tB, budget, peak, mu, PV, batop)
%     n = number of appliances
%     m = number of photovoltaic cells
%     t = number of hours per day
%     mu = maximum appliance usage
%     sched = n x t matrix 
%     price = 1 x t matrix
%     usage,tw = n x 1 matrix (per appliance)
%     duration, tA, tB = n x mu(per appliance)
%     budget, peak = constant
%     PV = m x t matrix 

     % EDIT
%    clc;
%    clear;
%    sched = [1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1;
%             0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0];
%    t=24;
%    sched = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0;
%             0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
%             0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,0;
%             0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0;
%             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0;
%             0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0;
%             0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
%             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0;
%             0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1];
%    price=tou_rates24(t); 
%    PV =    [0 0 0 0 0 0 0 0 0 50 50 50 50 50 0 0 0 0 0 0 0 0 0 0 ];
%    n=9;
%    mu=3;
%    usage = [1;2;3;3;1;2;1;1;1];
%    tw = [16;56;72;96;999;396;252;300;150;50];
%    peak = 1200;
%    budget = 45;
       % EDIT
    
    %penalties or weights   
    P_over=1;   
    P_dissat=1;
    P_bud=1;
    P_int=1;
    P_dur=1;
    
    %normalizing factors
    Mbp = 10;   %budget penalty multiplier
    Mc = 10000; %cost multiplier
    Mop = 100;   %overpeak multiplier
    Mtds = 100000; %dissatisfaction multiplier
    Mint = 10000000;    
    Mdur = 2000000;
    
    %Getting t_start and t_finish of appliance
    t_strt=zeros(n,mu);
    t_fin=zeros(n,mu);
            for a=1:n
                y=diff([0 sched(a,:) 0]);
                k1=find(y==1);
                k2=find(y==-1)-1;
                % IN TTR EDIT
                for b=1:length(k1)
                    t_strt(a,b)=k1(1,b);
                    t_fin(a,b)=k2(1,b);
                end
            end

%     functions:
%         1. cost: check if cost of produce > cost of consume - no negative???
%         2. dissatisfaction: from cueto
%         3. budget:check if budget > cost - no negative???
%         4. consumption: check if thresh > consume-produce - no negative??? OKS 
%         5. interruption penalty
%         6. duration penalty
%% Total Effective Consumption vs Peakthreshold by utility (Watts) %% OVERPEAK
cons = 0;
over_peak = 0;
temp = 0;
    
    for b=1:t   % do for 24 hrs
        for a=1:n   % do for all n appliances
            cons = cons + (sched(a,b) * tw(a));
            temp = 0;
        end
        
        temp = (cons - PV(b))+(batop(b)-peak(b)); %% + BatOp(t) - Peak(b) ##EDITZ
        if temp>0
            over_peak = over_peak + temp;
        end
        cons = 0;
    end
    
    OP = over_peak*P_over*Mop; %-/1000
%% Total Effective Cost (EC) (Peso)%EDITZ
cons_price=0;
prod_price=0;
bat_price=0;
    for b=1:t %%total consumed price of appliances
        for a=1:n
            cons_price = cons_price + (sched(a,b) * tw(a) * price(1,b)); 
        end
    end
    
    for b=1:t %%total power produced by PV 
        prod_price= prod_price + (PV(b) * price(1,b));
    end
    
    %%gawa foR bat
 
    for b=1:t %%total power produced/consumed by battery
    bat_price= bat_price + (batop(b) * price(1,b));
    end
    
    temp = cons_price - prod_price + bat_price; %%+BatOp(t)*price
    
    if temp>0;
        EC = temp*Mc;
        else 
        EC = 0;
    end
%% Total Effective Cost vs Budget (aka Budget Penalty) (Peso) %since ieedit na si EC, no need for editing kay Mc
    temp = EC - (budget*Mc);
    if temp>0;
        BP = (EC - (budget*Mc))*Mbp*P_bud;
    else
        BP = 0;
    end
%% Dissatisfaction function (Unitless) %% don't change
TDS=0;
out_of_bounds=0;
% NOTE: function obtains average satisfaction for all usage times
      for a=1:n     % do for all n appliances
          S=0;
          if isempty(t_fin(a,:)) || isempty(t_strt(a,:))
            S_ave=0;    % 0 if no on time
          else
              for b=1:usage(a)  % do for all usage times
                       if t_fin(a,b)<=tB(a,b) && t_fin(a,b)>=(tA(a,b)+duration(a,b)-1)
                            s_n=(t_fin(a,b)-(tB(a,b)+1))/(tA(a,b)+(duration(a,b)-1)-(tB(a,b)+1));
                       else
                            s_n=0;  % if t_fin is not in preferred range
                            if t_strt(a,b)<tA(a,b)
                                out_of_bounds=out_of_bounds+tA(a,b)-t_strt(a,b);
                            elseif t_fin(a,b)>tB(a,b )
                                out_of_bounds=out_of_bounds+t_fin(a,b)-tB(a,b);
                            end
                       end
                    S=S+s_n;
              end
            S_ave=S/usage(a);   %obtaining average satisfaction
          end
          TDS=TDS+(1-S_ave)+out_of_bounds;  %total dissatisfaction 
      end
        TDS=TDS*P_dissat*1*Mtds; 
%% Interruption Penalty %%don't change
% on_times vs number of usage
TI=0;
        for a=1:n
            on_times=sum(diff([0 sched(a,:)])==1);                         
            I=abs(on_times-usage(a)); 
            TI=TI+(I*P_int*Mint);
        end
%% Duration Penalty %% don't change
TD=0;
    for a=1:n
        D=0;
        on_tot=0;
            for b=1:usage(a)
                on=sum(sched(a,tA(a,b):tB(a,b)));
                on_tot=on_tot+on;
                D=D+abs((on-duration(a,b)));
            end
            d_excess=abs(sum(sched(a,:))-on_tot);
            TD=TD+D+d_excess;
    end
    TD=TD*P_dur*Mdur;
%% Objective Function value
OF = TI+TD+TDS+BP+EC+OP;
end