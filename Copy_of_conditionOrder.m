function [conditions_array, rnd_condition_order] = Copy_of_conditionOrder(structure, max_repeats, rnd_condition_order,...
    categorizing, agent_patient)

struct_conditions = zeros(length(structure), 3);
for i = 1:length(structure)
    struct_conditions(i, :) = structure(i).condition;
end
% ik had array 1:0 2:1 3:3 en hij had toch conditie 1 vooraan in de rij!!!!!!!
% ik denk dat dit komt omdat we een random conditie order maken gebasseerd op de huidige array en dan maar 1 conditie aftrekken van de array en hierop verder bouwen!

if categorizing
    active_conditions = struct_conditions(:,1);
    not_completed_indexes = [structure.c_completed]==0;
    free_conditions = active_conditions(not_completed_indexes)';
elseif agent_patient
    a_active_conditions = struct_conditions(:,2);
    p_active_conditions = struct_conditions(:,3);
    active_conditions = [a_active_conditions p_active_conditions];
    not_completed_indexes = [[structure.a_completed]==0; [structure.p_completed]==0];
    a_available = a_active_conditions(not_completed_indexes(1,:));
    p_available = p_active_conditions(not_completed_indexes(2,:));
    free_conditions = [a_available' p_available'];
elseif ~agent_patient && ~categorizing    
    c_active_conditions = struct_conditions(:,1);
    a_active_conditions = struct_conditions(:,2);
    p_active_conditions = struct_conditions(:,3);
    a_active_conditions = [c_active_conditions a_active_conditions p_active_conditions];
    not_completed_indexes = [[structure.c_completed]==0; [structure.a_completed]==0; [structure.p_completed]==0];
    c_available = c_active_conditions(not_completed_indexes(1,:));
    a_available = a_active_conditions(not_completed_indexes(2,:));
    p_available = p_active_conditions(not_completed_indexes(3,:));
    free_conditions = [c_available' a_available' p_available'];
end

starting_no_conditions  = histc(free_conditions, unique(active_conditions));

conditions_array = [unique(active_conditions)'; starting_no_conditions];

maximum_left = max(conditions_array(2,:));
rest_left = sum(conditions_array(2,:)) - maximum_left;
% if maximum_left > (rest_left+1)*max_repeats
%     disp('starting proportions do not allow the restricted randomization');
% end
if maximum_left > (rest_left)*max_repeats
    disp('starting proportions do not allow the restricted randomization');
end
% if sum(conditions_array(2,:)) > (4*(sum(conditions_array(2,:))-max(conditions_array(2,:)))+max_repeats)  % this formula ensures that it is mathematical possible to create a list with the restriction of max_repeats of the same consecutive conditions
%     disp('starting proportions do not allow the restricted randomization');
% end
if sum(conditions_array(2,:)) == 0
    disp('conditions_array is empty');
end

if isempty(rnd_condition_order)
        rnd_condition_order = free_conditions(randperm(length(free_conditions), 1));
%     rnd_condition_order = free_conditions(randperm(length(free_conditions), max_repeats));
%     while length(rnd_condition_order)~=10
%         if sum(rnd_condition_order(end-(max_repeats-1):end)==rnd_condition_order(end)) == (max_repeats)
%             danger_for_repeat = rnd_condition_order(end);
%         else
%             danger_for_repeat = [];
%         end
%         not_excluded_conditions = find(conditions_array(2,:) == ...     % this is based on having enough of a condition left to fullfil the no more than 3 repeats criterium
%             (max_repeats*(sum(conditions_array(2,:))-max(conditions_array(2,:)))+max_repeats));
%         if isempty(not_excluded_conditions)
%             not_excluded_conditions = conditions_array(1,:);
%         end
%         not_empty_conditions = find(conditions_array(2, :)~=0);
%         available_conditions = intersect(not_excluded_conditions, not_empty_conditions);
%         available_conditions = setdiff(available_conditions, danger_for_repeat);
%         available_conditions_list = free_conditions(ismember(free_conditions, available_conditions));
%         added_condition = available_conditions_list(randperm(length(available_conditions_list), 1));
%         rnd_condition_order(end+1) = added_condition;
%     end
else
    if length(rnd_condition_order) < max_repeats
        rnd_condition_order(end+1) = free_conditions(randperm(length(free_conditions), 1));
    else
        if sum(rnd_condition_order(end-(max_repeats-1):end)==rnd_condition_order(end)) == (max_repeats)
            danger_for_repeat = rnd_condition_order(end);
        else
            danger_for_repeat = [];
        end
%         if maximum_left == (rest_left+1)*max_repeats
%             not_excluded_conditions = conditions_array(1,find(conditions_array(2,:)==maximum_left));
%         else
%             not_excluded_conditions = conditions_array(1,:);
%         end
        if maximum_left == (rest_left)*max_repeats
            not_excluded_conditions = conditions_array(1,find(conditions_array(2,:)==maximum_left));
        else
            not_excluded_conditions = conditions_array(1,:);
        end
%         not_excluded_conditions = conditions_array(1,find(conditions_array(2,:) == ...     % this is based on having enough of a condition left to fullfil the no more than 3 repeats criterium
%             (max_repeats*(sum(conditions_array(2,:))-max(conditions_array(2,:)))+max_repeats)));
%         if isempty(not_excluded_conditions)
%             not_excluded_conditions = conditions_array(1,:);
%         end
        not_empty_conditions = conditions_array(1,find(conditions_array(2, :)~=0));
        available_conditions = intersect(not_excluded_conditions, not_empty_conditions);
        available_conditions = setdiff(available_conditions, danger_for_repeat);
        available_conditions_list = free_conditions(ismember(free_conditions, available_conditions));
        added_condition = available_conditions_list(randperm(length(available_conditions_list), 1));
        rnd_condition_order(end+1) = added_condition;
    end
%     rnd_condition_order = rnd_condition_order(2:10);
%     if sum(rnd_condition_order(end-(max_repeats-1):end)==rnd_condition_order(end)) == (max_repeats)
%         danger_for_repeat = rnd_condition_order(end);
%     else
%         danger_for_repeat = [];
%     end
%     not_excluded_conditions = find(conditions_array(2,:) == ...     % this is based on having enough of a condition left to fullfil the no more than 3 repeats criterium
%         (max_repeats*(sum(conditions_array(2,:))-max(conditions_array(2,:)))+max_repeats));
%     if isempty(not_excluded_conditions)
%         not_excluded_conditions = conditions_array(1,:);
%     end
%     not_empty_conditions = find(conditions_array(2, :)~=0);
%     available_conditions = intersect(not_excluded_conditions, not_empty_conditions);
%     available_conditions = setdiff(available_conditions, danger_for_repeat);
%     available_conditions_list = free_conditions(ismember(free_conditions, available_conditions));
%     added_condition = available_conditions_list(randperm(length(available_conditions_list), 1));
%     rnd_condition_order(end+1) = added_condition;
end
end