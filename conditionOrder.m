function [conditions_array, rnd_condition_order] = conditionOrder(conditions_array, conditions, rnd_condition_order, max_repeats)

if sum(conditions_array(2,:)) > (4*min(conditions_array(2,:))+3)  % this formula ensures that it is mathematical possible to create a list with the restriction of 3 of the same consecutive conditions
    disp('starting proportions do not allow the restricted randomization');
end

ik moet in beide stappen de controlecheck uitvoeren die hierboven ook vermeld staat op de new_condition_array.
alleen, als dit goed is, kan ik de stap behouden en moet ze niet opnieuw gedaan worden
new_conditions_array = conditions_array;
repetition = true;
if ~exist(rnd_condition_order)
    rnd_condition_order = ...                      
            conditions(randperm(length(conditions), 10));
    repetitions = true;
    while repetitions
        for i = 4:length(rnd_condition_order)
            if sum(rnd_condition_order(i-3:i)==rnd_condition_order(i)) == 4
                rnd_condition_order = conditions(randperm(length(conditions), 10));
            else
                repetitions = false;
            end
        end
    end
    unique_condition_order = unique(rnd_condition_order);   
    count_conditions  = histc(rnd_condition_order, unique_condition_order);
    for i = 1:length(unique_condition_order)
        new_conditions_array(2, find(new_conditions_array(1,:)==unique_condition_order(i))) = ...
            new_conditions_array(2, find(new_conditions_array(1,:)==unique_condition_order(i))) - count_conditions(i);
    end
else
    rnd_condition_order = ...
        [rnd_condition_order(2:10) new_conditions_array(1, randperm(length(new_conditions_array(1,:)), 1))];
    while repetition
        if sum(new_conditions_array(2,:)) > (4*min(new_conditions_array(2,:))+3)
            disp('something went wrond in running down all the conditions')
        else
            repetition = false;
        end
    end
end
    
    % de conditie met het meest condities over mag er nooit meer dan 4x
    % meer over hebben dan de som van de rest + max repeats? bvb voor lijst van 10 wordt
    % het pas een probleem als er 8 van 1 soort zijn? klopt dit? ja blijkt
    % te kloppen :D, want dan is de lijst theoretisch op te delen in
    % deeltjes van [a a a b a a a b ...]
        
if ((TrialRecord.User.random_condition_order_index...                        % if we have reached the end of the order during previous userloop, reset
        == length(TrialRecord.User.random_condition_order)) && ...
        (~TrialRecord.User.repeat) && (TrialRecord.User.engaged)) ||...
        TrialRecord.User.current_sum_buttons ~= previous_sum_buttons  
    condition_order = [];
    if TrialRecord.User.training_categorization 
        for i = 1:length(TrialRecord.User.structure)
            condition_order(end+1) = [TrialRecord.User.structure(i).condition(1)]; % TrialRecord.User.structure(index).condition = [4 5 6]; first number is category, second agent, last patient
        end
    elseif TrialRecord.User.training_agent_patient
        for i = 1:length(TrialRecord.User.structure)
            condition_order(end+1) = [TrialRecord.User.structure(i).condition(2)];
            condition_order(end+1) = [TrialRecord.User.structure(i).condition(3)];
        end
    else
        for i = 1:length(TrialRecord.User.structure)
            condition_order(end+1) = [TrialRecord.User.structure(i).condition(1)];
            condition_order(end+1) = [TrialRecord.User.structure(i).condition(2)];
            condition_order(end+1) = [TrialRecord.User.structure(i).condition(3)];
        end
    end

    restricted = false;
    indexes_used_c_stimuli = find([TrialRecord.User.structure.c_completed]==1); % we are in the reset order loop, so we have to account for already completed stimuli in the structure
    used_c_conditions = [];
    for i = 1:length(indexes_used_c_stimuli)
        used_c_conditions(end+1) = ...                                          % find the conditions that have been completed in the struct already
            TrialRecord.User.structure(indexes_used_c_stimuli(i)).condition(1); % this way we can account for time in the new condition order creation
    end                                                                         % so that we do not stumble upon size errors in the struct e.g.:
    indexes_used_a_stimuli = find([TrialRecord.User.structure.a_completed]==1); % 3 condition 1, when there is only room for 1 before the next reset
    used_a_conditions = ones(1, length(indexes_used_a_stimuli))*5;
    indexes_used_p_stimuli = find([TrialRecord.User.structure.p_completed]==1);
    used_p_conditions = ones(1, length(indexes_used_p_stimuli))*6;
    used_conditions = horzcat(used_c_conditions, used_a_conditions, used_p_conditions);
    conditions_already_completed = ...
        TrialRecord.User.random_condition_order(end-length(used_conditions)+1:end); % gather the conditions that are completed in the current structure from the previous condition order
    steps_till_reset = ...                                                  % calculate the steps before next reset, this is de dangerous window for size errors
        TrialRecord.User.blocksize - TrialRecord.User.completed_stimuli;
    while ~restricted
        TrialRecord.User.random_condition_order = ...                       % create new random order
            condition_order(randperm(length(condition_order)));
        TrialRecord.User.random_condition_order_index = 0;                  % reset index
        index2 = 1;
        repetitions = 0;
        while index2 ~= (length(TrialRecord.User.random_condition_order)-(max_repeats_condition-1)) % minus max repeats, because within the loop, I index further up to the max repeats within the order
            if TrialRecord.User.random_condition_order(index2) == TrialRecord.User.random_condition_order(index2+1)... % if the indexed valuu equals the next 3 values
                    && TrialRecord.User.random_condition_order(index2) == TrialRecord.User.random_condition_order(index2+2)...
                    && TrialRecord.User.random_condition_order(index2) == TrialRecord.User.random_condition_order(index2+3)
                repetitions = repetitions + 1;
            end
            index2 = index2 + 1;
        end
        problem_vector = horzcat(conditions_already_completed,...           % this is the vector with the already completed conditions and the conditions that will be displayed within the danger zone
            TrialRecord.User.random_condition_order(1:steps_till_reset));   % if the planned number of conditions exceeds the available number of conditions
        if length(find(problem_vector==1)) > length(TrialRecord.User.chasing_list) ||...
                length(find(problem_vector==2)) > length(TrialRecord.User.grooming_list) ||...
                length(find(problem_vector==3)) > length(TrialRecord.User.mounting_list) ||...
                length(find(problem_vector==4)) > length(TrialRecord.User.holding_list) ||...
                length(find(problem_vector==5)) > length(stimulus_list) ||...
                length(find(problem_vector==6)) > length(stimulus_list)
            size_error = true;
        else
            size_error = false;
        end
        if repetitions == 0 && ~size_error
            restricted = true;
        end
    end
    disp('condition order reset');
else
    disp('did not reset random condition order');
end

end
