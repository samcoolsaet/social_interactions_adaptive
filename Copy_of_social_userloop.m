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
TrialRecord.User.start_progression_number = 11;                                               % the progression number to start training with

if TrialRecord.CurrentTrialNumber == 0
    TrialRecord.User.random_condition_order = 1;
    TrialRecord.User.random_condition_order_index = 1;
    TrialRecord.User.performance = 0;
    TrialRecord.User.progression_number = TrialRecord.User.start_progression_number;
    previous_sum_categories = 0;
    TrialRecord.User.engaged = true;
    TrialRecord.User.max_fails = 3;
    TrialRecord.User.repeat = false;
    TrialRecord.User.completed_stimuli = 0;
    TrialRecord.User.c_structure_completion = 0;
    TrialRecord.User.a_structure_completion = 0;
    TrialRecord.User.p_structure_completion = 0;
else
    previous_sum_categories = TrialRecord.User.current_sum_categories;      % calculations of previous sum categories
end
%% constants
max_repeats_condition = 3;
% progression
TrialRecord.User.blocksize = 5;                                                              % The TrialRecord.User.blocksize is the number of animationsthe monkey has to complete.a block is the elementary unit, a block determines whether the progression number increases/decreases/stays the same.
%%% maybe later create a blocksize as a function of previous performance to quickly skip to his level when starting again.                                                                            % block def: a set number of stimuli that have been showed for the first time
succes_threshold = 0.80;                                                    % if performance is bigger than or equal to this, progression number + 1
fail_threshold = 0;                                                         % if performance is smaller than or equal to this, progression number - 1
TrialRecord.User.size_progression_factor = 10;                              % the number of progression number steps needed to go from start size to end size, used for both category and agent patient
category_progression_factor = TrialRecord.User.size_progression_factor + 1; % number of progression number steps needed to add a category button
agent_patient_progression_factor = TrialRecord.User.size_progression_factor + 2; % number of progression number steps needed to add a patient button

% progression_trials = TrialRecord.User.blocksize * TrialRecord.User.size_progression_factor;  % the number of trials needed to get to the final size
% consolidation_trials = TrialRecord.User.blocksize * ...
%     (category_progression_factor-TrialRecord.User.size_progression_factor); % the number of trials to consolidate the current size progression 

TrialRecord.User.max_c_progression_number = category_progression_factor * 2 ...
    + TrialRecord.User.size_progression_factor;                               % last button active + at final size
% max_ap_progression_number =agent_patient_progression_factor * 1 + ...
%     TrialRecord.User.size_progression_factor;
min_c_progression_number = 0;
% max_ap_progression_number =agent_patient_progression_factor * 1 + ...
%     TrialRecord.User.size_progression_factor;

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
if TrialRecord.User.completed_stimuli == TrialRecord.User.blocksize  % find a way to carry over the completed stim if the structure resets   
    indexes_used_c_stimuli = find([TrialRecord.User.structure.c_completed]==1);
    indexes_used_a_stimuli = find([TrialRecord.User.structure.a_completed]==1);
    indexes_used_p_stimuli = find([TrialRecord.User.structure.p_completed]==1);
    fails = [TrialRecord.User.structure(indexes_used_c_stimuli).c_fails...
        TrialRecord.User.structure(indexes_used_a_stimuli).a_fails...
        TrialRecord.User.structure(indexes_used_p_stimuli).p_fails];
    corrects = (fails == 0);
    TrialRecord.User.performance = mean(corrects);
    if TrialRecord.User.performance >= succes_threshold                     % if performance is over the threshold, add a progression number
            TrialRecord.User.progression_number = ... 
                TrialRecord.User.progression_number + 1;
    elseif TrialRecord.User.performance <= fail_threshold                   % if performance is under the threshold and progression number is not already at the min progression number, substract a progression number
        TrialRecord.User.progression_number = ... 
            TrialRecord.User.progression_number - 1;
    end
    [TrialRecord.User.structure(indexes_used_c_stimuli).c_success] = deal(0);
    [TrialRecord.User.structure(indexes_used_c_stimuli).c_fails] = deal(0);
    [TrialRecord.User.structure(indexes_used_c_stimuli).c_completed] = deal(0);
    [TrialRecord.User.structure(indexes_used_a_stimuli).a_success] = deal(0);
    [TrialRecord.User.structure(indexes_used_a_stimuli).a_fails] = deal(0);
    [TrialRecord.User.structure(indexes_used_c_stimuli).a_completed] = deal(0);
    [TrialRecord.User.structure(indexes_used_p_stimuli).p_success] = deal(0);
    [TrialRecord.User.structure(indexes_used_p_stimuli).p_fails] = deal(0);
    [TrialRecord.User.structure(indexes_used_c_stimuli).p_completed] = deal(0);
    disp('last blocksize reset in struct');
