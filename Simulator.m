clear all
ODEGenerator;

%define intended bounds
Temp = [20,50];
ReactionTime = [0,60];

MaxTemp = max(Temp);
MaxReactionTime = max(ReactionTime);

%predefine what data will look like, where column 1 is temp, column 2 is
%reaction time, column 3 is final concentration
AllData = zeros(100,3);

%easiest way to track number of data points across multiple loops,
%represents current data point and is changed in each loop to populate
%'AllData' efficiently
Counter = 1;

%To simulate the reaction
for i = 1:2:MaxTemp
    Temp = i;
    Temp = Temp + 273.15;


    for j = 1:2:MaxReactionTime
        ReactionTime = j;
     
    TempRef = [75+273.15];

    RefK(1) = 0.00927;
    Ea(1) = 87.1;
    RefK(2) = 0.0000363;
    Ea(2) = 74.5;

    for k = 1:Reactions
        K(k) = RefK(k)*exp((-Ea(k)/8.314)*((1/Temp)-(1/TempRef)));
    end
   %}

    Conc = [0.1 0.08 0 0];%inital concentrations in mol
    Time = [0 ReactionTime];%in minutes

    %run ODE solver
    options = odeset('Nonnegative',1);
    [TimeData,ConcData] = ode15s(@(Time,Conc)SolverFunction(Time,Conc,K,ODEStringVector),Time,Conc,ODEStringVector);

    %define reaction end point
    EndPoint = ConcData(end,3);

    %populate data table with this information
    AllData(Counter,:) = [Temp,ReactionTime,EndPoint];

    %add to counter to increment data point for next time
    Counter = Counter + 1

    
end
end

%convert to % yield
Conc(Conc == 0) =inf;
SMConc = min(Conc);
AllData(:,3) = AllData(:,3) / SMConc * 100;

%create reactivity plot
scatter(AllData(:,1),AllData(:,2),[],AllData(:,3))
hold on
colorbar
xlabel('Temperature /Kelvin')
ylabel('Reaction time /min')
a = colorbar
a.Label.String = '% Yield'

%create kinetc plot
plot(TimeData,ConcData)
hold on
xlabel('Time /min')
ylabel('Conc /M')
