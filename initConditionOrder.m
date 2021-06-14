% function [conditions_array, conditions] = initConditionOrder(categorizing, agent_patient, rnd_condition_order, varargin) % varargin is the list with all the names of the stimulilists and should always be of length 8
function [conditions_array, conditions] = initConditionOrder(categorizing, agent_patient, varargin) % varargin is the list with all the names of the stimulilists and should always be of length 8
% [conditions_array, conditions] = initConditionOrder(true,false, TrialRecord.User.chasing_list, ...
%         TrialRecord.User.gen_chasing_list, TrialRecord.User.grooming_list,...
%         TrialRecord.User.gen_grooming_list, TrialRecord.User.mounting_list,...
%         TrialRecord.User.gen_mounting_list,...
%         TrialRecord.User.holding_list, TrialRecord.User.gen_holding_list);
if length(varargin) < 8
    disp('stimulus list missing in input');
end
% if exist('rnd_condition_order','var')    % clear, because we want to restart the condition order everytime we call the initConditionOrder
%     clear rnd_condition_order
% end

% zorg er gwn voor in de taak dat ik de rnd_condition_order manueel clear
% telkes als ik deze functie oproep!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% maybe work with some feedback so that the discrepancies between stimuli
% that are still available does not become too big.
no_chasing = length(varargin{1}) + length(varargin{2}); 
no_grooming = length(varargin{3}) + length(varargin{4});
no_mounting = length(varargin{5}) + length(varargin{6});
no_threat = length(varargin{7}) + length(varargin{8});

active_conditions = 1:(no_chasing>0)+(no_grooming>0)+(no_mounting>0)+(no_threat>0);
if categorizing
    active_conditions = 1:(no_chasing>0)+(no_grooming>0)+(no_mounting>0)+(no_threat>0);
elseif agent_patient
    active_conditions = [5 6];
elseif ~agent_patient && ~categorizing    
    active_conditions = 1:(no_chasing>0)+(no_grooming>0)+(no_mounting>0)+(no_threat>0);
    active_conditions(end+1:end+2) = [5 6];
end

conditions = [];
for i = 1:length(active_conditions)
    switch active_conditions(i)
        case 1
            no_condition = active_conditions(i)* ones(1,no_chasing);
        case 2
            no_condition = active_conditions(i)* ones(1,no_grooming);
        case 3
            no_condition = active_conditions(i)* ones(1,no_mounting);
        case 4
            no_condition = active_conditions(i)* ones(1,no_threat);
        case 5
            no_condition = active_conditions(i)* ones(1,(no_chasing+no_grooming+no_mounting+no_threat));
        case 6
            no_condition = active_conditions(i)* ones(1,(no_chasing+no_grooming+no_mounting+no_threat));
    end
    conditions = horzcat(conditions, no_condition);
end

starting_no_conditions  = histc(conditions, active_conditions);

conditions_array = zeros(2, length(active_conditions));
conditions_array(1,:) = active_conditions;
conditions_array(2,:) = starting_no_conditions;
end

