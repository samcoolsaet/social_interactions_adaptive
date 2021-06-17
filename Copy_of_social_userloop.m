function [C,timingfile,userdefined_trialholder] = social_userloop(MLConfig,TrialRecord)
%% template
% return values
C = [];
timingfile = 'Copy_of_social_timing.m';                                 % Placeholder, real timing file assigned below.
userdefined_trialholder = '';

persistent timing_filenames_retrieved
    if isempty(timing_filenames_retrieved)
        timing_filenames_retrieved = true;
    return
    end
%% initializing for first trial
TrialRecord.User.start_block = 41;                                               % the progression number to start training with
TrialRecord.User.generalizing = true;

if TrialRecord.CurrentTrialNumber == 0
    TrialRecord.User.random_condition_order = 1;
    TrialRecord.User.random_condition_order_index = 1;
    TrialRecord.User.performance = 0;
    TrialRecord.NextBlock = TrialRecord.User.start_block;
    previous_sum_buttons = 0;
    TrialRecord.User.engaged = true;
    TrialRecord.User.max_fails = 3;
    TrialRecord.User.repeat = false;
    TrialRecord.User.completed_stimuli = 0;
    TrialRecord.User.c_structure_completion = 0;
    TrialRecord.User.a_structure_completion = 0;
    TrialRecord.User.p_structure_completion = 0;
    TrialRecord.User.test_trial_counter = 0;
else
    previous_sum_buttons = TrialRecord.User.current_sum_buttons;      % calculations of previous sum categories
end
%% constants
% progression
TrialRecord.User.blocksize = 20;                                            % The TrialRecord.User.blocksize is the number of animations the monkey has to complete.
                                                                            %%% maybe later create a blocksize as a function of previous performance to quickly skip to his level when starting again.

succes_threshold = 0.80;                                                    % if performance is bigger than or equal to this, progression number + 1
fail_threshold = 0.10;                                                         % if performance is smaller than or equal to this, progression number - 1

TrialRecord.User.size_progression_factor = 20;                              % the number of progression number steps needed to go from start size to end size, used for both category and agent patient

TrialRecord.User.button_progression_factor = ...
    TrialRecord.User.size_progression_factor + 1;                            % number of progression number steps needed to add a category button
                                                                            % progression_trials 
                                                                            
TrialRecord.User.max_block = TrialRecord.User.button_progression_factor * 3 ...
    - 1;                                                                    % last button active + at final size
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
if TrialRecord.User.completed_stimuli == TrialRecord.User.blocksize             % if ze have completed a blocksize of stimuli, evaluate
    indexes_used_c_stimuli = find([TrialRecord.User.structure.c_completed]==1); % find the completed stimuli
    indexes_used_a_stimuli = find([TrialRecord.User.structure.a_completed]==1); % 
    indexes_used_p_stimuli = find([TrialRecord.User.structure.p_completed]==1); %
    fails = [TrialRecord.User.structure(indexes_used_c_stimuli).c_fails...      % isolate the fails field of these completed stimuli
        TrialRecord.User.structure(indexes_used_a_stimuli).a_fails...
        TrialRecord.User.structure(indexes_used_p_stimuli).p_fails];
    corrects = (fails == 0);                                                % correct for the first time means that there are no fails
    TrialRecord.User.performance = mean(corrects);                          % performance is the corrects/completed stimuli
    if TrialRecord.User.performance >= succes_threshold                     % if performance is over the threshold, add a progression number
            TrialRecord.NextBlock = ... 
                TrialRecord.CurrentBlock + 1;
    elseif TrialRecord.User.performance <= fail_threshold                   % if performance is under the threshold and progression number is not already at the min progression number, substract a progression number
        TrialRecord.NextBlock = ... 
            TrialRecord.CurrentBlock - 1;
    end
    [TrialRecord.User.structure(indexes_used_c_stimuli).c_success] = deal(0);   % reset all the completed stimuli
    [TrialRecord.User.structure(indexes_used_c_stimuli).c_fails] = deal(0);     % this way, the data of the used, but not completed ones stays in there
    [TrialRecord.User.structure(indexes_used_c_stimuli).c_completed] = deal(0);
    [TrialRecord.User.structure(indexes_used_a_stimuli).a_success] = deal(0);
    [TrialRecord.User.structure(indexes_used_a_stimuli).a_fails] = deal(0);
    [TrialRecord.User.structure(indexes_used_c_stimuli).a_completed] = deal(0);
    [TrialRecord.User.structure(indexes_used_p_stimuli).p_success] = deal(0);
    [TrialRecord.User.structure(indexes_used_p_stimuli).p_fails] = deal(0);
    [TrialRecord.User.structure(indexes_used_c_stimuli).p_completed] = deal(0);
    disp(['performance:' string(TrialRecord.User.performance)]);
    disp('last blocksize reset in struct');
