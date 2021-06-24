%  Constant Price Rate for houses less than 200 kW
function price_rate = cons_price_less200(t)
%Jan-Jun(Dry)P5.69 kW/h
%Jul-Dec(Wet)P5.57

    Pr1=0.00569; 
    Pr2=0.00557; 

    
    price_rate=zeros(2,t);

    for a=1:2 %1=dry,2=wet
        for b=1:t
            if a==1
                price_rate(a,b)=Pr1;
            elseif a==2
                price_rate(a,b)=Pr2;
            end
        end
    end
end