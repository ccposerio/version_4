function[n,t,solution,MaxBattCharge,MinBattCharge,HighThresh,LowThresh,PV,app_TW,price,price_code]= scheduler48(Monte)

t=48; 
num=1 ;  % num = number of households in a community

AllHouse_netLoad = zeros(1,t);  %net Load Profile of whole community
AllHouse_netCost = zeros(1,t);  %net Cost of whole community
AllHouse_Savings = 0;   %savings of whole community
Monte =3;
for a=1:num
    input(a,2)="housePV.m";
    input(a,1)=Monte(a);
    %matrix input:
    % [1 house.m; 2 house.m]
    % to follow filename per house type
end
MCAin = join(input, "_");   %MCAin contains filenames in strings ex. ["4_house.m" "1_house.m"...]
%% START RUN FOR COMMUNITY
for count=1:num
    %% START RUN FOR SINGLE HOUSEHOLD
    clear('data');
    load_perApp_perHr = zeros(1,t);
    filename=MCAin(count) % to know kung anong house type na
    count;   %to know kung pang ilan nang MCA house
    data = load(filename);
    %%  IMPORT INPUT DATA
        t=48;
        user_budget=75;
        peak_threshold= cons_peak(t);  
        peak_code=1; 
        
        %Parsing input data
            [row_len,col_len]=size(data);
            %counts number of appliances
            n=max(data(:,1));
            %counts number of usage per appliance
            app_usage=zeros(n,1);
 
            for a = 1:n  
                temp = find(data(:,1)==a);
                app_usage(a) = size(temp,1);
            end  
          
			temp = find(data(:,1)==0);     %number of photovoltaic cells
            m = size(temp,1);   % m = number of inputted pv cells
            PV = zeros(m,t);    %wattage production of photovoltaic cells
 
            mu=max(app_usage);
            app_tA=zeros(n,mu);
            app_tB=zeros(n,mu);
            app_TW=zeros(n,1);
            

            
            
            %total wattage, duration, tA, tB
            use=0;
            pv_ctr=0;
            for a=1:row_len
                if (data(a,1)==10)
                    MaxBattCharge = data(a,2);
                    HighThresh = data(a,3);
                    LowThresh = data(a,4);
                    MinBattCharge=data(a,5);
                    
                elseif (data(a,1)==0)
                    pv_ctr=pv_ctr+1;
                    for c=0:(data(a,3)-1)
                        PV(pv_ctr,(data(a,4)+c)) = data(a,2);   %PV contains total wattage per hour per declared panel
                    end 
                elseif(data(a,1)<10) && ( data(a,1)>0);
                    app_TW(data(a,1),1)=data(a,2);      %%data(a,1)=appNo.; data(a,2)=TW
                    use=use+1;
                    if use<=app_usage(data(a,1))
                        app_dur(data(a,1),use)=data(a,3);
                        app_tA(data(a,1),use)=data(a,4);
                        app_tA(data(a,1),use)=data(a,4);
                        app_tB(data(a,1),use)=data(a,5);
                        if use==app_usage(data(a,1))
                            use=0;
                        end
                    end 
                end 
            end

        n=max(data(:,1))-1;    
       
        
		tot_prod=zeros(1,t);    % total wattage production of ALL photovoltaic cells per hour
        for b=1:t
            tot_prod(b) = sum(PV(:,b)); %total wattage production of the household per hour
        end
	
		
      app_TW(10,:)=[];    
      %app_dur([10],:)=[];
      app_tA([10],:)=[];
      app_tB([10],:)=[];
      app_usage([10],:)=[];
        
        
    %%  INITIALIZATION OF PARAMETERS
        N=500;  %Number of particles
        dim=n*t;    %dimension of a particle in a single row
        
        c1=9;                     
        c2=9; 
        v_max=6; 
        
        validctr=0; %counts valid scheds produced per run (at most 5)
        valid_fitness = []; %contains fitness of all valid scheds produced by sims
    %%  PSO PROGRAM
    max_iteration=500;
    simulations=5; 
    checkd=zeros(1,simulations);%number of appliances with right duration in one simulation
    checki=zeros(1,simulations);%number of appliances with right interruption in one simulation
    minfit_per_ite=zeros(max_iteration,simulations);
    sol_per_run=zeros(simulations,dim);
   
    for run=1:simulations
            itectr=0;
        %Allocations
            sig=zeros(N,dim);
            solution=zeros(n,t);
            fitness=zeros(N,1);
            pbest=ones(N,dim);
            gbest=ones(1,dim);
            pbest_fitness=ones(N,1);
        %Initial position and velocity
            sched=round(rand(N,dim));%initial position
            v=round(-v_max+(rand(N,dim)*(2*v_max)));%initial velocity

        %Start of PSO Algorithm
            while itectr<max_iteration

                itectr=itectr+1;
                w=1;%inertia weight

                %Evaluation of Fitness
                for a=1:N       %do for all N particles
                    for b=1:n       %do for all n appliances
                        solution(b,:)=sched(a,(b-1)*t+1:b*t);                      %rearranges every row(particle) of swarm to its own matrix
                    end
                   %detemine pricing scheme to be used
                   
                   
    if (Monte==3);
       price=cons_price_less200(t); %% pricing for consumed power less than 200kW
       %price=tou_rates48(t);
       price_code=1;
       batoperation = zeros(1,t);
       BattCharge=0;
      [BattCharge,batoperation] = batop(BattCharge,t, solution, app_TW, PV,MaxBattCharge,MinBattCharge, HighThresh, LowThresh);
    
    else (Monte==4);
        BattCharge=0;
        batoperation = zeros(1,t);
       [~,batoperation] = batop(BattCharge,t, solution, app_TW, PV,MaxBattCharge,MinBattCharge, HighThresh, LowThresh);
        tempvar=solution.*app_TW;
        sum1 = sum(tempvar,'all') + sum(batoperation,'all') -sum(PV, 'all');
        if (sum1<0);
            price = price_buying(t);
            price_code=1;
        elseif(sum1>0);
           price=cons_price_more200(t);
           %price=tou_rates48(t); 
            price_code=1; 
        else(sum1==0);
           price=cons_price_more200(t); 
           %price=tou_rates48(t);
            price_code=1; 
        end
    end
    
    fitness(a,itectr)=objFunc(n, t, solution, price(price_code,:), app_usage, app_TW, app_dur, app_tA, app_tB, user_budget, peak_threshold(peak_code,:), mu, tot_prod,batoperation);
                end

                %Updating Pbest
                for a=1:N       %do for all N particles
                    if itectr==1 || fitness(a,itectr) < pbest_fitness(a,1);
                        pbest_fitness(a,1)=fitness(a,itectr);
                        pbest(a,:)=sched(a,:);
                    end
                end

                %Updating Gbest
                [fmin, fmin_index]=min(pbest_fitness);                         %finds best particle                                 
                minfit_per_ite(itectr,run)=fmin;                              %stores gbest value per iteration on every run
                if itectr==1 || fmin < gbest_fitness ;                          
                    gbest_fitness=fmin;
                    gbest=pbest(fmin_index,:);
                end

                %Updating Velocity
                for a=1:N       %do for all N particles
                    for b=1:dim         %do for all n*t units
                        v(a,b)=w*v(a,b)+(c1*rand()*(pbest(a,b)-sched(a,b)))...
                        +(c2*rand()*(gbest(1,b)-sched(a,b)));
                        if v(a,b)>v_max  ;                                      %limiting velocity within [-v_max,v_max]
                            v(a,b)=v_max;
                        elseif v(a,b)<-v_max;
                            v(a,b)=-v_max;
                        end
                    end
                end

                %Sig function and Updating Position
                for a=1:N
                    for b=1:dim
                        sig(a,b)=1/(1+exp(-v(a,b)));
                        if sig(a,b)>rand();
                            sched(a,b)=1;
                        elseif sig(a,b)<rand();
                            sched(a,b)=0;
                        end
                    end
                end

            end         % End of one BPSO simulation

            run
            sol_per_run(run,:)=gbest;       %solution per run (max_iteration iterations or cycles)
            
            %Constructs the matrix of the latest global best
            for a=1:n       %do for all n appliances 
                solution(a,:)=gbest(1,(a-1)*t+1:a*t);
                on_times=sum(diff([0 solution(a,:)])==1);
                if sum(solution(a,:))==sum(app_dur(a,:))  ;  %checks per appliance if preferred duration is met      
                    checkd(1,run)=checkd(1,run)+1; 
                end
                if on_times==app_usage(a) ; %checks per appliance if usage has no interruption
                    checki(1,run)=checki(1,run)+1;
                end
            end
            %Checks if duration of operation and on times is met to be VALID!
            if checkd(1,run)==n && checki(1,run)==n;
                validctr=validctr+1;
                valid_fitness = [valid_fitness; gbest_fitness]; %stores global best value since sched is valid
            end
            
            %NOTE: sometimes best fitness is not a valid schedule
    end
    %%
            % Validity or Fitness Check (if no valid sched, solution = fittest for all)
            if validctr > 0;
                % Validity
                fittest = min(valid_fitness);
                [row, col] = find( minfit_per_ite(max_iteration,:) == fittest );
                fittest_index = col;  
            elseif validctr == 0;
                % Fitness 
                [fittest, fittest_index]=min(minfit_per_ite(max_iteration,:));
            end
            %if walang valid, solution = may pinakamababang fitness
         
            for a=1:n 
                solution(a,:)=sol_per_run(fittest_index,(a-1)*t+1:a*t);
            end
            
            %DONE 1RUN / 5SIMS / 1HOUSE
            %collate answers for whole community
               
                   
end        
%end
