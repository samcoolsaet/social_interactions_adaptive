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
TrialRecord.User.start_block = 40;                                               % the progression number to start training with
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
%     TrialRecord.NextBlock = TrialRecord.CurrentBlock;
end
%% constants
max_repeats_condition = 3;
% progression
TrialRecord.User.blocksize = 20;                                            % The TrialRecord.User.blocksize is the number of animations the monkey has to complete.
                                                                            %%% maybe later create a blocksize as a function of previous performance to quickly skip to his level when starting again.

succes_threshold = 0.80;                                                    % if performance is bigger than or equal to this, progression number + 1
fail_threshold = 0.10;                                                         % if performance is smaller than or equal to this, progression number - 1

TrialRecord.User.size_progression_factor = 20;                              % the number of progression number steps needed to go from start size to end size, used for both category and agent patient

TrialRecord.User.category_progression_factor = ...
    TrialRecord.User.size_progression_factor + 1;                            % number of progression number steps needed to add a category button
% TrialRecord.User.agent_patient_progression_factor = ...
%     TrialRecord.User.size_progression_factor + 1;                           % number of progression number steps needed to add a patient button

                                                                            % progression_trials % the number of trials needed to get to the final size
                                                                            % consolidation_trials = the number of trials to consolidate the current size progression,
                                                                            % is the difference between size and category progression * progression number 
TrialRecord.User.max_c_progression_number = TrialRecord.User.category_progression_factor * 2 ...
    - 1;                                                                    % last button active + at final size
% TrialRecord.User.max_ap_progression_number = TrialRecord.User.agent_patient_progression_factor * 1 + ...
%     TrialRecord.User.size_progression_factor;
TrialRecord.User.min_c_progression_number = TrialRecord.User.start_block;   % at leat category progression factor because I never want to show 1 button again
% TrialRecord.User.min_ap_progression_number = TrialRecord.User.category_progression_factor;

% training
TrialRecord.User.training_categorization = true;                            % complete task or training
TrialRecord.User.training_agent_patient = false;

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

if TrialRecord.User.training_categorization
    if TrialRecord.NextBlock > TrialRecord.User.max_c_progression_number
        TrialRecord.NextBlock = TrialRecord.User.max_c_progression_number;
        disp(['max c progression number reached' string(TrialRecord.User.max_c_progression_number)]);
    elseif TrialRecord.NextBlock < TrialRecord.User.min_c_progression_number
        TrialRecord.NextBlock = TrialRecord.User.min_c_progression_number;
        disp(['min c progression number reached' string(TrialRecord.User.min_c_progression_number)]);
    end
elseif TrialRecord.User.training_agent_patient
    if TrialRecord.NextBlock > TrialRecord.User.max_c_progression_number
        TrialRecord.NextBlock = TrialRecord.User.max_c_progression_number;
        disp(['max c progression number reached' string(TrialRecord.User.max_c_progression_number)]);
    elseif TrialRecord.NextBlock < TrialRecord.User.min_c_progression_number
        TrialRecord.NextBlock = TrialRecord.User.min_c_progression_number;
        disp(['min c progression number reached' string(TrialRecord.User.min_c_progression_number)]);
    end
%     if TrialRecord.NextBlock > TrialRecord.User.max_ap_progression_number
%         TrialRecord.NextBlock = TrialRecord.User.max_ap_progression_number;
%         disp(['max ap progression number reached' string(TrialRecord.User.max_ap_progression_number)]);
%     elseif TrialRecord.NextBlock < TrialRecord.User.min_ap_progression_number
%         TrialRecord.NextBlock = TrialRecord.User.min_ap_progression_number;
%         disp(['min ap progression number reached' string(TrialRecord.User.min_ap_progression_number)]);
%     end
end

% TrialRecord.NextBlock = TrialRecord.User.progression_number;            % blocknumber is now based on progression, so that I can easily keep track of everything

% setting independant category and button progression based on progression
% number
TrialRecord.User.category_progression = ...                                 % the category progression factor, which should be at least bigger than the size progression factor in order 
    TrialRecord.NextBlock / ...                               % in order to go through the complete size evolution before adding a category, determines the number of progression
    (TrialRecord.User.category_progression_factor);                                          % number steps needed to increase category progression + 1
