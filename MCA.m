function MonteCarlo = MCA(MCA_count)
%%
%%MCA_count = 1;

MonteCarlo = zeros(MCA_count, 1);
%probabilities: 
% house of 1: 3.3%      - 1
% house of 2-3: 15.0%   - 2 
% house of 4-5: 54.2%   - 3 
% house of 6+: 27.7%    - 4
    pd = makedist('PiecewiseLinear', 'x', [ 1 2 3], 'Fx', [0 0.183 1]);
    for a=1:MCA_count
        MonteCarlo(a) = fix(random(pd));
    end
end