end

if TrialRecord.NextBlock > TrialRecord.User.max_block
    TrialRecord.NextBlock = TrialRecord.User.max_block;
    disp(['max block reached' string(TrialRecord.User.max_block)]);
elseif TrialRecord.NextBlock < TrialRecord.User.min_block
    TrialRecord.NextBlock = TrialRecord.User.min_block;
    disp(['min block reached' string(TrialRecord.User.min_block)]);
end

% TrialRecord.NextBlock = TrialRecord.User.progression_number;            % blocknumber is now based on progression, so that I can easily keep track of everything

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
    if TrialRecord.User.button_progression >=0
        TrialRecord.User.agent_on = true;
    end
    if TrialRecord.User.button_progression >=1
        TrialRecord.User.patient_on = true;
    end
else
    TrialRecord.User.chasing_on = true;
    TrialRecord.User.grooming_on = true;
    TrialRecord.User.holding_on = true;
    TrialRecord.User.mounting_on = true;
    TrialRecord.User.agent_on = true;
    TrialRecord.User.patient_on = true;
end
if TrialRecord.User.chasing_on || TrialRecord.User.grooming_on || TrialRecord.User.holding_on || TrialRecord.User.mounting_on
    TrialRecord.User.category = true;
else
    TrialRecord.User.category = false;
end
% calculation current sum categories after switches have been altered

TrialRecord.User.current_sum_categories = sum([TrialRecord.User.chasing_on, ... % difference between current and previous sum of categories acts as a 
    TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...               % switch for new stimulus list creation involving new categories and other
    TrialRecord.User.mounting_on,]);
display(TrialRecord.User.current_sum_categories);

TrialRecord.User.current_sum_buttons = sum([TrialRecord.User.chasing_on, ... % difference between current and previous sum of categories acts as a 
    TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...               % switch for new stimulus list creation involving new categories and other
    TrialRecord.User.mounting_on, TrialRecord.User.agent_on, ...                % changes that have to be made when categories are added
    TrialRecord.User.patient_on]);
%% orienting between stimuli and frame files creating individual folder lists and general stim and frame lists
% Do all of this for trial 0 because it would be inefficient to repeat and
% I want these variables to be fixed throughout the run
if TrialRecord.CurrentTrialNumber == 0
    % dir() gives a struct of the contents of the path
    chasing_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\chasing');
    grooming_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\grooming');
    mounting_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\mounting');
    holding_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\holding');
    
    chasing_path = regexp(chasing_struct(1).folder,filesep,'split');
    grooming_path = regexp(grooming_struct(1).folder,filesep,'split');
    mounting_path = regexp(mounting_struct(1).folder,filesep,'split');
    holding_path = regexp(holding_struct(1).folder,filesep,'split');
    
    TrialRecord.User.chasing_folder = chasing_path{1, end};
    TrialRecord.User.grooming_folder = grooming_path{1, end};
    TrialRecord.User.mounting_folder = mounting_path{1, end};
    TrialRecord.User.holding_folder = holding_path{1, end};
    
    % isolating the name field
    TrialRecord.User.chasing_list = {chasing_struct.name};
    TrialRecord.User.grooming_list = {grooming_struct.name};
    TrialRecord.User.mounting_list = {mounting_struct.name};
    TrialRecord.User.holding_list = {holding_struct.name};
    
    % deleting the 2 empty spots from the name field
    TrialRecord.User.chasing_list(1:2) = [];
    TrialRecord.User.grooming_list(1:2) = [];
    TrialRecord.User.mounting_list(1:2) = [];
    TrialRecord.User.holding_list(1:2) = [];
    

    % analogous for the frames
    chasing_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\chasing');
    grooming_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\grooming');
    mounting_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\mounting');
    holding_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\holding');

    TrialRecord.User.chasing_frame_list = {chasing_frame_struct.name};
    TrialRecord.User.grooming_frame_list = {grooming_frame_struct.name};
    TrialRecord.User.mounting_frame_list = {mounting_frame_struct.name};
    TrialRecord.User.holding_frame_list = {holding_frame_struct.name};

    TrialRecord.User.chasing_frame_list(1:2) = [];
    TrialRecord.User.grooming_frame_list(1:2) = [];
    TrialRecord.User.mounting_frame_list(1:2) = [];
    TrialRecord.User.holding_frame_list(1:2) = [];

