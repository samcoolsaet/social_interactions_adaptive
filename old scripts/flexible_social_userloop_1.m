function [C,timingfile,userdefined_trialholder] = social_userloop(MLConfig,TrialRecord)
%% template
% return values
C = [];
timingfile = 'flexible_touch_of_project.m';                                 % Placeholder, real timing file assigned below.
userdefined_trialholder = '';

persistent timing_filenames_retrieved
    if isempty(timing_filenames_retrieved)
        timing_filenames_retrieved = true;
    return
    end
%% constants
% progression
TrialRecord.User.blocksize = 2;                                                              % The blocksize is the number of animations that will be shown for the first time.a block is the elementary unit, a block determines whether the progression number increases/decreases/stays the same.
                                                                            % block def: a set number of stimuli that have been showed for the first time
TrialRecord.User.size_progression_factor = ...                              % the number of progression number steps needed to go from start size to end size, used for both category and agent patient
    2;
category_progression_factor = 4;                                            % number of progression number steps needed to add a category button
agent_patient_progression_factor = 4;                                       % number of progression number steps needed to add a patient button
progression_trials = TrialRecord.User.blocksize * TrialRecord.User.size_progression_factor;  % the number of trials needed to get to the final size
consolidation_trials = TrialRecord.User.blocksize * ...
    (category_progression_factor-TrialRecord.User.size_progression_factor); % the number of trials to consolidate the current size progression 

start_progression_number = 0;                                               % the progression number to start training with

succes_threshold = 0.80;                                                    % if performance is bigger than or equal to this, progression number + 1
fail_threshold = 0;                                                         % if performance is smaller than or equal to this, progression number - 1
TrialRecord.User.max_c_progression_number = category_progression_factor * 4 - 1;                               % last button active + at final size
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
TrialRecord.User.agent_on = false;
TrialRecord.User.patient_on = false;

TrialRecord.User.categorizing = false;
TrialRecord.User.agenting = false;
TrialRecord.User.patienting = false;

TrialRecord.User.grooming = false;
TrialRecord.User.chasing = false;
TrialRecord.User.holding = false;
TrialRecord.User.mounting = false;
%% initializing for first trial
if TrialRecord.CurrentTrialNumber == 0
    TrialRecord.User.stimulus_sequence_index = 0; % 1
    TrialRecord.User.no_wrong_repeats = -1;
    TrialRecord.User.performance = 0;
    TrialRecord.User.progression_number = start_progression_number;
    TrialRecord.User.repeat = false;                                        
    previous_sum_categories = 0;
    TrialRecord.User.repetitions = 0;
else
    previous_sum_categories = TrialRecord.User.current_sum_categories;      % calculations of previous sum categories
end