% TrialRecord.User.agent_patient_progression = ...                            % analogous to category
%     TrialRecord.NextBlock / ... 
%     (TrialRecord.User.agent_patient_progression_factor);


% if TrialRecord.User.category_progression < 4 && ...                         % as long as not all the buttons are unlocked, reset size progression when new button is added
%         TrialRecord.User.training_categorization
%     TrialRecord.User.size_progression = ...                                 
%         mod(TrialRecord.CurrentBlock, ...
%         TrialRecord.User.category_progression_factor);                                       
% end
% if TrialRecord.User.agent_patient_progression < 2 && ...                    % analogous
%         TrialRecord.User.training_agent_patient
    TrialRecord.User.size_progression = ... 
        mod(TrialRecord.NextBlock, ... 
        TrialRecord.User.category_progression_factor);
% end

%% toggling conditions on
% training progression switches. at the end ( if not training ) all switches
% are turned on 
if TrialRecord.User.training_categorization
    if TrialRecord.User.category_progression >=0
        TrialRecord.User.chasing_on = true;
    end
    if TrialRecord.User.category_progression >=1
        TrialRecord.User.grooming_on = true;
    end
    if TrialRecord.User.category_progression >=2
        TrialRecord.User.mounting_on = true;
    end
    if TrialRecord.User.category_progression >=3
        TrialRecord.User.holding_on = true;
    end
elseif TrialRecord.User.training_agent_patient
    if TrialRecord.User.agent_patient_progression >=0
        TrialRecord.User.agent_on = true;
    end
    if TrialRecord.User.agent_patient_progression >=1
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
% if (~TrialRecord.User.repeat) && (TrialRecord.User.engaged)
TrialRecord.User.current_sum_buttons = sum([TrialRecord.User.chasing_on, ... % difference between current and previous sum of categories acts as a 
    TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...               % switch for new stimulus list creation involving new categories and other
    TrialRecord.User.mounting_on, TrialRecord.User.agent_on, ...                % changes that have to be made when categories are added
    TrialRecord.User.patient_on]);
% end
%% orienting between stimuli and frame files creating individual folder lists and general stim and frame lists
% Do all of this for trial 0 because it would be inefficient to repeat and
% I want these variables to be fixed throughout the run
if TrialRecord.CurrentTrialNumber == 0
    % dir() gives a struct of the contents of the path
    % I CAN LINK THE GENERALIZATION STIMULI TO A DIFFERENT FOLDER AND THEN
    % MAKE A LINK WITH THE FOLDER IN THE STRUCT
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
% if TrialRecord.User.holding_on || TrialRecord.User.agent_on || TrialRecord.User.patient_on
%     stimulus_list = TrialRecord.User.general_stimulus_list;
%     frame_list = TrialRecord.User.general_frame_list;
% elseif  ~TrialRecord.User.holding_on && TrialRecord.User.mounting_on
%     stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:(end-length(TrialRecord.User.holding_list)));
%     frame_list = TrialRecord.User.general_frame_list(1, 1:(end-length(TrialRecord.User.holding_frame_list)));
% elseif ~TrialRecord.User.mounting_on && TrialRecord.User.grooming_on
%     stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:(length(TrialRecord.User.chasing_list)+length(TrialRecord.User.grooming_list)));
%     frame_list = TrialRecord.User.general_frame_list(1, 1:(length(TrialRecord.User.chasing_frame_list)+length(TrialRecord.User.grooming_frame_list)));
% elseif ~TrialRecord.User.grooming_on && TrialRecord.User.chasing_on
%     stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:length(TrialRecord.User.chasing_list));
%     frame_list = TrialRecord.User.general_frame_list(1, 1:length(TrialRecord.User.chasing_frame_list));
% end

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
%         if i <= length(TrialRecord.User.chasing_list)
%             TrialRecord.User.structure(i).folder = 'chasing';
%             TrialRecord.User.structure(i).condition = [1 5 6];
%         elseif i <= length(TrialRecord.User.chasing_list) + ... 
%                 length(TrialRecord.User.grooming_list)
%             TrialRecord.User.structure(i).folder = 'grooming';
%             TrialRecord.User.structure(i).condition = [2 5 6];
%         elseif i <= length(TrialRecord.User.chasing_list) + ... 
%                 length(TrialRecord.User.grooming_list) + length(TrialRecord.User.mounting_list)
%             TrialRecord.User.structure(i).folder = 'mounting';
%             TrialRecord.User.structure(i).condition = [3 5 6];
%         elseif i <= length(TrialRecord.User.general_stimulus_list)
%             TrialRecord.User.structure(i).folder = 'holding';
%             TrialRecord.User.structure(i).condition = [4 5 6];
%         end
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
disp(TrialRecord.User.random_condition_order);