if TrialRecord.User.generalizing
    gen_chasing_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\gen_chasing');
    gen_grooming_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\gen_grooming');
    gen_mounting_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\gen_mounting');
    gen_holding_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\gen_holding');
    
    gen_chasing_path = regexp(gen_chasing_struct(1).folder,filesep,'split');
    gen_grooming_path = regexp(gen_grooming_struct(1).folder,filesep,'split');
    gen_mounting_path = regexp(gen_mounting_struct(1).folder,filesep,'split');
    gen_holding_path = regexp(gen_holding_struct(1).folder,filesep,'split');
    
    TrialRecord.User.gen_chasing_folder = gen_chasing_path{1, end};
    TrialRecord.User.gen_grooming_folder = gen_grooming_path{1, end};
    TrialRecord.User.gen_mounting_folder = gen_mounting_path{1, end};
    TrialRecord.User.gen_holding_folder = gen_holding_path{1, end};

    TrialRecord.User.gen_chasing_list = {gen_chasing_struct.name};
    TrialRecord.User.gen_grooming_list = {gen_grooming_struct.name};
    TrialRecord.User.gen_mounting_list = {gen_mounting_struct.name};
    TrialRecord.User.gen_holding_list = {gen_holding_struct.name};
    
    TrialRecord.User.gen_chasing_list(1:2) = [];
    TrialRecord.User.gen_grooming_list(1:2) = [];
    TrialRecord.User.gen_mounting_list(1:2) = [];
    TrialRecord.User.gen_holding_list(1:2) = [];
    
    gen_chasing_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\gen_chasing');
    gen_grooming_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\gen_grooming');
    gen_mounting_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\gen_mounting');
    gen_holding_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\gen_holding');
    
    TrialRecord.User.gen_chasing_frame_list = {gen_chasing_frame_struct.name};
    TrialRecord.User.gen_grooming_frame_list = {gen_grooming_frame_struct.name};
    TrialRecord.User.gen_mounting_frame_list = {gen_mounting_frame_struct.name};
    TrialRecord.User.gen_holding_frame_list = {gen_holding_frame_struct.name};

    TrialRecord.User.gen_chasing_frame_list(1:2) = [];
    TrialRecord.User.gen_grooming_frame_list(1:2) = [];
    TrialRecord.User.gen_mounting_frame_list(1:2) = [];
    TrialRecord.User.gen_holding_frame_list(1:2) = [];
else
    TrialRecord.User.gen_chasing_list = [];
    TrialRecord.User.gen_grooming_list = [];
    TrialRecord.User.gen_mounting_list = [];
    TrialRecord.User.gen_holding_list = [];
    
    TrialRecord.User.gen_chasing_frame_list = [];
    TrialRecord.User.gen_grooming_frame_list = [];
    TrialRecord.User.gen_mounting_frame_list = [];
    TrialRecord.User.gen_holding_frame_list = [];
end

    % creating general lists with all the files
    TrialRecord.User.general_stimulus_list = [TrialRecord.User.chasing_list, ...
        TrialRecord.User.gen_chasing_list, TrialRecord.User.grooming_list,...
        TrialRecord.User.gen_grooming_list, TrialRecord.User.mounting_list,...
        TrialRecord.User.gen_mounting_list, TrialRecord.User.holding_list, TrialRecord.User.gen_holding_list]; 
    TrialRecord.User.general_frame_list = [TrialRecord.User.chasing_frame_list,...
        TrialRecord.User.gen_chasing_frame_list, TrialRecord.User.grooming_frame_list,...
        TrialRecord.User.gen_grooming_frame_list,TrialRecord.User.mounting_frame_list,...
        TrialRecord.User.gen_mounting_frame_list, TrialRecord.User.holding_frame_list,...
        TrialRecord.User.gen_holding_frame_list];
end

cum_length = cumsum([length(TrialRecord.User.chasing_list) length(TrialRecord.User.gen_chasing_list)...
    length(TrialRecord.User.grooming_list) length(TrialRecord.User.gen_grooming_list)...
    length(TrialRecord.User.mounting_list) length(TrialRecord.User.gen_mounting_list)...
    length(TrialRecord.User.holding_list) length(TrialRecord.User.gen_holding_list)]);

% creating useable stimulus list depending on the switches