%% determining next block and difficulty based on a general progression number %%%%%% maybe create a vector with the length of trialerrors but displaying the stimulus sequence numbers, this way I can keep track of actual fails and just going on when failing because the number of repeats hits the limit
% % counting number of repeats per block
% % %check this with new index stuff at 0 trials index is 0
% % no_repeats_total = TrialRecord.CurrentTrialWithinBlock - blocksize;
% if mod(TrialRecord.User.stimulus_sequence_index, TrialRecord.User.blocksize) == 0 ...      % after previous block, do the following. does't work with blokcsize = 1
%         && TrialRecord.CurrentTrialNumber ~=0 && ...
%         ~TrialRecord.User.repeat                                            % stim seq index to not keep repeats into account
%     boolean_mistakes_per_block = TrialRecord.TrialErrors...                 % convert the trialerrors vector into a boolean vector
%         (end-TrialRecord.CurrentTrialWithinBlock+1 : end) ~= 0;             
%     no_first_time_mistakes = 0;                                             % init the number of first time mistakes
%     index = 1;                                                              % init the index
%     while index ~= length(boolean_mistakes_per_block)                       % while we haven't ran over the complete boolean vector
%         if boolean_mistakes_per_block(index) == 1 && ...                    % a 1 will always be followed by a zero because the a wrong trial repeats until the correct answer is given
%                 boolean_mistakes_per_block(index+1) == 0                    % if a 1 is followed by a zero, this is an indicator for a first time mistake
%             no_first_time_mistakes = no_first_time_mistakes + 1;            
%         end
%         index = index + 1;
%     end
%     no_first_time_corrects = TrialRecord.User.blocksize - no_first_time_mistakes;            % the number of corrects is the complement of the first time wrong ones according to the blocksize
%     TrialRecord.User.performance = no_first_time_corrects/TrialRecord.User.blocksize;        % performance is the first time corrects over the blocksize ( first time stimuli are shown )
%     TrialRecord.NextBlock = TrialRecord.CurrentBlock + 1;                   % move to the nect block after all of this
%     if TrialRecord.User.performance >= succes_threshold && ...              % if performance is over the threshold, add a progression number
%             TrialRecord.User.progression_number < TrialRecord.User. ...
%             max_c_progression_number                                        % but the progression number can not go above max number
%         TrialRecord.User.progression_number = ... 
%             TrialRecord.User.progression_number + 1;
%     elseif TrialRecord.User.performance <= fail_threshold && ...            % if performance is under the threshold and progression number is not already at the min progression number, substract a progression number
%             TrialRecord.User.progression_number > min_c_progression_number
%         TrialRecord.User.progression_number = ... 
%             TrialRecord.User.progression_number - 1;
%     end
% end

if mod(TrialRecord.User.stimulus_sequence_index, TrialRecord.User.blocksize) == 0 ...      % after previous block, do the following. does't work with blokcsize = 1
        && TrialRecord.CurrentTrialNumber ~=0 && ...
        ~TrialRecord.User.repeat                                            % stim seq index to not keep repeats into account
    trialerrors_block = TrialRecord.TrialErrors(end-TrialRecord.CurrentTrialWithinBlock+1 : end);
    first_time = zeros(1, length(TrialRecord.User.index_trialerror));
    first_time_index = 1;
    while first_time_index ~= length(TrialRecord.User.index_trialerror)+1
        first_time(first_time_index) = trialerrors_block(TrialRecord.User.index_trialerror(first_time_index));
        first_time_index = first_time_index + 1;
    end
    boolean_corrects_per_block = first_time == 0;
    TrialRecord.User.performance = mean(boolean_corrects_per_block);
    TrialRecord.NextBlock = TrialRecord.CurrentBlock + 1;                   % move to the nect block after all of this
    if TrialRecord.User.performance >= succes_threshold && ...              % if performance is over the threshold, add a progression number
            TrialRecord.User.progression_number < TrialRecord.User. ...
            max_c_progression_number                                        % but the progression number can not go above max number
        TrialRecord.User.progression_number = ... 
            TrialRecord.User.progression_number + 1;
    elseif TrialRecord.User.performance <= fail_threshold && ...            % if performance is under the threshold and progression number is not already at the min progression number, substract a progression number
            TrialRecord.User.progression_number > min_c_progression_number
        TrialRecord.User.progression_number = ... 
            TrialRecord.User.progression_number - 1;
    end
end


% if TrialRecord.User.progression_number > max_c_progression_number;
%     TrialRecord.User.progression_number = max_c_progression_number;
% end

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
        TrialRecord.User.holding_on = true;
    end
    if TrialRecord.User.category_progression >=3
        TrialRecord.User.mounting_on = true;
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

% calculation current sum categories after switches have been altered
TrialRecord.User.current_sum_categories = sum([TrialRecord.User.chasing_on, ... % difference between current and previous sum of categories acts as a 
    TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...               % switch for new stimulus list creation involving new categories and other
    TrialRecord.User.mounting_on, TrialRecord.User.agent_on, ...                % changes that have to be made when categories are added
    TrialRecord.User.patient_on]);
