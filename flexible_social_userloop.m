function [C,timingfile,userdefined_trialholder] = social_userloop(MLConfig,TrialRecord)
%% template
% return values
C = [];
timingfile = 'flexible_touch_of_project.m';  % Placeholder, real timing file assigned below.
userdefined_trialholder = '';

persistent timing_filenames_retrieved
    if isempty(timing_filenames_retrieved)
        timing_filenames_retrieved = true;
    return
    end

%% determining next block and difficulty based on a general progression number
blocksize = 10; % i should come with a clear definition of a blok
% blocksize = length(TrialRecord.User.condition_sequence);

if TrialRecord.CurrentTrialNumber == 0
    TrialRecord.User.performance = 0;
    TrialRecord.User.progression_number = 0;
    TrialRecord.User.repeat = false; % initializing repeat for first trial
elseif mod(TrialRecord.CurrentTrialNumber, blocksize) == 0
    boolean_errors_per_block = TrialRecord.TrialErrors(end-(blocksize-1) : end) == 0;
    TrialRecord.User.performance = mean(boolean_errors_per_block);
    TrialRecord.NextBlock = TrialRecord.CurrentBlock + 1;
    if TrialRecord.User.performance >= 0.80 && ~TrialRecord.User.repeat     % progression number shouldn't be influenced by repetitions
        TrialRecord.User.progression_number = TrialRecord.User.progression_number + 1;
    elseif TrialRecord.User.performance == 0 && ~TrialRecord.User.repeat
        if TrialRecord.User.progression_number > 0
            TrialRecord.User.progression_number = TrialRecord.User.progression_number - 1;
        end
    end
end

% setting independant category and button progression based on progression
% number
category_progression_factor = 1; %blocksize*category_progression_factor for +1category
agent_patient_progression_factor = 1; %blocksize*category_progression_factor for +1category
TrialRecord.User.size_progression_factor = blocksize*category_progression_factor;
constant_no_trials_at_max_size = 5;
TrialRecord.User.category_progression = TrialRecord.User.progression_number / ... 
    (category_progression_factor*blocksize + constant_no_trials_at_max_size);
TrialRecord.User.agent_patient_progression = TrialRecord.User.progression_number / ... 
    (agent_patient_progression_factor*blocksize + constant_no_trials_at_max_size);
if TrialRecord.User.category_progression <= 4
    TrialRecord.User.size_progression = mod(TrialRecord.User.progression_number, TrialRecord.User.size_progression_factor);
end
if TrialRecord.User.agent_patient_progression <= 2
    TrialRecord.User.size_progression = mod(TrialRecord.User.progression_number, TrialRecord.User.size_progression_factor);
end

%% toggling conditions on
TrialRecord.User.training_categorization = false; % complete task or training categorization
TrialRecord.User.training_agent_patient = false;

% difference between current and previous sum of categories acts as a
% switch for new stimulus list creation involving new categories and other
% changes that have to be made when categories are added

% calculations of previous sum categories
if TrialRecord.CurrentTrialNumber ~= 0
    previous_sum_categories = TrialRecord.User.current_sum_categories;
else
    previous_sum_categories = 0;
end

