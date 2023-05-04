clear all

% Enter string equations
M{1} = ''
M{2} = ''

%Define a variable for the number of reactions 
Reactions = size(M,2);

ReactionAlphabet = 'ABCDEFGHIJK';
%Define stoichiometry
ReactionStoichiometry = zeros(Reactions,size(ReactionAlphabet,2));

%Make each string equation into a horizontal vector
for i = 1:Reactions
    CurrentReaction = M{i};

    %Find the string position where the starting materials are to the left
    %of the arrow, and the products are to the right
    for j = 1:length(CurrentReaction)
        if CurrentReaction(j) == '-'
            ReactionDivider = j;
        end
    end

    CurrentSM = CurrentReaction(1:ReactionDivider-1); %Current starting materials
    CurrentP = CurrentReaction(ReactionDivider+2:end); %Current products

    %Loop through the current alphabet to find these letters in the
    %starting materials and then in the products
    for jj = 1:length(ReactionAlphabet)
        CurrentAlphabet = ReactionAlphabet(jj);

        NumberOfOccurances = findstr(CurrentAlphabet,CurrentSM); %Number of times this species is a starting material in the same reaction (could be A + x -> products, or A + A -> products, etc.)
        if ~isempty(NumberOfOccurances) %If this is not empty, or, if there ARE occurances of this species
            CurrentAlphabetStoichiometry = size(NumberOfOccurances,2); %Find how many times this species is a starting material
            ReactionStoichiometry(i,jj) = -CurrentAlphabetStoichiometry; %populate this as a reactant in the stoichiometry matrix
        end

        NumberOfOccurances = []; %delete this value in between different 'if' statements

        NumberOfOccurances = findstr(CurrentAlphabet,CurrentP); %Number of times this species is a product in the same reaction
        if ~isempty(NumberOfOccurances) %If this is not empty, or, if there ARE occurances of this species
            CurrentAlphabetStoichiometry = size(NumberOfOccurances,2); %Find how many times this species is a product
            ReactionStoichiometry(i,jj) = +CurrentAlphabetStoichiometry; %populate this as a product in the stoichiometry matrix
        end

        NumberOfOccurances = []; %delete this value in between different 'if' statements

    end
end


%First step: define reactions in a matrix and then move this into ODEs

%create equation for each species
CurrentSpecies = [];
%define ODEStringVector  which will collect ODEStrings
ODEStringVector = [];

for i = 1:Reactions
    CurrentStoichiometry = ReactionStoichiometry(i,:);
    CurrentReactants = find(CurrentStoichiometry<0);
    NumberofReactants = size(CurrentReactants,2);
    
    for j = 1:NumberofReactants
        Reactants(j) = CurrentReactants(j);
    end
    CurrentProducts = find(CurrentStoichiometry>0);
    NumberofProducts = size(CurrentProducts,2);
    for k = 1:NumberofProducts
        Products(k) = CurrentProducts(k);
    end
    CurrentSpecies = [CurrentSpecies,Reactants,Products];
end


%assign equations for each species
for i = CurrentSpecies
    EquationString{i} = sprintf('dydt(%d) = ',i);
    ODEStringVector{i} = EquationString{i};
end

%loop through reactions to create reaction chunks and for each, adding them
%to the ODEString for the relevant species each time
for i = 1:Reactions
CurrentStoichiometry = ReactionStoichiometry(i,:);
CurrentReactants = find(CurrentStoichiometry<0);
CurrentProducts = find(CurrentStoichiometry>0);

RateConstant = sprintf('K(%d)',i);

NumberofReactants = size(CurrentReactants,2);
NumberofProducts = size(CurrentProducts,2);
NumberofSpecies = size(unique(CurrentSpecies));

ReactionChunk = RateConstant;

for j = 1:NumberofReactants
    CURRENTReactantIndex = CurrentReactants(j);
    CURRENTReactant = ReactionAlphabet(CURRENTReactantIndex);
    ReactionChunk = strcat([ReactionChunk,'*',CURRENTReactant]);
end

for j = 1:NumberofReactants
CURRENTReactantIndex = CurrentReactants(j);
ODEStringVector{CURRENTReactantIndex} = strcat([ODEStringVector{CURRENTReactantIndex},'-',ReactionChunk]);
end

for jj = 1:NumberofProducts
    CURRENTProductIndex = CurrentProducts(jj);
    CURRENTProduct = ReactionAlphabet(CURRENTProductIndex);

ODEStringVector{CURRENTProductIndex} = strcat([ODEStringVector{CURRENTProductIndex},'+',ReactionChunk]);

end




end