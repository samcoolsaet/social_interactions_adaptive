function [C,timingfile,userdefined_trialholder] = social_userloop(MLConfig,TrialRecord)
%% template
% return values
C = [];
timingfile = 'social_timing.m';                                 % Placeholder, real timing file assigned below.
userdefined_trialholder = '';

persistent timing_filenames_retrieved
    if isempty(timing_filenames_retrieved)
        timing_filenames_retrieved = true;
    return
    end
%% initializing for first trial
TrialRecord.User.start_block = 1;                                               % the progression number to start training with
TrialRecord.User.generalizing = true;

if TrialRecord.CurrentTrialNumber == 0
%     TrialRecord.User.random_condition_order = 1;
%     TrialRecord.User.random_condition_order_index = 1;
    TrialRecord.User.performance = 0;
    TrialRecord.NextBlock = TrialRecord.User.start_block;
    previous_sum_buttons = 0;
    previous_sum_categories = 0;
    TrialRecord.User.engaged = true;
    TrialRecord.User.max_fails = 6;
    TrialRecord.User.repeat = false;
    TrialRecord.User.completed_stimuli = 0;
    TrialRecord.User.c_structure_completion = 0;
    TrialRecord.User.a_structure_completion = 0;
    TrialRecord.User.p_structure_completion = 0;
    TrialRecord.User.test_trial_counter = 0;
    TrialRecord.User.structure_completion = 0;
else
    previous_sum_buttons = TrialRecord.User.current_sum_buttons;      % calculations of previous sum categories
    previous_sum_categories = TrialRecord.User.current_sum_categories;    
end
%% constants
% progression
TrialRecord.User.blocksize = 10;                                            % The TrialRecord.User.blocksize is the number of animations the monkey has to complete.
                                                                            %%% maybe later create a blocksize as a function of previous performance to quickly skip to his level when starting again.

succes_threshold = 0.80;                                                    % if performance is bigger than or equal to this, progression number + 1
fail_threshold = 0.10;                                                         % if performance is smaller than or equal to this, progression number - 1

TrialRecord.User.size_progression_factor = 20;                              % the number of progression number steps needed to go from start size to end size, used for both category and agent patient

TrialRecord.User.button_progression_factor = ...
    TrialRecord.User.size_progression_factor + 1;                            % number of progression number steps needed to add a category button
                                                                            % progression_trials 
                                                                            
TrialRecord.User.max_block = 20; % TrialRecord.User.button_progression_factor * 3 ...
%    - 1;                                                                    % last button active + at final size
TrialRecord.User.min_block = TrialRecord.User.start_block;

% training
TrialRecord.User.training_categorization = false;                            % complete task or training
TrialRecord.User.training_agent_patient = true;

% fixed constants
TrialRecord.User.chasing_on = false;                                        % all false for script to work
TrialRecord.User.grooming_on = false;
TrialRecord.User.holding_on = false;
TrialRecord.User.mounting_on = false;
TrialRecord.User.agent_on = false;
TrialRecord.User.patient_on = false;

TrialRecord.User.categorizing = false;
TrialRecord.User.agenting = false;
TrialRecord.User.patienting = false;

TrialRecord.User.grooming = false;
TrialRecord.User.chasing = false;
TrialRecord.User.holding = false;
TrialRecord.User.mounting = false;


%% determining next block and difficulty based on a general progression number %%%%%% maybe create a vector with the length of trialerrors but displaying the stimulus sequence numbers, this way I can keep track of actual fails and just going on when failing because the number of repeats hits the limit
if TrialRecord.CurrentTrialNumber ~= 0
    cum_last_block = sum([TrialRecord.User.structure.c_last_block]) + ...
        sum([TrialRecord.User.structure.a_last_block]) + ...
        sum([TrialRecord.User.structure.p_last_block]);
    if cum_last_block == TrialRecord.User.blocksize 
        [TrialRecord.User.structure, TrialRecord.User.performance, TrialRecord.NextBlock] = ...
            evaluate(TrialRecord.User.structure, TrialRecord.CurrentBlock, succes_threshold, fail_threshold);
    end
end

if TrialRecord.User.structure_completion == 1
    TrialRecord.User.structure = resetStructure(TrialRecord.User.structure);
end

if TrialRecord.NextBlock > TrialRecord.User.max_block
    TrialRecord.NextBlock = TrialRecord.User.max_block;
    disp(['max block reached' string(TrialRecord.User.max_block)]);
elseif TrialRecord.NextBlock < TrialRecord.User.min_block
    TrialRecord.NextBlock = TrialRecord.User.min_block;
    disp(['min block reached' string(TrialRecord.User.min_block)]);
end
% setting independant category and button progression based on progression
% number
TrialRecord.User.button_progression = ...                                 % the category progression factor, which should be at least bigger than the size progression factor in order 
    TrialRecord.NextBlock / ...                               % in order to go through the complete size evolution before adding a category, determines the number of progression
    (TrialRecord.User.button_progression_factor);                                          % number steps needed to increase category progression + 1