%% orienting between stimuli and frame files creating individual folder lists and general stim and frame lists
% Do all of this for trial 0 because it would be inefficient to repeat and
% I want these variables to be fixed throughout the run
if TrialRecord.CurrentTrialNumber == 0
    % dir() gives a struct of the contents of the path
    chasing_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\chasing');
    grooming_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\grooming');
    holding_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\holding');
    mounting_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\mounting');
    % isolating the name field
    TrialRecord.User.chasing_list = {chasing_struct.name};
    TrialRecord.User.grooming_list = {grooming_struct.name};
    TrialRecord.User.holding_list = {holding_struct.name};
    TrialRecord.User.mounting_list = {mounting_struct.name};
    % deleting the 2 empty spots from the name field
    TrialRecord.User.chasing_list(1:2) = [];
    TrialRecord.User.grooming_list(1:2) = [];
    TrialRecord.User.holding_list(1:2) = [];
    TrialRecord.User.mounting_list(1:2) = [];

    % analogous for the frames
    chasing_frame_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\chasing');
    grooming_frame_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\grooming');
    holding_frame_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\holding');
    mounting_frame_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\mounting');
    TrialRecord.User.chasing_frame_list = {chasing_frame_struct.name};
    TrialRecord.User.grooming_frame_list = {grooming_frame_struct.name};
    TrialRecord.User.holding_frame_list = {holding_frame_struct.name};
    TrialRecord.User.mounting_frame_list = {mounting_frame_struct.name};
    TrialRecord.User.chasing_frame_list(1:2) = [];
    TrialRecord.User.grooming_frame_list(1:2) = [];
    TrialRecord.User.holding_frame_list(1:2) = [];
    TrialRecord.User.mounting_frame_list(1:2) = [];

    % creating general lists with all the files
    TrialRecord.User.general_stimulus_list = [TrialRecord.User.chasing_list, TrialRecord.User.grooming_list, TrialRecord.User.holding_list,  TrialRecord.User.mounting_list]; 
    TrialRecord.User.general_frame_list = [TrialRecord.User.chasing_frame_list, TrialRecord.User.grooming_frame_list, TrialRecord.User.holding_frame_list, TrialRecord.User.mounting_frame_list];
end

% creating useable stimulus list depending on the switches
if TrialRecord.User.mounting_on || TrialRecord.User.agent_on || TrialRecord.User.patient_on
    stimulus_list = TrialRecord.User.general_stimulus_list;
    frame_list = TrialRecord.User.general_frame_list;
elseif  ~TrialRecord.User.mounting_on && TrialRecord.User.holding_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:(end-length(TrialRecord.User.mounting_list)));
    frame_list = TrialRecord.User.general_frame_list(1, 1:(end-length(TrialRecord.User.mounting_frame_list)));
elseif ~TrialRecord.User.holding_on && TrialRecord.User.grooming_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:(length(TrialRecord.User.chasing_list)+length(TrialRecord.User.grooming_list)));
    frame_list = TrialRecord.User.general_frame_list(1, 1:(length(TrialRecord.User.chasing_frame_list)+length(TrialRecord.User.grooming_frame_list)));
elseif ~TrialRecord.User.grooming_on && TrialRecord.User.chasing_on
    stimulus_list = TrialRecord.User.general_stimulus_list(1, 1:length(TrialRecord.User.chasing_list));
    frame_list = TrialRecord.User.general_frame_list(1, 1:length(TrialRecord.User.chasing_frame_list));
end

