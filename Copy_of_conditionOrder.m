function [conditions_array, rnd_condition_order, struct_conditions] = Copy_of_conditionOrder(structure, max_repeats, rnd_condition_order,...
    categorizing, agent_patient)

struct_conditions = cell(1);
for i = 1:length(structure)
    struct_conditions(i, 1:length(structure(i).condition)) = num2cell(structure(i).condition);
end
% parallel in 3e dimense booleans creeren voor de struct_conditions om de
% niet gebruikt te isoleren
for i = 1:length(struct_conditions(:,1,1))
    for j = 1:length(struct_conditions(1,:,1))
        if ~isempty(struct_conditions(i,j))
            if ismember(struct_conditions{i,j}, [1 2 3 4])
                struct_conditions{i,j,2} = structure(i).c_completed;
            end
            if struct_conditions{i,j} == 5
                struct_conditions{i,j,2} = structure(i).a_completed;
            end
            if struct_conditions{i,j} == 6 
                struct_conditions{i,j,2} = structure(i).p_completed;
            end
            if struct_conditions{i,j} == 7
                struct_conditions{i,j,2} = structure(i).b_completed;
            end
        else
            struct_conditions{i,j,2} = 99;
        end
    end
end
% num_array_not_completed = cell2mat(struct_conditions(:,:,2))==0;
%%%% hacky way: just make num_array_not_completed a ones matrix with the size of
%%%% struct_conditions
num_array_not_completed = logical(ones(size(struct_conditions(:,:,2))));
free_conditions = [struct_conditions{num_array_not_completed}];
if isempty(free_conditions)
    free_conditions = zeros(size(unique([struct_conditions{:,:,1}])));
end


starting_no_conditions  = histc(free_conditions, unique([struct_conditions{:,:,1}]));

conditions_array = [unique([struct_conditions{:,:,1}]); starting_no_conditions];

maximum_left = max(conditions_array(2,:));
rest_left = sum(conditions_array(2,:)) - maximum_left;
if maximum_left > (rest_left)*max_repeats
    disp('starting proportions do not allow the restricted randomization');
end
if sum(conditions_array(2,:)) == 0
    disp('conditions_array is empty');
end

if isempty(rnd_condition_order)
        rnd_condition_order = free_conditions(randperm(length(free_conditions), 1));
else
    if length(rnd_condition_order) < max_repeats
        rnd_condition_order(end+1) = free_conditions(randperm(length(free_conditions), 1));
    else
        if sum(rnd_condition_order(end-(max_repeats-1):end)==rnd_condition_order(end)) == (max_repeats)
            danger_for_repeat = rnd_condition_order(end);
        else
            danger_for_repeat = [];
        end
        not_excluded_conditions = conditions_array(1,:);
        for i = flip(1:length(conditions_array(2,:)))
            rest = conditions_array(2,:);
            rest(i) = [];
            sum_rest = sum(rest);
            if sum_rest > conditions_array(2,i)*max_repeats
                not_excluded_conditions(i) = [];
            end
        end
        not_empty_conditions = conditions_array(1,find(conditions_array(2, :)~=0));
        available_conditions = intersect(not_excluded_conditions, not_empty_conditions);
        available_conditions = setdiff(available_conditions, danger_for_repeat);
        available_conditions_list = free_conditions(ismember(free_conditions, available_conditions));
        added_condition = available_conditions_list(randperm(length(available_conditions_list), 1));
        rnd_condition_order(end+1) = added_condition;
    end
end
end