if (~TrialRecord.User.repeat && TrialRecord.User.engaged) || ...
        TrialRecord.User.current_sum_buttons ~= previous_sum_buttons        % engaged refers to return when time limit for engagement scene is reached
    TrialRecord.User.random_condition_order_index = TrialRecord.User.random_condition_order_index + 1;
else
    disp('repeat');
end
disp(TrialRecord.User.random_condition_order_index);

condition = TrialRecord.User.random_condition_order(TrialRecord.User.random_condition_order_index);
%% given the condition, pick a stimulus that has not yet been completed in the current structure
if ~TrialRecord.User.repeat && TrialRecord.User.engaged || ...
        TrialRecord.User.current_sum_buttons ~= previous_sum_buttons                    % if this, we should just do everything the same as previous trial
    switch condition
        case 1
            index3 = 1;
            indexes_c_incomplete = [];
            while index3 ~= length(TrialRecord.User.structure) + 1          % just iterate over the structure and see which ones are still available (not completed), given the condition
                if (strcmp(TrialRecord.User.structure(index3).folder, 'chasing') || ...
                        strcmp(TrialRecord.User.structure(index3).folder, 'gen_chasing'))...
                        && TrialRecord.User.structure(index3).c_completed == 0
                    indexes_c_incomplete(end+1) = index3;
                end
                index3 = index3 + 1;
            end
            index_index = randperm(length(indexes_c_incomplete), 1);
            TrialRecord.User.struct_index = indexes_c_incomplete(index_index);
        case 2
            index3 = 1;
            indexes_c_incomplete = [];
            while index3 ~= length(TrialRecord.User.structure) + 1
                if (strcmp(TrialRecord.User.structure(index3).folder, 'grooming') || ...
                        strcmp(TrialRecord.User.structure(index3).folder, 'gen_grooming'))...
                        && TrialRecord.User.structure(index3).c_completed == 0
                    indexes_c_incomplete(end+1) = index3;
                end
                index3 = index3 + 1;
            end
            index_index = randperm(length(indexes_c_incomplete), 1);
            TrialRecord.User.struct_index = indexes_c_incomplete(index_index);
        case 3
            index3 = 1;
            indexes_c_incomplete = [];
            while index3 ~= length(TrialRecord.User.structure) + 1
                if (strcmp(TrialRecord.User.structure(index3).folder, 'mounting') || ...
                        strcmp(TrialRecord.User.structure(index3).folder, 'gen_mounting'))...
                        && TrialRecord.User.structure(index3).c_completed == 0
                    indexes_c_incomplete(end+1) = index3;
                end
                index3 = index3 + 1;
            end
            index_index = randperm(length(indexes_c_incomplete), 1);
            TrialRecord.User.struct_index = indexes_c_incomplete(index_index);
        case 4
            index3 = 1;
            indexes_c_incomplete = [];
            while index3 ~= length(TrialRecord.User.structure) + 1
                if (strcmp(TrialRecord.User.structure(index3).folder, 'holding') || ...
                        strcmp(TrialRecord.User.structure(index3).folder, 'gen_holding'))...
                        && TrialRecord.User.structure(index3).c_completed == 0
                    indexes_c_incomplete(end+1) = index3;
                end
                index3 = index3 + 1;
            end
            index_index = randperm(length(indexes_c_incomplete), 1);
            TrialRecord.User.struct_index = indexes_c_incomplete(index_index);
        case 5
            indexes_a_incomplete = find([TrialRecord.User.structure.a_completed]==0);
            index_index = randperm(length(indexes_a_incomplete), 1);
            TrialRecord.User.struct_index = indexes_a_incomplete(index_index);
        case 6
            indexes_p_incomplete = find([TrialRecord.User.structure.p_completed]==0);
            index_index = randperm(length(indexes_p_incomplete), 1);
            TrialRecord.User.struct_index = indexes_p_incomplete(index_index);
        otherwise
            disp('indexing into structure failed');
    end
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