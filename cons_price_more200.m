%  Constant Price Rate for houses greater than 200 kW
function price_rate = cons_price_more200(t)
%Jan-Jun(Dry)P8.9453 kW/h
%Jul-Dec(Wet)P8.5254

    Pr1=0.0089453;
    Pr2=0.0085254;
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