TrialRecord.User.size_progression = ... 
    mod(TrialRecord.NextBlock, ... 
    TrialRecord.User.button_progression_factor);

%% toggling conditions on
% training progression switches. at the end ( if not training ) all switches
% are turned on 
if TrialRecord.User.training_categorization
    TrialRecord.User.category = true;
    if TrialRecord.User.button_progression >=0
        TrialRecord.User.chasing_on = true;
    end
    if TrialRecord.User.button_progression >=1
        TrialRecord.User.grooming_on = true;
    end
    if TrialRecord.User.button_progression >=2
        TrialRecord.User.mounting_on = true;
    end
    if TrialRecord.User.button_progression >=3
        TrialRecord.User.holding_on = true;
    end
elseif TrialRecord.User.training_agent_patient
    TrialRecord.User.agent_on = true;
    TrialRecord.User.patient_on = true;
    TrialRecord.User.category = false;
    if TrialRecord.User.button_progression >=0
        TrialRecord.User.chasing_on = true;
    end
    if TrialRecord.User.button_progression >=1
        TrialRecord.User.grooming_on = true;
    end
    if TrialRecord.User.button_progression >=2
        TrialRecord.User.mounting_on = true;
    end
    if TrialRecord.User.button_progression >=3
        TrialRecord.User.holding_on = true;
    end
else
    TrialRecord.User.chasing_on = true;
    TrialRecord.User.grooming_on = true;
    TrialRecord.User.holding_on = true;
    TrialRecord.User.mounting_on = true;
    TrialRecord.User.agent_on = true;
    TrialRecord.User.patient_on = true;
    TrialRecord.User.category = true;
end

% calculation current sum categories after switches have been altered

TrialRecord.User.current_sum_categories = sum([TrialRecord.User.chasing_on, ... % difference between current and previous sum of categories acts as a 
    TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...               % switch for new stimulus list creation involving new categories and other
    TrialRecord.User.mounting_on,]);
display(TrialRecord.User.current_sum_categories);

if TrialRecord.User.training_categorization
    TrialRecord.User.current_sum_buttons = sum([TrialRecord.User.chasing_on, ... 
        TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...           
        TrialRecord.User.mounting_on]);
elseif TrialRecord.User.training_agent_patient   
    TrialRecord.User.current_sum_buttons = sum([TrialRecord.User.agent_on, ...  
        TrialRecord.User.patient_on]);
else   
    TrialRecord.User.current_sum_buttons = sum([TrialRecord.User.chasing_on, ... % difference between current and previous sum of categories acts as a 
        TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...               % switch for new stimulus list creation involving new categories and other
        TrialRecord.User.mounting_on, TrialRecord.User.agent_on, ...                % changes that have to be made when categories are added
        TrialRecord.User.patient_on]);
end
%% orienting between stimuli and frame files creating individual folder lists and general stim and frame lists
% Do all of this for trial 0 because it would be inefficient to repeat and
% I want these variables to be fixed throughout the run
if TrialRecord.CurrentTrialNumber == 0
    [TrialRecord.User.chasing_list, TrialRecord.User.grooming_list, TrialRecord.User.mounting_list, ...
        TrialRecord.User.holding_list, TrialRecord.User.gen_chasing_list, TrialRecord.User.gen_grooming_list, ...
        TrialRecord.User.gen_mounting_list, TrialRecord.User.gen_holding_list,...
    TrialRecord.User.chasing_frame_list, TrialRecord.User.grooming_frame_list, TrialRecord.User.mounting_frame_list, ...
    TrialRecord.User.holding_frame_list, TrialRecord.User.gen_chasing_frame_list, ...
    TrialRecord.User.gen_grooming_frame_list, TrialRecord.User.gen_mounting_frame_list, ...
    TrialRecord.User.gen_holding_frame_list, TrialRecord.User.chasing_folder, TrialRecord.User.grooming_folder, ...
    TrialRecord.User.mounting_folder, TrialRecord.User.holding_folder, TrialRecord.User.gen_chasing_folder, ...
    TrialRecord.User.gen_grooming_folder, TrialRecord.User.gen_mounting_folder, TrialRecord.User.gen_holding_folder,...
    TrialRecord.User.general_stimulus_list, TrialRecord.User.general_frame_list] = ...
    stimulusList('D:\onedrive\OneDrive - KU Leuven\social_interactions\agent_patient', TrialRecord.User.generalizing);
end

cum_length = cumsum([length(TrialRecord.User.chasing_list) length(TrialRecord.User.gen_chasing_list)...
    length(TrialRecord.User.grooming_list) length(TrialRecord.User.gen_grooming_list)...
    length(TrialRecord.User.mounting_list) length(TrialRecord.User.gen_mounting_list)...
    length(TrialRecord.User.holding_list) length(TrialRecord.User.gen_holding_list)]);

% creating useable stimulus list depending on the switches

if TrialRecord.User.holding_on % || TrialRecord.User.agent_on || TrialRecord.User.patient_on
    stimulus_list = TrialRecord.User.general_stimulus_list;
    frame_list = TrialRecord.User.general_frame_list;
