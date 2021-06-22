function [conditions_array, rnd_condition_order] = conditionOrder(conditions_array, conditions, max_repeats, rnd_condition_order)
% [conditions_array, rnd_condition_order] = conditionOrder(conditions_array, conditions, max_repeats, rnd_condition_order)
if sum(conditions_array(2,:)) > (4*(sum(conditions_array(2,:))-max(conditions_array(2,:)))+max_repeats)  % this formula ensures that it is mathematical possible to create a list with the restriction of max_repeats of the same consecutive conditions
    disp('starting proportions do not allow the restricted randomization');
end

% nu moet ik nog iets maken als we op het einde aangekomen zijn ook.
% conditions moeten ook geupdated worden of hij gaat in het negatief

new_conditions_array = conditions_array;
rnd_condition_order_test = rnd_condition_order;
repetition = true;
if isempty(rnd_condition_order)
    rnd_condition_order_test = ...                      
            conditions(randperm(length(conditions), 10));
    repetitions = true;
    while repetitions || repetition
        new_conditions_array = conditions_array;
        unique_condition_order = unique(rnd_condition_order_test);   
        count_conditions  = histc(rnd_condition_order_test, unique_condition_order);
        for i = 1:length(unique_condition_order)
            new_conditions_array(2, find(new_conditions_array(1,:)==unique_condition_order(i))) = ...
                new_conditions_array(2, find(new_conditions_array(1,:)==unique_condition_order(i))) - count_conditions(i);
        end
        for i = 4:length(rnd_condition_order_test)
            if sum(rnd_condition_order_test(i-max_repeats:i)==rnd_condition_order_test(i)) == 4
                rnd_condition_order_test = conditions(randperm(length(conditions), 10));
            else
                repetitions = false;
            end
        end
        if sum(new_conditions_array(2,:)) > (4*(sum(new_conditions_array(2,:))-max(new_conditions_array(2,:)))+max_repeats) || ...
                any(new_conditions_array(2,:)<0)
            rnd_condition_order_test = conditions(randperm(length(conditions), 10));
        else
            repetition = false;
        end
    end
else
    rnd_condition_order_test = ...
        [rnd_condition_order(2:10) new_conditions_array(1, randperm(length(new_conditions_array(1,:)), 1))];
    repetitions = true;
    while repetitions || repetition
        new_conditions_array = conditions_array;
        new_conditions_array(2, find(new_conditions_array(1,:)==rnd_condition_order_test(end))) = ...
            new_conditions_array(2, find(new_conditions_array(1,:)==rnd_condition_order_test(end))) - 1;
        for i = 4:length(rnd_condition_order_test)
            if sum(rnd_condition_order_test(i-max_repeats:i)==rnd_condition_order_test(i)) == 4
                rnd_condition_order_test = ...
                    [rnd_condition_order(2:10) new_conditions_array(1, randperm(length(new_conditions_array(1,:)), 1))]; % ik neem hier de eerste 9 rnd_condition_order die net het probleem veroorzaakt, dit is dus niet goed
            else
                repetitions = false;
            end
        end
        if sum(new_conditions_array(2,:)) > (4*(sum(new_conditions_array(2,:))-max(new_conditions_array(2,:)))+max_repeats) || ...
                any(new_conditions_array(2,:)<0)
            rnd_condition_order_test = ...
                [rnd_condition_order(2:10) new_conditions_array(1, randperm(length(new_conditions_array(1,:)), 1))];
        else
            repetition = false;
        end
    end
end
rnd_condition_order = rnd_condition_order_test;
conditions_array = new_conditions_array;
%%%%%%%%%%%%%%%%%%% ik voeg nog altijd de verkeerde cijfers toe aan mijn
%%%%%%%%%%%%%%%%%%% rnd_condition_order!!!!
end

