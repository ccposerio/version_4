%  Constant Buying Price Rate f the utility for houses greater than 200 kW

function price_rate = price_buying(t)
Pr1 = 0.0046;

for a=1 %1
        for b=1:t
            if a==1
                price_rate(a,b)=Pr1;
                  end
        end
    end



end