%%%%%%%%%%%%%%%%%
if TrialRecord.CurrentTrialNumber == 0
boolean_repeats = [structure.c_repeats] == 4
if TrialRecord.CurrentTrialNumber == 0 || TrialRecord.User.current_sum_categories ~= previous_sum_categories || mean van de repeats of the successes compleet zijn %%%% boolean maken voor de repeats, als ik dan het gemiddelde neem van de boolean_repeats en de successes en dat is gelijk aan 0.50, is de structure volledig doorlopen.
    structure = struct('stimuli', {}, 'frames', {}, 'c_repeats', {}, 'c_success', {}, 'a_repeats', {}, 'a_success', {}, 'p_repeats', {}, 'p_success', {}, 'folder', {});
    index = 1;
    while index ~= length(stimulus_list)+1;
        structure(index).stimuli = stimulus_list(index);
        structure(index).frames = frame_list(index);
        structure(index).c_repeats = 0;
        structure(index).c_success = 0;
        structure(index).a_repeats = 0;
        structure(index).a_success = 0;
        structure(index).p_repeats = 0;
        structure(index).p_success = 0;
        if index <= length(TrialRecord.User.chasing_list)
            structure(index).folder = 'chasing';
        elseif index <= length(TrialRecord.User.chasing_list) + length(TrialRecord.User.grooming_list)
            structure(index).folder = 'grooming';
        elseif index <= length(TrialRecord.User.chasing_list) + length(TrialRecord.User.grooming_list) + length(TrialRecord.User.holding_list)
            structure(index).folder = 'holding';
        elseif index <= length(TrialRecord.User.general_stimulus_list)
            structure(index).folder = 'mounting';
        end
        index = index+1;
    end
end
% determine categorizing, agent or patient ( codes 1,2 and 3)
category = false;
agent = false;
patient = false;

if mean([structure.c_success]) ~= 1 && mean([structure.c_repeats]) ~= 4 ...
        && (TrialRecord.User.chasing_on || TrialRecord.User.grooming_on || TrialRecord.User.holding_on || TrialRecord.User.mounting_on)
    category = true;
end
if mean([structure.a_success]) ~= 1 && mean([structure.a_repeats]) ~= 4 ...
        && TrialRecord.User.agent_on
    agent = true;
end
if mean([structure.p_success]) ~= 1 && mean([structure.p_repeats]) ~= 4 ...
        && TrialRecord.User.patient_on
    patient = true;
end

question = randperm(sum([category agent patient], 'all'), 1);
index2 = 1;
active_stim = struct('stimuli', {}, 'frames', {}, 'c_repeats', {}, 'c_success', {}, 'a_repeats', {}, 'a_success', {}, 'p_repeats', {}, 'p_success', {}, 'folder', {});

if ~TrialRecord.User.training_agent_patient
    switch question
        case 1
            while index2 ~= length(stimulus_list)+1
                if structure(index2).c_repeats < 4 && structure(index2).c_success ~= 1
                    active_stim(end+1) = structure(index2)
                end
                index2 = index2 +1;
            end
        case 2
            while index2 ~= length(stimulus_list)+1
                if structure(index2).a_repeats < 4 && structure(index2).a_success ~= 1
                    active_stim(end+1) = structure(index2)
                end
                index2 = index2 +1;
            end
        case 3
            while index2 ~= length(stimulus_list)+1
                if structure(index2).p_repeats < 4 && structure(index2).p_success ~= 1
                    active_stim(end+1) = structure(index2)
                end
                index2 = index2 +1;
            end
    end
else
    switch question
        case 1
            while index2 ~= length(stimulus_list)+1
                if structure(index2).a_repeats < 4 && structure(index2).a_success ~= 1
                    active_stim(end+1) = structure(index2)
                end
                index2 = index2 +1;
            end
        case 2
            while index2 ~= length(stimulus_list)+1
                if structure(index2).a_repeats < 4 && structure(index2).a_success ~= 1
                    active_stim(end+1) = structure(index2)
                end
                index2 = index2 +1;
            end
    end
end

chosen_stim_index = randperm(length(active_stim), 1);

if ~TrialRecord.User.training_agent_patient
    switch question
        case 1
            if strncmpi('chas', active_stim(chosen_stim_index).stimuli, 4)    % check for title of the animation to determine actual category
                TrialRecord.User.chasing = true;
                TrialRecord.NextCondition = 1;
            elseif strncmpi('groom', active_stim(chosen_stim_index).stimuli, 5)
                TrialRecord.User.grooming = true;
                TrialRecord.NextCondition = 2;
            elseif strncmpi('hold', active_stim(chosen_stim_index).stimuli, 4)
                TrialRecord.User.holding = true;
                TrialRecord.NextCondition = 3;
            elseif strncmpi('mount', active_stim(chosen_stim_index).stimuli, 5)
                TrialRecord.User.mounting = true;
                TrialRecord.NextCondition = 4;
            end
        case 2
            TrialRecord.NextCondition = 5;
            TrialRecord.User.agenting = true;
        case 3
            TrialRecord.NextCondition = 6;
            TrialRecord.User.patienting = true;
    end