end
TrialRecord.NextBlock = TrialRecord.User.progression_number + 1;            
if TrialRecord.User.progression_number > TrialRecord.User.max_c_progression_number
    TrialRecord.User.progression_number = TrialRecord.User.max_c_progression_number;
    disp('max progression number reached');
elseif TrialRecord.User.progression_number < min_c_progression_number
    TrialRecord.User.progression_number = min_c_progression_number;
    disp('min progression number reached');
end
% setting independant category and button progression based on progression
% number
TrialRecord.User.category_progression = ...                                 % the category progression factor, which should be at least bigger than than the size progression factor in order 
    TrialRecord.User.progression_number / ...                               % in order to go through the complete size evolution before adding a category, determines the number of progression
    (category_progression_factor);                                          % number steps needed to increase category progression + 1
TrialRecord.User.agent_patient_progression = ...                            % analogous to category
    TrialRecord.User.progression_number / ... 
    (agent_patient_progression_factor);


if TrialRecord.User.category_progression <= 4 && ...                        % as long as not all the buttons are unlocked, reset size progression when new button is added
        TrialRecord.User.training_categorization
    TrialRecord.User.size_progression = ...                                 % something not right check this
        mod(TrialRecord.User.progression_number, ...
        category_progression_factor);                                       
end
if TrialRecord.User.agent_patient_progression <= 2 && ...                   % analogous
        TrialRecord.User.training_agent_patient
    TrialRecord.User.size_progression = ... 
        mod(TrialRecord.User.progression_number, ... 
        TrialRecord.User.size_progression_factor);
end

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
end
% calculation current sum categories after switches have been altered
TrialRecord.User.current_sum_categories = sum([TrialRecord.User.chasing_on, ... % difference between current and previous sum of categories acts as a 
    TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...               % switch for new stimulus list creation involving new categories and other
    TrialRecord.User.mounting_on,]);

% TrialRecord.User.current_sum_buttons : check AP script for this

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

    % creating general lists with all the files
    TrialRecord.User.general_stimulus_list = [TrialRecord.User.chasing_list, TrialRecord.User.grooming_list, TrialRecord.User.mounting_list, TrialRecord.User.holding_list]; 
    TrialRecord.User.general_frame_list = [TrialRecord.User.chasing_frame_list, TrialRecord.User.grooming_frame_list, TrialRecord.User.mounting_frame_list, TrialRecord.User.holding_frame_list];
end

% creating useable stimulus list depending on the switches
if TrialRecord.User.holding_on || TrialRecord.User.agent_on || TrialRecord.User.patient_on
    stimulus_list = TrialRecord.User.general_stimulus_list;
    frame_list = TrialRecord.User.general_frame_list;
elseif  ~TrialRecord.User.holding_on && TrialRecord.User.mounting_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:(end-length(TrialRecord.User.holding_list)));
    frame_list = TrialRecord.User.general_frame_list(1, 1:(end-length(TrialRecord.User.holding_frame_list)));
elseif ~TrialRecord.User.mounting_on && TrialRecord.User.grooming_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:(length(TrialRecord.User.chasing_list)+length(TrialRecord.User.grooming_list)));
    frame_list = TrialRecord.User.general_frame_list(1, 1:(length(TrialRecord.User.chasing_frame_list)+length(TrialRecord.User.grooming_frame_list)));
elseif ~TrialRecord.User.grooming_on && TrialRecord.User.chasing_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:length(TrialRecord.User.chasing_list));
    frame_list = TrialRecord.User.general_frame_list(1, 1:length(TrialRecord.User.chasing_frame_list));
end


