function [dydt] = SolverFunction(Time,Conc,K,ODEStringVector)

dydt = zeros(size(Conc));

ConcentrationAlphabet = 'ABCDEFGHIJK';

for i = 1:size(Conc,1)
eval(sprintf('%s = Conc(i);',ConcentrationAlphabet(i)))

end

for i = 1:size(Conc,1)
    CurrentODE = char(ODEStringVector{i});
    CurrentODE = [CurrentODE,';'];
    eval(CurrentODE);
end

end