else
    switch question
        case 1
            TrialRecord.NextCondition = 5;
            TrialRecord.User.agenting = true;
        case 2
            TrialRecord.NextCondition = 6;
            TrialRecord.User.patienting = true;
    end
end

TrialRecord.User.movie = strcat('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\', ... 
    active_stim(chosen_stim_index).folder, '\', active_stim(chosen_stim_index).stimuli);                                                  % complete path of the animation
TrialRecord.User.frame = strcat('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\', ... 
    active_stim(chosen_stim_index).folder, '\', active_stim(chosen_stim_index).frames);                    % and frame

%%%%%%%%%%%%%%%

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
%% task order
% setting condition sequence, maintaining it over userloops and picking
% condition. depending on switches stimuli have to be showed once, twice or
% thrice

if TrialRecord.User.current_sum_categories ~= previous_sum_categories       % at the start or whenever category is added
    if ~TrialRecord.User.training_categorization && ... 
            ~TrialRecord.User.training_agent_patient
        TrialRecord.User.no_repetitions = 3;                                % 3 repititions for category, agent and patient
    elseif TrialRecord.User.agent_on && TrialRecord.User.patient_on 
        TrialRecord.User.no_repetitions = 2;                                % 2 for agent, patient
    elseif TrialRecord.User.training_categorization || ... 
            TrialRecord.User.agent_on || TrialRecord.User.patient_on
        TrialRecord.User.no_repetitions = 1;                                % 1 for category or agent or patient
    end
    TrialRecord.User.condition_sequence = ...                               % make a permutation of no_repetitions*length (stim list)
        randperm(length(stimulus_list) * TrialRecord.User.no_repetitions);
end

stimulus_sequence = ... 
    mod(TrialRecord.User.condition_sequence,length(stimulus_list));         % converting the random order to a list of indexes for the stimuli in range 1:length(stim list)
stim_sequence_zero = find(stimulus_sequence == 0);                          
switch TrialRecord.User.no_repetitions                                      % if there is a 0, this means that it is the last number of the stim list, so replace this with the length(stim_list)
    case 1                                                                  % has to be done once, twice or thrice, depending on number of repetitions
        stimulus_sequence(stim_sequence_zero(1)) = length(stimulus_list);
    case 2
        stimulus_sequence(stim_sequence_zero(1)) = length(stimulus_list);
        stimulus_sequence(stim_sequence_zero(2)) = length(stimulus_list);
    case 3
        stimulus_sequence(stim_sequence_zero(1)) = length(stimulus_list);
        stimulus_sequence(stim_sequence_zero(2)) = length(stimulus_list);
        stimulus_sequence(stim_sequence_zero(3)) = length(stimulus_list);
end

if TrialRecord.User.current_sum_categories ~= previous_sum_categories...
        && TrialRecord.CurrentTrialNumber ~= 0
    TrialRecord.User.stimulus_sequence_index = 0; % 1                          % initialize index or start at 1 everytime the pool of stimuli changes
end
if ~TrialRecord.User.repeat                                                 % whenever repeat is off, add +1 to index
    TrialRecord.User.stimulus_sequence_index =  TrialRecord.User.stimulus_sequence_index + 1;
end
if TrialRecord.User.stimulus_sequence_index == length(stimulus_list)+1      % if we went through the complete list, restart at 1
    TrialRecord.User.stimulus_sequence_index = 1;
end
TrialRecord.User.stimulus = stimulus_sequence(TrialRecord.User.stimulus_sequence_index); % extract the number of the stimulus with the stim index from the stim sequence list

% intitializing question
if TrialRecord.User.training_agent_patient
    if TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ...   % if the number belongs to the first half of the total amount of numbers, then it is an agent question
            length( stimulus_list )
        TrialRecord.User.agenting = true;
        TrialRecord.NextCondition = 5;
    else
        TrialRecord.User.patienting = true;                                 % else, this is a patient question
        TrialRecord.NextCondition = 6;                                      % this is a way of tagging the condition sequence and since the sequence is random, it is valid
    end
else
    if TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ...   % if the number belongs to the first third of the total amount of numbers, then it is a category question
            length( stimulus_list )
        TrialRecord.User.categorizing = true;
        if TrialRecord.User.categorizing
            if strncmpi('chas', stimulus_list{TrialRecord.User.stimulus}, 4)    % check for title of the animation to determine actual category
                TrialRecord.User.chasing = true;
                TrialRecord.NextCondition = 1;
            elseif strncmpi('groom', stimulus_list{TrialRecord.User.stimulus}, 5)
                TrialRecord.User.grooming = true;
                TrialRecord.NextCondition = 2;
            elseif strncmpi('hold', stimulus_list{TrialRecord.User.stimulus}, 4)
                TrialRecord.User.holding = true;
                TrialRecord.NextCondition = 3;
            elseif strncmpi('mount', stimulus_list{TrialRecord.User.stimulus}, 5)
                TrialRecord.User.mounting = true;
                TrialRecord.NextCondition = 4;
            end
        end
    elseif length( stimulus_list ) < ...                                    % if it belongs to the 2nd third of the portion, then it is an agent question
            TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) && ... 
            TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ...
            (2 * length( stimulus_list ))
        TrialRecord.User.agenting = true;
        TrialRecord.NextCondition = 5;
    else                                                                    % else, it is a patient question
        TrialRecord.User.patienting = true;
        TrialRecord.NextCondition = 6;
    end
end

% determining correct folder name and define indexes for within folders
% all_folders = {'chasing','grooming','holding','mounting'} and then I can
% index
if TrialRecord.User.stimulus <= length(TrialRecord.User.chasing_list)        %  this is based on the idea that the general stim list is a sum of all the lists, so stimulus_list = [chasing_list, grooming_list, holding_list, mounting_list];
    folder = 'chasing';                                                      % I can divide the general list in chunks according to the lengths of the sublists general_stimulus_list = [chasing_list, grooming_list, holding_list, mounting_list];
    folder_index = TrialRecord.User.stimulus;                                % check 1: chasing, 2: grooming, 3:holding, 4: mounting
    indexed = TrialRecord.User.chasing_list{folder_index};
elseif TrialRecord.User.stimulus <= length(TrialRecord.User.chasing_list)+length(TrialRecord.User.grooming_list)
    folder = 'grooming';
    folder_index = TrialRecord.User.stimulus - length(TrialRecord.User.chasing_list);
    indexed = TrialRecord.User.grooming_list{folder_index};
elseif TrialRecord.User.stimulus <= length(TrialRecord.User.chasing_list)+length(TrialRecord.User.holding_list)+length(TrialRecord.User.grooming_list)
    folder = 'holding';
    folder_index = TrialRecord.User.stimulus - (length(TrialRecord.User.chasing_list)+length(TrialRecord.User.grooming_list));
    indexed = TrialRecord.User.holding_list{folder_index};
elseif TrialRecord.User.stimulus <= ... 
        length(TrialRecord.User.chasing_list)+length(TrialRecord.User.holding_list)+length(TrialRecord.User.grooming_list)+length(TrialRecord.User.mounting_list)
    folder = 'mounting';
    folder_index = TrialRecord.User.stimulus - (length(TrialRecord.User.chasing_list)+length(TrialRecord.User.holding_list)+length(TrialRecord.User.grooming_list));
    indexed = TrialRecord.User.mounting_list{folder_index};
end

% creating path to chosen stimulus and according frame
TrialRecord.User.movie = strcat('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\', ... 
    folder, '\', indexed);                                                  % complete path of the animation
TrialRecord.User.frame = strcat('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\', ... 
    folder, '\', frame_list{TrialRecord.User.stimulus});                    % and frame

% creating condition
C = {'sqr([2 1], [1 0 0], 0, 0, -1)'};
end