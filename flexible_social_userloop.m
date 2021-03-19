function [C,timingfile,userdefined_trialholder] = social_userloop(MLConfig,TrialRecord)
%% Code

% return values
C = [];
timingfile = 'flexible_touch_of_project.m';  % Placeholder, real timing file assigned below.
userdefined_trialholder = '';

persistent timing_filenames_retrieved
    if isempty(timing_filenames_retrieved)
        timing_filenames_retrieved = true;
    return
    end

% determining next block and difficulty based on progression number

blocksize = 1;
% blocksize = length(TrialRecord.User.condition_sequence);

if TrialRecord.CurrentTrialNumber == 0
    TrialRecord.User.performance = 0;
    TrialRecord.User.progression_number = 0;
elseif mod(TrialRecord.CurrentTrialNumber, blocksize) == 0
    boolean_errors_per_block = TrialRecord.TrialErrors(end-(blocksize-1) : end) == 0;
    TrialRecord.User.performance = mean(boolean_errors_per_block);
    TrialRecord.NextBlock = TrialRecord.CurrentBlock + 1;
    if TrialRecord.User.performance >= 0.80
        TrialRecord.User.progression_number = TrialRecord.User.progression_number + 1;
    end
end

% toggling conditions on
training_categorization = true; % complete task or training categorization
training_agent_patient = true;

if training_categorization
    TrialRecord.User.chasing_on = false;
    TrialRecord.User.grooming_on = false;
    TrialRecord.User.holding_on = false;
    TrialRecord.User.mounting_on = false;
    agent_patient = false;
    if TrialRecord.User.progression_number >=0
        TrialRecord.User.chasing_on = true;
    end
    if TrialRecord.User.progression_number >=1
        TrialRecord.User.grooming_on = true;
    end
    if TrialRecord.User.progression_number >=2
        TrialRecord.User.holding_on = true;
    end
    if TrialRecord.User.progression_number >=3
        TrialRecord.User.mounting_on = true;
    end
else
    TrialRecord.User.chasing_on = true;
    TrialRecord.User.grooming_on = true;
    TrialRecord.User.holding_on = true;
    TrialRecord.User.mounting_on = true;
    agent_patient = true;  
end

% orienting between stimuli and frame files
% creating individual folder lists and general stim and frame lists
chasing_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\chasing');
chasing_list = {chasing_struct.name};
chasing_list(1:2) = [];
grooming_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\grooming');
grooming_list = {grooming_struct.name};
grooming_list(1:2) = [];
holding_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\holding');
holding_list = {holding_struct.name};
holding_list(1:2) = [];
mounting_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\mounting');
mounting_list = {mounting_struct.name};
mounting_list(1:2) = [];

chasing_frame_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\chasing');
chasing_frame_list = {chasing_frame_struct.name};
chasing_frame_list(1:2) = [];
grooming_frame_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\grooming');
grooming_frame_list = {grooming_frame_struct.name};
grooming_frame_list(1:2) = [];
holding_frame_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\holding');
holding_frame_list = {holding_frame_struct.name};
holding_frame_list(1:2) = [];
mounting_frame_struct = dir('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\mounting');
mounting_frame_list = {mounting_frame_struct.name};
mounting_frame_list(1:2) = [];


if TrialRecord.User.chasing_on && TrialRecord.User.grooming_on && TrialRecord.User.holding_on && TrialRecord.User.mounting_on
    stimulus_list = [chasing_list, grooming_list, holding_list,  mounting_list];   % I could just make the stimulus list as an array with rows and identy each row as a category
    frame_list = [chasing_frame_list, grooming_frame_list, holding_frame_list, mounting_frame_list];
elseif TrialRecord.User.chasing_on && TrialRecord.User.grooming_on && TrialRecord.User.holding_on       
    stimulus_list = [chasing_list, grooming_list, holding_list];
    frame_list = [chasing_frame_list, grooming_frame_list, holding_frame_list];
elseif TrialRecord.User.chasing_on && TrialRecord.User.grooming_on
    stimulus_list = [chasing_list, grooming_list];
    frame_list = [chasing_frame_list, grooming_frame_list];
elseif TrialRecord.User.chasing_on
    stimulus_list = chasing_list;
    frame_list = chasing_frame_list;
end

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



% setting condition sequence, maintaining it over userloops and picking
% condition

if TrialRecord.CurrentTrialNumber == 0
    if agent_patient
        TrialRecord.User.condition_sequence = randperm(length(stimulus_list) * 3);
    else
        TrialRecord.User.condition_sequence = randperm(length(stimulus_list));
    end
    if training_agent_patient
        TrialRecord.User.condition_sequence = randperm(length(stimulus_list) * 2);
    end
end


stimulus_sequence = mod(TrialRecord.User.condition_sequence,length(stimulus_list)) + 1; % is sequence of animations
TrialRecord.User.stimulus_sequence_index = mod(TrialRecord.CurrentTrialNumber, length(stimulus_sequence)) + 1;
TrialRecord.User.stimulus = stimulus_sequence(TrialRecord.User.stimulus_sequence_index);

% intitializing question

TrialRecord.User.categorizing = false;
TrialRecord.User.agenting = false;
TrialRecord.User.patienting = false;

TrialRecord.User.grooming = false;
TrialRecord.User.chasing = false;
TrialRecord.User.holding = false;
TrialRecord.User.mounting = false;

if training_agent_patient
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
if TrialRecord.User.stimulus <= length(chasing_list)        % stimulus_list = [chasing_list, grooming_list, holding_list, mounting_list];
    folder = 'chasing';
    folder_index = TrialRecord.User.stimulus;
    indexed = chasing_list{folder_index};
elseif TrialRecord.User.stimulus <= length(chasing_list)+length(grooming_list)
    folder = 'grooming';
    folder_index = TrialRecord.User.stimulus - length(chasing_list);
    indexed = grooming_list{folder_index};
elseif TrialRecord.User.stimulus <= length(chasing_list)+length(holding_list)+length(grooming_list)
    folder = 'holding';
    folder_index = TrialRecord.User.stimulus - (length(chasing_list)+length(grooming_list));
    indexed = holding_list{folder_index};
elseif TrialRecord.User.stimulus <= ... 
        length(chasing_list)+length(holding_list)+length(grooming_list)+length(mounting_list)
    folder = 'mounting';
    folder_index = TrialRecord.User.stimulus - (length(chasing_list)+length(holding_list)+length(grooming_list));
    indexed = mounting_list{folder_index};
end

% creating path to chosen stimulus and according frame
TrialRecord.User.movie = strcat('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\stimuli\', ... 
    folder, '\', indexed);
TrialRecord.User.frame = strcat('C:\Users\samco\Documents\GitHub\social_interactions_adaptive\social_interactions_adaptive\frames\', ... 
    folder, '\', frame_list{TrialRecord.User.stimulus});

% creating condition

C = {'sqr([2 1], [1 0 0], 0, 0, -1)'};

end  