if TrialRecord.User.current_sum_categories ~= previous_sum_categories
    TrialRecord.User.structure = struct('stimuli', {}, 'frames', {}, 'c_fails', {}, ... 
        'c_success', {},'c_completed', {}, 'a_fails', {}, 'a_success', {}, ...
        'a_completed', {}, 'p_fails', {}, 'p_success', {}, 'p_completed', {}, 'folder', {}, 'condition', {});
    index = 1;
    while index ~= length(stimulus_list)+1
        TrialRecord.User.structure(index).stimuli = stimulus_list(index);
        TrialRecord.User.structure(index).frames = frame_list(index);
        TrialRecord.User.structure(index).c_fails = 0;
        TrialRecord.User.structure(index).c_success = 0;
        TrialRecord.User.structure(index).c_completed = 0;
        TrialRecord.User.structure(index).a_fails = 0;
        TrialRecord.User.structure(index).a_success = 0;
        TrialRecord.User.structure(index).a_completed = 0;
        TrialRecord.User.structure(index).p_fails = 0;
        TrialRecord.User.structure(index).p_success = 0;
        TrialRecord.User.structure(index).p_completed = 0;
        if index <= length(TrialRecord.User.chasing_list)
            TrialRecord.User.structure(index).folder = 'chasing';
            TrialRecord.User.structure(index).condition = [1 5 6];
        elseif index <= length(TrialRecord.User.chasing_list) + ... 
                length(TrialRecord.User.grooming_list)
            TrialRecord.User.structure(index).folder = 'grooming';
            TrialRecord.User.structure(index).condition = [2 5 6];
        elseif index <= length(TrialRecord.User.chasing_list) + ... 
                length(TrialRecord.User.grooming_list) + length(TrialRecord.User.mounting_list)
            TrialRecord.User.structure(index).folder = 'mounting';
            TrialRecord.User.structure(index).condition = [3 5 6];
        elseif index <= length(TrialRecord.User.general_stimulus_list)
            TrialRecord.User.structure(index).folder = 'holding';
            TrialRecord.User.structure(index).condition = [4 5 6];
        end
        index = index+1;
    end
    disp('new structure made');
end
if (TrialRecord.User.random_condition_order_index...
        == length(TrialRecord.User.random_condition_order)) && ...
        (~TrialRecord.User.repeat) && (TrialRecord.User.engaged)
    condition_order = [];
    if TrialRecord.User.training_categorization % [TrialRecord.User.structure.condition(1)]  [TrialRecord.User.structure(1).condition(1)]
        for i = 1:length(TrialRecord.User.structure)
            condition_order(end+1) = [TrialRecord.User.structure(i).condition(1)];
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
    while ~restricted
        TrialRecord.User.random_condition_order = condition_order(randperm(length(condition_order)));
        TrialRecord.User.random_condition_order_index = 0;
        index2 = 1;
        repetitions = 0;
        while index2 ~= (length(TrialRecord.User.random_condition_order)-(max_repeats_condition-1))
            if TrialRecord.User.random_condition_order(index2) == TrialRecord.User.random_condition_order(index2+1)...
                    && TrialRecord.User.random_condition_order(index2) == TrialRecord.User.random_condition_order(index2+2)...
                    && TrialRecord.User.random_condition_order(index2) == TrialRecord.User.random_condition_order(index2+3)
                repetitions = repetitions + 1;
            end
%             if trying to limit random condition order production so that
%             it does not error.
%                 [TrialRecord.User.structure.c_completed]==1
%             end
            index2 = index2 + 1;
        end
        if repetitions == 0
            restricted = true;
        end
    end
    disp('condition order reset');
else
    disp('did not reset random condition order');
end
disp(TrialRecord.User.random_condition_order);
% determine categorizing, agent or patient ( codes 1,2 and 3)

if ~TrialRecord.User.repeat && TrialRecord.User.engaged                     % engaged refers to return when time limit for engagement scene is reached
    TrialRecord.User.random_condition_order_index = TrialRecord.User.random_condition_order_index + 1;
    disp(['random condition order index', TrialRecord.User.random_condition_order_index]);
else
    disp('repeat');
end

