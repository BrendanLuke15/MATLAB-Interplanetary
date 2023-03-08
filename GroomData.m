function [Vinf_G] = GroomData(Vinf_R,Parameter,Value,LessThan,Leg,other)
% Function to groom "raw" Vinf data:
% Inputs:
%   - Vinf_R: raw Vinf struct
%   - Parameter: metric to filter against
%       - C3 (departure, km^2/s^2 -> [none])
%       - V_Entry (arrival, inertial, km/s -> [mu, R_Planet, h_interface])
%       - dV_t (total, km/s -> [mu1, R_Planet1, h_orb1, mu2, R_Planet2, h_orb2])
%       - dV_d (departure, km/s -> [mu1, R_Planet1, h_orb1])
%       - dV_a (arrival, km/s -> [mu2, R_Planet2, h_orb2])
%       - Reset (all, resets magnitudes -> [none])
%   - Value: value of Parameter to filter against
%   - LessThan: comparison operator boolean -> true is keep "<", false is keep ">"
%   - Leg: leg of trajectory to filter
%   - other: vector of ancilliary information needed for some parameters
%       - see items insude square brackets [] in Parameter input above for what to include
% Outputs:
%   - Vinf_G: groomed Vinf struct (only magnitudes NaN'ed)

% Check valid parameter
valids = {'C3','V_Entry','dV_t','dV_d','dV_a','Reset'}; % valid parameters
if ~any(strcmp(valids,Parameter))
    txt = sprintf("Error: '%s' is not a valid parameter;\n Valid paramters are: '%s' '%s' '%s' '%s' '%s' '%s'\n",Parameter,valids{:});
    error(txt);
end

Vinf_G = Vinf_R; % create output struct

% not all implemented, only C3, V_Entry, & Reset
if strcmp(Parameter,'C3')
    dims = size(Vinf_R.Magnitude{2*Leg-1}); % dimensions of leg 'i'
    Vinf_Mag = Vinf_R.Magnitude{2*Leg-1}; % get accessible Vinf magnitude data
    Vinf_Mag2 = Vinf_R.Magnitude{2*Leg}; % get accessible Vinf magnitude data
    for j = 1:dims(1)
        for k = 1:dims(2)
            if LessThan
                if Vinf_Mag(j,k)^2 > Value
                    Vinf_Mag(j,k) = NaN;
                    Vinf_Mag2(j,k) = NaN;
                end
            else
                if Vinf_Mag(j,k)^2 < Value
                    Vinf_Mag(j,k) = NaN;
                    Vinf_Mag2(j,k) = NaN;
                end
            end
        end
    end
    Vinf_G.Magnitude{2*Leg-1} = Vinf_Mag; % write to groomed output struct
    Vinf_G.Magnitude{2*Leg} = Vinf_Mag2; % write to groomed output struct
elseif strcmp(Parameter,'V_Entry')
    dims = size(Vinf_R.Magnitude{2*Leg}); % dimensions of leg 'i'
    Vinf_Mag = Vinf_R.Magnitude{2*Leg}; % get accessible Vinf magnitude data
    Vinf_Mag2 = Vinf_R.Magnitude{2*Leg-1}; % get accessible Vinf magnitude data
    for j = 1:dims(1)
        for k = 1:dims(2)
            if LessThan
                if sqrt(2*other(1)/(other(2)+other(3)) + Vinf_Mag(j,k)^2) > Value
                    Vinf_Mag(j,k) = NaN;
                    Vinf_Mag2(j,k) = NaN;
                end
            else
                if sqrt(2*other(1)/(other(2)+other(3)) + Vinf_Mag(j,k)^2) < Value
                    Vinf_Mag(j,k) = NaN;
                    Vinf_Mag2(j,k) = NaN;
                end
            end
        end
    end
    Vinf_G.Magnitude{2*Leg} = Vinf_Mag; % write to groomed output struct
    Vinf_G.Magnitude{2*Leg-1} = Vinf_Mag2; % write to groomed output struct
elseif strcmp(Parameter,'dV_t')
elseif strcmp(Parameter,'dV_d')
elseif strcmp(Parameter,'dV_a')
elseif strcmp(Parameter,'Reset')
    for i = 1:length(Vinf_R.Magnitude)
        dims = size(Vinf_R.Magnitude{i}); % dimensions of leg 'i'
        Mag = NaN(dims(1),dims(2)); % Vinf magnitude array initialization
        Vinf_Vect = Vinf_R.Vector{i}; % get accessible Vinf vector data
        for j = 1:dims(1)
            for k = 1:dims(2)
                Mag(j,k) = sqrt(Vinf_Vect(j,k,1)^2+Vinf_Vect(j,k,2)^2+Vinf_Vect(j,k,3)^2);
            end
        end
        Vinf_G.Magnitude{i} = Mag; % write to groomed output struct
    end
end

end