elseif  ~TrialRecord.User.holding_on && TrialRecord.User.mounting_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:cum_length(end-2));
    frame_list = TrialRecord.User.general_frame_list(1, 1:cum_length(end-2));
elseif ~TrialRecord.User.mounting_on && TrialRecord.User.grooming_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:cum_length(end-4));
    frame_list = TrialRecord.User.general_frame_list(1, 1:cum_length(end-4));
elseif ~TrialRecord.User.grooming_on && TrialRecord.User.chasing_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:cum_length(end-6));
    frame_list = TrialRecord.User.general_frame_list(1, 1:cum_length(end-6));
end


%% create an empty structure
if TrialRecord.User.current_sum_categories ~= previous_sum_categories             % this comes dozn to: on start and zhen button added within training
    [TrialRecord.User.structure] = createStructure(stimulus_list, frame_list, cum_length, TrialRecord.User.chasing_folder,...
    TrialRecord.User.gen_chasing_folder, TrialRecord.User.grooming_folder, TrialRecord.User.gen_grooming_folder, ...
    TrialRecord.User.mounting_folder, TrialRecord.User.gen_mounting_folder,...
    TrialRecord.User.holding_folder, TrialRecord.User.gen_holding_folder, TrialRecord.User.category, TrialRecord.User.agent_on);
end
%% create a random condition order with a restriction of max consecutive conditions and a precaution for overlap across structure resets 
if TrialRecord.User.current_sum_buttons ~= previous_sum_buttons
    TrialRecord.User.rnd_condition_order = [];
    [TrialRecord.User.conditions_array, TrialRecord.User.rnd_condition_order] = ...
        conditionOrder(TrialRecord.User.structure, ...
        4, TrialRecord.User.rnd_condition_order, ...
        TrialRecord.User.training_categorization, TrialRecord.User.training_agent_patient);
elseif ~TrialRecord.User.repeat && TrialRecord.User.engaged
    [TrialRecord.User.conditions_array, TrialRecord.User.rnd_condition_order] = ...
        conditionOrder(TrialRecord.User.structure, ...
        4, TrialRecord.User.rnd_condition_order, ...
        TrialRecord.User.training_categorization, TrialRecord.User.training_agent_patient);
end
condition = TrialRecord.User.rnd_condition_order(end);
if length(TrialRecord.User.rnd_condition_order) <= 10
    disp(TrialRecord.User.rnd_condition_order);
else
    disp(TrialRecord.User.rnd_condition_order(end-9:end));
end
disp(TrialRecord.User.conditions_array);
%% given the condition, pick a stimulus that has not yet been completed in the current structure
if ~TrialRecord.User.repeat && TrialRecord.User.engaged || ...
        TrialRecord.User.current_sum_buttons ~= previous_sum_buttons                    % if this, we should just do everything the same as previous trial
    [TrialRecord.User.struct_index] = pickStimulus(condition, TrialRecord.User.structure);
else
    disp('same struct index used');
end
%% set the condition for the timing file
if condition == 1
    TrialRecord.User.chasing = true;
    TrialRecord.NextCondition = 1;
    TrialRecord.User.categorizing = true;
elseif condition == 2
    TrialRecord.User.grooming = true;
    TrialRecord.NextCondition = 2;
    TrialRecord.User.categorizing = true;
elseif condition == 3
    TrialRecord.User.mounting = true;
    TrialRecord.NextCondition = 3;
    TrialRecord.User.categorizing = true;
elseif condition == 4
    TrialRecord.User.holding = true;
    TrialRecord.NextCondition = 4;
    TrialRecord.User.categorizing = true;
elseif condition == 5
    TrialRecord.NextCondition = 5;
    TrialRecord.User.agenting = true;
elseif condition == 6
    TrialRecord.NextCondition = 6;
    TrialRecord.User.patienting = true;
else
    disp('condition not found');
end

TrialRecord.User.movie = strcat('D:\onedrive\OneDrive - KU Leuven\social_interactions\agent_patient\stimuli\',... 
    TrialRecord.User.structure(TrialRecord.User.struct_index).folder, '\', ...
    TrialRecord.User.structure(TrialRecord.User.struct_index).stimuli);     % complete path of the animation
TrialRecord.User.frame = strcat('D:\onedrive\OneDrive - KU Leuven\social_interactions\agent_patient\frames\',... 
    TrialRecord.User.structure(TrialRecord.User.struct_index).folder, '\', ...
    TrialRecord.User.structure(TrialRecord.User.struct_index).frames);      % and frame

if TrialRecord.User.generalizing
    if strncmp(TrialRecord.User.structure(TrialRecord.User.struct_index).folder, 'gen', 3)
        TrialRecord.User.test_trial = true;
        disp(['test_trial' string(TrialRecord.User.test_trial)]);
    else
        TrialRecord.User.test_trial = false;
        disp(['test_trial' string(TrialRecord.User.test_trial)]);
    end
end
% creating condition
C = {'sqr([2 1], [1 0 0], 0, 0, -1)'};
end