function [Vinf1,Vinf2] = VinfVectorFunc(State1,State2,Date1,Date2,TOF)
% Function to simplify data generation for interplanetary transfers:
% Inputs:
%   - State1: state vector for departure planet
%   - State2: state vector for arrival planet
%   - Date1: date vector for departure dates
%   - Date2: date vector for arrival dates
%   - TOF: time of flight vector (s)
% Outputs:
%   - Vinf1: vector and magnitude for departure Vinfs
%   - Vinf2: vector and magnitude for arrival Vinfs

Vinf1 = NaN(length(Date1),length(Date2),4);
Vinf2 = NaN(length(Date1),length(Date2),4);

startTime = toc;
for i = 1:length(Date1)
    for j = 1:length(TOF)
        [V1,V2,~]  = GaussProblemUVF(State1(i,:),State2(i+j-1,:),TOF(j));
        % X,Y,Z Vinf componenents
        Vinf1(i,i+j-1,1:3) = V1 - State1(i,4:6);
        Vinf2(i,i+j-1,1:3) = V2 - State2(i+j-1,4:6);
        % Vinf magnitude
        Vinf1(i,i+j-1,4) = sqrt(Vinf1(i,i+j-1,1)^2+Vinf1(i,i+j-1,2)^2+Vinf1(i,i+j-1,3)^2);
        Vinf2(i,i+j-1,4) = sqrt(Vinf2(i,i+j-1,1)^2+Vinf2(i,i+j-1,2)^2+Vinf2(i,i+j-1,3)^2);
    end
    % Report Progress:
    fprintf('Progress:\n %.4f %%\n',i/length(Date1)*100);
    fprintf('Time Elapsed (mins):\n %.4f \n',(toc-startTime)/60);
    fprintf('Time Remaining Estimate (mins):\n %.4f \n',(toc-startTime)/(i/length(Date1))/60-(toc-startTime)/60);
    fprintf('Total Time Estimate (mins):\n %.4f \n',(toc-startTime)/(i/length(Date1))/60);
end

end