function [conditions_array, conditions] = Copy_of_initConditionOrder(categorizing,...
    agent_patient, structure)          % varargin is the list with all the names of the stimulilists and should always be of length 8

struct_conditions = zeros(length(structure), 3);
for i = 1:length(structure)
    struct_conditions(i, :) = structure(i).condition;
end

if categorizing
    active_conditions = struct_conditions(:,1);
elseif agent_patient
    active_conditions = struct_conditions(:,2:3);
elseif ~agent_patient && ~categorizing    
    active_conditions = struct_conditions;
end

conditions = unique(active_conditions);
active_conditions = reshape(active_conditions, 1, []);
starting_no_conditions  = histc(active_conditions, unique(active_conditions));

conditions_array = [[unique(active_conditions)]; [starting_no_conditions]];
end

