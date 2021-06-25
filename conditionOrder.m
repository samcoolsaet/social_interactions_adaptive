function [conditions_array, rnd_condition_order] = conditionOrder(conditions_array, conditions, max_repeats, rnd_condition_order)
% [conditions_array, rnd_condition_order] = conditionOrder(conditions_array, conditions, max_repeats, rnd_condition_order)
if sum(conditions_array(2,:)) > (4*(sum(conditions_array(2,:))-max(conditions_array(2,:)))+max_repeats)  % this formula ensures that it is mathematical possible to create a list with the restriction of max_repeats of the same consecutive conditions
    disp('starting proportions do not allow the restricted randomization');
end
if sum(conditions_array(2,:)) == 0
    disp('conditions_array is empty');
end
% nu moet ik nog iets maken als we op het einde aangekomen zijn ook.
% conditions moeten ook geupdated worden of hij gaat in het negatief
% for i = 1:46
    repetitions = true;
    repetition = true;
    new_conditions_array = conditions_array;
    rnd_condition_order_test = rnd_condition_order;
    if isempty(rnd_condition_order)
        rnd_condition_order_test = ...                      
                conditions(randperm(length(conditions), 10));
        while repetitions || repetition
            repetitions = true;
            repetition = true;
            new_conditions_array = conditions_array;
            unique_condition_order = unique(rnd_condition_order_test);   
            count_conditions  = histc(rnd_condition_order_test, unique_condition_order);
            for i = 1:length(unique_condition_order)
                new_conditions_array(2, find(new_conditions_array(1,:)==unique_condition_order(i))) = ...
                    new_conditions_array(2, find(new_conditions_array(1,:)==unique_condition_order(i))) - count_conditions(i);
            end
            for i = (max_repeats+1):length(rnd_condition_order_test)
                if sum(rnd_condition_order_test(i-max_repeats:i)==rnd_condition_order_test(i)) == (max_repeats+1)
                    rnd_condition_order_test = conditions(randperm(length(conditions), 10));
                else
                    repetitions = false;
                end
            end
            if max(new_conditions_array(2,:)) > (max_repeats*(sum(new_conditions_array(2,:))-max(new_conditions_array(2,:)))+max_repeats) || ...
                    any(new_conditions_array(2,:)<0)
                rnd_condition_order_test = conditions(randperm(length(conditions), 10));
            else
                repetition = false;
            end
        end
    else
        rnd_condition_order_test = rnd_condition_order(2:10);
        if sum(rnd_condition_order(end-(max_repeats-2):end)==rnd_condition_order(end)) == (max_repeats-1)
            danger_for_repeat = rnd_condition_order(end);
        else
            danger_for_repeat = [];
        end
        not_excluded_conditions = find(new_conditions_array(2,:) == ...     % this is based on having enough of a condition left to fullfil the no more than 3 repeats criterium
            (max_repeats*(sum(new_conditions_array(2,:))-max(new_conditions_array(2,:)))+max_repeats));
        if isempty(not_excluded_conditions)
            not_excluded_conditions = new_conditions_array(1,:);
        end
        not_empty_conditions = find(new_conditions_array(2, :)~=0);
        available_conditions = intersect(not_excluded_conditions, not_empty_conditions);
        available_conditions = setdiff(available_conditions, danger_for_repeat);
        available_conditions_list = [];
        for i = 1:length(available_conditions)
            available_conditions_list = [available_conditions_list ...
                new_conditions_array(1, available_conditions(i))*ones(1, new_conditions_array(2, available_conditions(i)))];
        end
%         added_condition_index = randperm(length(available_conditions), 1);
%         added_condition = available_conditions(added_condition_index);
        added_condition = available_conditions_list(randperm(length(available_conditions_list), 1));
        rnd_condition_order_test(end+1) = added_condition;
        new_conditions_array(2, find(new_conditions_array(1,:)==added_condition)) = ...
            new_conditions_array(2, find(new_conditions_array(1,:)==rnd_condition_order_test(end))) - 1;
    end
rnd_condition_order = rnd_condition_order_test;
conditions_array = new_conditions_array;
% disp([rnd_condition_order(end)  conditions_array(1, find(new_conditions_array(1,:)==rnd_condition_order(end)))]);
% end