condition = TrialRecord.User.random_condition_order(TrialRecord.User.random_condition_order_index);
if ~TrialRecord.User.repeat && TrialRecord.User.engaged
    switch condition % shouldn't do all of this when repeating, right?
        case 1 % it's in case 1 when it should not be!!! all opf the condition 1 have already been completed, so the problem is: why condition == 1
            index3 = 1;
            indexes_c_incomplete = [];
            while index3 ~= length(TrialRecord.User.structure) + 1
                if strcmp(TrialRecord.User.structure(index3).folder, 'chasing')...
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
                if strcmp(TrialRecord.User.structure(index3).folder, 'grooming')...
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
                if strcmp(TrialRecord.User.structure(index3).folder, 'mounting')...
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
                if strcmp(TrialRecord.User.structure(index3).folder, 'holding')...
                        && TrialRecord.User.structure(index3).c_completed == 0
                    indexes_c_incomplete(end+1) = index3;
                end
                index3 = index3 + 1;
            end
            index_index = randperm(length(indexes_c_incomplete), 1);
            TrialRecord.User.struct_index = indexes_c_incomplete(index_index);
        case 5
            indexes_a_incomplete = find([TrialRecord.User.structure.a_completed==0]);
            index_index = randperm(length(indexes_a_incomplete), 1);
            TrialRecord.User.struct_index = indexes_a_incomplete(index_index);
        case 6
            indexes_p_incomplete = find([TrialRecord.User.structure.p_completed==0]);
            index_index = randperm(length(indexes_p_incomplete), 1);
            TrialRecord.User.struct_index = indexes_p_incomplete(index_index);
        otherwise
            disp('indexing into structure failed');
    end
else
    disp('same struct index used');
end

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

% if ~TrialRecord.User.training_agent_patient
%     switch question
%         case 1
%             if strncmpi('chas', TrialRecord.User.structure(TrialRecord.User.struct_index).stimuli, 4)    % check for title of the animation to determine actual category
%                 TrialRecord.User.chasing = true;
%                 TrialRecord.NextCondition = 1;
%             elseif strncmpi('groom', TrialRecord.User.structure(TrialRecord.User.struct_index).stimuli, 5)
%                 TrialRecord.User.grooming = true;
%                 TrialRecord.NextCondition = 2;
%             elseif strncmpi('mount', TrialRecord.User.structure(TrialRecord.User.struct_index).stimuli, 5)
%                 TrialRecord.User.mounting = true;
%                 TrialRecord.NextCondition = 3;
%             elseif strncmpi('hold', TrialRecord.User.structure(TrialRecord.User.struct_index).stimuli, 4)
%                 TrialRecord.User.holding = true;
%                 TrialRecord.NextCondition = 4;
%             end
%             TrialRecord.User.categorizing = true;
%         case 2
%             TrialRecord.NextCondition = 5;
%             TrialRecord.User.agenting = true;
%         case 3
%             TrialRecord.NextCondition = 6;
%             TrialRecord.User.patienting = true;
%     end
% else
%     switch question
%         case 1
%             TrialRecord.NextCondition = 5;
%             TrialRecord.User.agenting = true;
%         case 2
%             TrialRecord.NextCondition = 6;
%             TrialRecord.User.patienting = true;
%     end
% end

TrialRecord.User.movie = strcat(pwd, '\stimuli\', ... 
    TrialRecord.User.structure(TrialRecord.User.struct_index).folder, '\', ...
    TrialRecord.User.structure(TrialRecord.User.struct_index).stimuli);     % complete path of the animation
TrialRecord.User.frame = strcat(pwd,'\frames\', ... 
    TrialRecord.User.structure(TrialRecord.User.struct_index).folder, '\', ...
    TrialRecord.User.structure(TrialRecord.User.struct_index).frames);      % and frame

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for frame...
% % img_size in degrees = 15*9, frames sizes (x, y), locations
% % open the file
% fid=fopen('frames.txt'); 
% % set linenum to the desired line number that you want to import
% linenum = 1;
% % use '%s' if you want to read in the entire line or use '%f' if you want to read only the first numeric value
% C = textscan(fid,'%s',4, 'delimiter',';', 'headerlines',linenum-1)
% dimensions = C{1, 1}{2, 1}
% x_degree = C{1, 1}{3, 1}
% y_degree = C{1, 1}{4, 1}
% frewind(fid)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creating condition
C = {'sqr([2 1], [1 0 0], 0, 0, -1)'};
end
