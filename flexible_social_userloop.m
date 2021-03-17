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
    
% mltaskobject(stim, MLConfig, TrialRecord);

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

stimulus_list = [chasing_list, grooming_list, holding_list,  mounting_list];

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

frame_list = [chasing_frame_list, grooming_frame_list, holding_frame_list, mounting_frame_list];

% setting condition sequence, maintaining it over userloops and picking
% condition

if TrialRecord.CurrentTrialNumber == 0
    TrialRecord.User.condition_sequence = randperm(length(stimulus_list) * 3);
end


stimulus_sequence = mod(TrialRecord.User.condition_sequence,length(stimulus_list)) + 1;
TrialRecord.User.stimulus_sequence_index = mod(TrialRecord.CurrentTrialNumber, length(TrialRecord.User.condition_sequence)) + 1;
TrialRecord.User.stimulus = stimulus_sequence(TrialRecord.User.stimulus_sequence_index);

% intitializing question

TrialRecord.User.categorizing = false;
TrialRecord.User.agenting = false;
TrialRecord.User.patienting = false;

TrialRecord.User.grooming = false;
TrialRecord.User.chasing = false;
TrialRecord.User.holding = false;
TrialRecord.User.mounting = false;


if TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ... 
        length( stimulus_list )
    TrialRecord.User.categorizing = true;
    if TrialRecord.User.categorizing
        if strncmpi('groom', stimulus_list{TrialRecord.User.stimulus}, 5)
            TrialRecord.User.grooming = true;
            TrialRecord.NextCondition = 1;
        elseif strncmpi('chas', stimulus_list{TrialRecord.User.stimulus}, 4)
            TrialRecord.User.chasing = true;
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

% determining correct folder name and define indexes for within folders
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

C = {'fix(0,0)'};


% determining next block

if mod(TrialRecord.CurrentTrialNumber, length(TrialRecord.User.condition_sequence)) == 0
    TrialRecord.NextBlock = (TrialRecord.CurrentTrialNumber / length(TrialRecord.User.condition_sequence)) + 1;
end
end        