if TrialRecord.User.holding_on || TrialRecord.User.agent_on || TrialRecord.User.patient_on
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
if TrialRecord.User.current_sum_buttons ~= previous_sum_buttons             % this comes dozn to: on start and zhen button added within training
    TrialRecord.User.structure = struct('stimuli', {}, 'frames', {}, 'c_fails', {}, ... 
        'c_success', {},'c_completed', {}, 'a_fails', {}, 'a_success', {}, ...
        'a_completed', {}, 'p_fails', {}, 'p_success', {}, 'p_completed', {}, 'folder', {}, 'condition', {});
    for i = 1:length(stimulus_list)
        TrialRecord.User.structure(i).stimuli = stimulus_list(i);
        TrialRecord.User.structure(i).frames = frame_list(i);
        TrialRecord.User.structure(i).c_fails = 0;
        TrialRecord.User.structure(i).c_success = 0;
        TrialRecord.User.structure(i).c_completed = 0;
        TrialRecord.User.structure(i).a_fails = 0;
        TrialRecord.User.structure(i).a_success = 0;
        TrialRecord.User.structure(i).a_completed = 0;
        TrialRecord.User.structure(i).p_fails = 0;
        TrialRecord.User.structure(i).p_success = 0;
        TrialRecord.User.structure(i).p_completed = 0;
        if i <= cum_length(1)
            TrialRecord.User.structure(i).folder = TrialRecord.User.chasing_folder;
            TrialRecord.User.structure(i).condition = [1 5 6];
        elseif i <= cum_length(2)
            TrialRecord.User.structure(i).folder = TrialRecord.User.gen_chasing_folder;
            TrialRecord.User.structure(i).condition = [1 5 6];
        elseif i <= cum_length(3)
            TrialRecord.User.structure(i).folder = TrialRecord.User.grooming_folder;
            TrialRecord.User.structure(i).condition = [2 5 6];
        elseif i <= cum_length(4)
            TrialRecord.User.structure(i).folder = TrialRecord.User.gen_grooming_folder;
            TrialRecord.User.structure(i).condition = [2 5 6];
        elseif i <= cum_length(5)
            TrialRecord.User.structure(i).folder = TrialRecord.User.mounting_folder;
            TrialRecord.User.structure(i).condition = [3 5 6];
        elseif i <= cum_length(6)
            TrialRecord.User.structure(i).folder = TrialRecord.User.gen_mounting_folder;
            TrialRecord.User.structure(i).condition = [3 5 6];
        elseif i <= cum_length(7)
            TrialRecord.User.structure(i).folder = TrialRecord.User.holding_folder;
            TrialRecord.User.structure(i).condition = [4 5 6];
        elseif i <= cum_length(8)
            TrialRecord.User.structure(i).folder = TrialRecord.User.gen_holding_folder;
            TrialRecord.User.structure(i).condition = [4 5 6];
        end
    end
    disp('new structure made');
end
%% create a random condition order with a restriction of max consecutive conditions and a precaution for overlap across structure resets 

if TrialRecord.User.current_sum_buttons ~= previous_sum_buttons
    TrialRecord.User.rnd_condition_order = [];
    [TrialRecord.User.conditions_array, TrialRecord.User.conditions] = initConditionOrder(TrialRecord.User.training_categorization,...
        TrialRecord.User.training_agent_patient, TrialRecord.User.current_sum_buttons, ...
        TrialRecord.User.chasing_list, ...
        TrialRecord.User.gen_chasing_list, TrialRecord.User.grooming_list,...
        TrialRecord.User.gen_grooming_list, TrialRecord.User.mounting_list,...
        TrialRecord.User.gen_mounting_list,...
        TrialRecord.User.holding_list, TrialRecord.User.gen_holding_list);
elseif sum(TrialRecord.User.conditions_array(2,:)) == 0
    [TrialRecord.User.conditions_array, TrialRecord.User.conditions] = initConditionOrder(TrialRecord.User.training_categorization,...
        TrialRecord.User.training_agent_patient, TrialRecord.User.current_sum_buttons,...
        TrialRecord.User.chasing_list, ...
        TrialRecord.User.gen_chasing_list, TrialRecord.User.grooming_list,...
        TrialRecord.User.gen_grooming_list, TrialRecord.User.mounting_list,...
        TrialRecord.User.gen_mounting_list,...
        TrialRecord.User.holding_list, TrialRecord.User.gen_holding_list);    
end
if ~TrialRecord.User.repeat && TrialRecord.User.engaged
    [TrialRecord.User.conditions_array, TrialRecord.User.rnd_condition_order] = ...
        conditionOrder(TrialRecord.User.conditions_array, TrialRecord.User.conditions,...
        TrialRecord.User.max_fails, TrialRecord.User.rnd_condition_order);
end
disp(TrialRecord.User.rnd_condition_order);
condition = TrialRecord.User.rnd_condition_order(1);
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

TrialRecord.User.movie = strcat('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\',... 
    TrialRecord.User.structure(TrialRecord.User.struct_index).folder, '\', ...
    TrialRecord.User.structure(TrialRecord.User.struct_index).stimuli);     % complete path of the animation
TrialRecord.User.frame = strcat('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\',... 
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