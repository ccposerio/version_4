% Constant peak demand threshold

function peak_thresh = cons_peak(t)

cons_thresh_dry = 1200;
cons_thresh_wet = 1000;
peak_thresh = zeros(2,t); % buffer

for a=1:2 % 1=Dry, 2=Wet
    for b=1:t
        if (a==1)
            peak_thresh(a,b) = cons_thresh_dry;
        else
            peak_thresh(a,b) = cons_thresh_wet;
        end
    end
end

end