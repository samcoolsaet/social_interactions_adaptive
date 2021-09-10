function [structure] = Copy_of_createStructure(stimulus_list, frame_list, cum_length, chasing_folder,...
    gen_chasing_folder, grooming_folder, gen_grooming_folder, mounting_folder, gen_mounting_folder,...
    holding_folder, gen_holding_folder, categorizing, agent_patient)
structure = struct('stimuli', {}, 'frames', {}, 'c_fails', {}, ... 
    'c_success', {},'c_completed', {}, 'c_last_block', {}, 'a_fails', {}, 'a_success', {}, ...
    'a_completed', {}, 'a_last_block', {}, 'p_fails', {}, 'p_success', {}, 'p_completed', {},...
    'p_last_block', {}, 'b_fails', {}, 'b_success', {}, ...
    'b_completed', {}, 'b_last_block', {}, 'folder', {}, 'condition', {});
if agent_patient
    load('inventory.mat', 'inventory');
end
for i = 1:length(stimulus_list)
    structure(i).stimuli = stimulus_list(i);
    structure(i).frames = frame_list(i);
    structure(i).c_fails = 0;
    structure(i).c_success = 0;
    structure(i).c_completed = 0;
    structure(i).c_last_block = 0;
    structure(i).a_fails = 0;
    structure(i).a_success = 0;
    structure(i).a_completed = 0;
    structure(i).a_last_block = 0;
    structure(i).p_fails = 0;
    structure(i).p_success = 0;
    structure(i).p_completed = 0;
    structure(i).p_last_block = 0;
    structure(i).b_fails = 0;
    structure(i).b_success = 0;
    structure(i).b_completed = 0;
    structure(i).b_last_block = 0;
    if categorizing && agent_patient       
        inv_index = contains([inventory.name], stimulus_list{i}(1:end-3));
        conditions = ~[isempty(inventory(inv_index).a_degrees) ...
            isempty(inventory(inv_index).p_degrees) ...
            isempty(inventory(inv_index).b_degrees)] .* [5 6 7];
        if i <= cum_length(1)
            structure(i).folder = chasing_folder;
            structure(i).condition = [1 conditions(conditions~=0)];
        elseif i <= cum_length(2)
            structure(i).folder = gen_chasing_folder;
            structure(i).condition = [1 conditions(conditions~=0)];
        elseif i <= cum_length(3)
            structure(i).folder = grooming_folder;
            structure(i).condition = [2 conditions(conditions~=0)];
        elseif i <= cum_length(4)
            structure(i).folder = gen_grooming_folder;
            structure(i).condition = [2 conditions(conditions~=0)];
        elseif i <= cum_length(5)
            structure(i).folder = mounting_folder;
            structure(i).condition = [3 conditions(conditions~=0)];
        elseif i <= cum_length(6)
            structure(i).folder = gen_mounting_folder;
            structure(i).condition = [3 conditions(conditions~=0)];
        elseif i <= cum_length(7)
            structure(i).folder = holding_folder;
            structure(i).condition = [4 conditions(conditions~=0)];
        elseif i <= cum_length(8)
            structure(i).folder = gen_holding_folder;
            structure(i).condition = [4 conditions(conditions~=0)];
        end
    elseif agent_patient
        inv_index = contains([inventory.name], stimulus_list{i}(1:end-3));
        conditions = ~[isempty(inventory(inv_index).a_degrees) ...
            isempty(inventory(inv_index).p_degrees) ...
            isempty(inventory(inv_index).b_degrees)] .* [5 6 7];
        structure(i).condition = conditions(conditions~=0);
        if i <= cum_length(1)
            structure(i).folder = chasing_folder;
        elseif i <= cum_length(2)
            structure(i).folder = gen_chasing_folder;
        elseif i <= cum_length(3)
            structure(i).folder = grooming_folder;
        elseif i <= cum_length(4)
            structure(i).folder = gen_grooming_folder;
        elseif i <= cum_length(5)
            structure(i).folder = mounting_folder;
        elseif i <= cum_length(6)
            structure(i).folder = gen_mounting_folder;
        elseif i <= cum_length(7)
            structure(i).folder = holding_folder;
        elseif i <= cum_length(8)
            structure(i).folder = gen_holding_folder;
        end
    elseif categorizing
        if i <= cum_length(1)
            structure(i).folder = chasing_folder;
            structure(i).condition = 1;
        elseif i <= cum_length(2)
            structure(i).folder = gen_chasing_folder;
            structure(i).condition = 1;
        elseif i <= cum_length(3)
            structure(i).folder = grooming_folder;
            structure(i).condition = 2;
        elseif i <= cum_length(4)
            structure(i).folder = gen_grooming_folder;
            structure(i).condition = 2;
        elseif i <= cum_length(5)
            structure(i).folder = mounting_folder;
            structure(i).condition = 3;
        elseif i <= cum_length(6)
            structure(i).folder = gen_mounting_folder;
            structure(i).condition = 3;
        elseif i <= cum_length(7)
            structure(i).folder = holding_folder;
            structure(i).condition = 4;
        elseif i <= cum_length(8)
            structure(i).folder = gen_holding_folder;
            structure(i).condition = 4;
        end
    end
end
disp('new structure made');
end