TrialRecord.User.chasing_on = false;
TrialRecord.User.grooming_on = false;
TrialRecord.User.holding_on = false;
TrialRecord.User.mounting_on = false;
TrialRecord.User.agent_on = false;
TrialRecord.User.patient_on = false;
TrialRecord.User.agent_on = false;
TrialRecord.User.patient_on = false;

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
TrialRecord.User.current_sum_categories = sum([TrialRecord.User.chasing_on, ... 
    TrialRecord.User.grooming_on,TrialRecord.User.holding_on, ...
    TrialRecord.User.mounting_on, TrialRecord.User.agent_on, ... 
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

if TrialRecord.User.current_sum_categories ~= previous_sum_categories
    if ~TrialRecord.User.training_categorization && ~TrialRecord.User.training_agent_patient
        TrialRecord.User.no_repetitions = 3; % 3 repititions for category, agent and patient
    elseif TrialRecord.User.agent_on && TrialRecord.User.patient_on 
        TrialRecord.User.no_repetitions = 2; % 2 for agent, patient
    elseif TrialRecord.User.training_categorization || TrialRecord.User.agent_on || TrialRecord.User.patient_on
        TrialRecord.User.no_repetitions = 1; % 1 for category or agent or patient
    end
    TrialRecord.User.condition_sequence = randperm(length(stimulus_list) * TrialRecord.User.no_repetitions);
end

stimulus_sequence = mod(TrialRecord.User.condition_sequence,length(stimulus_list)); % is sequence of animations taking into account repititions with the modulo
stim_sequence_zero = find(stimulus_sequence == 0);
switch TrialRecord.User.no_repetitions
    case 1
        stimulus_sequence(stim_sequence_zero(1)) = length(stimulus_list);
    case 2
        stimulus_sequence(stim_sequence_zero(1)) = length(stimulus_list);
        stimulus_sequence(stim_sequence_zero(2)) = length(stimulus_list);
    case 3
        stimulus_sequence(stim_sequence_zero(1)) = length(stimulus_list);
        stimulus_sequence(stim_sequence_zero(2)) = length(stimulus_list);
        stimulus_sequence(stim_sequence_zero(3)) = length(stimulus_list);
end


% if TrialRecord.User.current_sum_categories ~= previous_sum_categories % SOLVED : indexing resets whenever category gets added %%%%%% ik denk dat dit het probleem is voor mijn error in het begin! MORGEN CHECKEN!!!
%     TrialRecord.User.stimulus_sequence_index = mod(TrialRecord.CurrentTrialNumber, length(stimulus_sequence)) + 1;
% %     TrialRecord.User.stimulus_sequence_index = mod(TrialRecord.CurrentTrialNumber, length(stimulus_sequence));
% %     if TrialRecord.User.stimulus_sequence_index == 0 & TrialRecord.CurrentTrialNumber ~= 0   %%%%%
% %         TrialRecord.User.stimulus_sequence_index = length(stimulus_sequence);
% %     end
% elseif ~TrialRecord.User.repeat % whenever repeat is off, add +1 to index
%     TrialRecord.User.stimulus_sequence_index =  TrialRecord.User.stimulus_sequence_index + 1;
% end

if TrialRecord.User.current_sum_categories ~= previous_sum_categories
    TrialRecord.User.stimulus_sequence_index = 1; % initialize index or start at 1 everytime the pool of stimuli changes
end
if ~TrialRecord.User.repeat % whenever repeat is off, add +1 to index
    TrialRecord.User.stimulus_sequence_index =  TrialRecord.User.stimulus_sequence_index + 1;
end
if TrialRecord.User.stimulus_sequence_index == length(stimulus_list)+1  % if we went through the complete list, restart at 1
    TrialRecord.User.stimulus_sequence_index = 1;
end
% TrialRecord.User.stimulus_sequence_index = mod(TrialRecord.CurrentTrialNumber, length(stimulus_sequence)) + 1;
TrialRecord.User.stimulus = stimulus_sequence(TrialRecord.User.stimulus_sequence_index);

% intitializing question

TrialRecord.User.categorizing = false;
TrialRecord.User.agenting = false;
TrialRecord.User.patienting = false;

TrialRecord.User.grooming = false;
TrialRecord.User.chasing = false;
TrialRecord.User.holding = false;
TrialRecord.User.mounting = false;

if TrialRecord.User.training_agent_patient
    if TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ...   % I could also easly turn the condition sequence into a cell array with rows and identy each row as category, agent and patient...
            length( stimulus_list )
        TrialRecord.User.agenting = true;
        TrialRecord.NextCondition = 5;
    else
        TrialRecord.User.patienting = true;
        TrialRecord.NextCondition = 6;
    end
else
    if TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ...   % I could also easly turn the condition sequence into a cell array with rows and identy each row as category, agent and patient...
            length( stimulus_list )
        TrialRecord.User.categorizing = true;
        if TrialRecord.User.categorizing
            if strncmpi('chas', stimulus_list{TrialRecord.User.stimulus}, 4)
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
    elseif length( stimulus_list ) < ... 
            TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) && ... 
            TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ...
            (2 * length( stimulus_list ))
        TrialRecord.User.agenting = true;
        TrialRecord.NextCondition = 5;
    else 
        TrialRecord.User.patienting = true;
        TrialRecord.NextCondition = 6;
    end
end

% determining correct folder name and define indexes for within folders
% all_folders = {'chasing','grooming','holding','mounting'} and then I can
% index
if TrialRecord.User.stimulus <= length(TrialRecord.User.chasing_list)        % stimulus_list = [chasing_list, grooming_list, holding_list, mounting_list];
    folder = 'chasing';
    folder_index = TrialRecord.User.stimulus;
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
    folder, '\', indexed);
TrialRecord.User.frame = strcat('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\', ... 
    folder, '\', frame_list{TrialRecord.User.stimulus});

% creating condition
C = {'sqr([2 1], [1 0 0], 0, 0, -1)'};
end