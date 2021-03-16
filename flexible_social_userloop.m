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

% creating taskobject out of stimuli path
stim_struct = dir('stimuli');
frame_struct = dir('frames');
TrialRecord.User.stimulus_list = {stim_struct.name};
TrialRecord.User.stimulus_list(1:2) = [];
TrialRecord.User.frame_list = {frame_struct.name};
TrialRecord.User.frame_list(1:2) = [];

% setting condition sequence, maintaining it over userloops and picking
% condition

if TrialRecord.CurrentTrialNumber == 0
    TrialRecord.User.condition_sequence = randperm(length(TrialRecord.User.stimulus_list) * 3);
end


stimulus_sequence = mod(TrialRecord.User.condition_sequence,length(TrialRecord.User.stimulus_list)) + 1;
TrialRecord.User.stimulus_sequence_index = mod(TrialRecord.CurrentTrialNumber, length(TrialRecord.User.condition_sequence)) + 1;
TrialRecord.User.stimulus = stimulus_sequence(TrialRecord.User.stimulus_sequence_index);
% TrialRecord.NextCondition = TrialRecord.User.stimulus;

% intitializing question

TrialRecord.User.categorizing = false;
TrialRecord.User.agenting = false;
TrialRecord.User.patienting = false;

TrialRecord.User.grooming = false;
TrialRecord.User.chasing = false;
TrialRecord.User.mounting = false;

if TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ... 
        length( TrialRecord.User.stimulus_list )
    TrialRecord.User.categorizing = true;
    if TrialRecord.User.categorizing
        if strncmpi('groom', TrialRecord.User.stimulus_list{TrialRecord.User.stimulus}, 5)
            TrialRecord.User.grooming = true;
            TrialRecord.NextCondition = 1;
        elseif strncmpi('chas', TrialRecord.User.stimulus_list{TrialRecord.User.stimulus}, 4)
            TrialRecord.User.chasing = true;
            TrialRecord.NextCondition = 2;
        elseif strncmpi('mount', TrialRecord.User.stimulus_list{TrialRecord.User.stimulus}, 5)
            TrialRecord.User.mounting = true;
            TrialRecord.NextCondition = 3;
%         elseif strncmpi('placeholder', TrialRecord.User.stimulus_list{TrialRecord.User.stimulus}, 5)
%             
%             TrialRecord.NextCondition = 4;
        end
    end
elseif length( TrialRecord.User.stimulus_list ) < ... 
        TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) && ... 
        TrialRecord.User.condition_sequence(TrialRecord.User.stimulus_sequence_index) <= ...
        (2 * length( TrialRecord.User.stimulus_list ))
    TrialRecord.User.agenting = true;
    TrialRecord.NextCondition = 5;
else 
    TrialRecord.User.patienting = true;
    TrialRecord.NextCondition = 6;
end

% creating task objects
% task_object1 = strcat('mov(C:\Users\samco\Documents\GitHub\social_interactions\stimuli\', ...
%     TrialRecord.User.stimulus_list{TrialRecord.User.stimulus}, ', 0, 0, 0)');
% task_object2 = strcat('pic(C:\Users\samco\Documents\GitHub\social_interactions\frames\', ... 
%     TrialRecord.User.frame_list{TrialRecord.User.stimulus}, ', 0, 0)');

TrialRecord.User.movie = strcat('C:\Users\samco\Documents\GitHub\social_interactions\stimuli\', ... 
    TrialRecord.User.stimulus_list{TrialRecord.User.stimulus});
TrialRecord.User.frame = strcat('C:\Users\samco\Documents\GitHub\social_interactions\frames\', ... 
    TrialRecord.User.frame_list{TrialRecord.User.stimulus});

% creating condition

% C = {task_object1, task_object2, 'fix(0,0)'};
C = {'fix(0,0)'};


% determining next block

if mod(TrialRecord.CurrentTrialNumber, length(TrialRecord.User.condition_sequence)) == 0
    TrialRecord.NextBlock = (TrialRecord.CurrentTrialNumber / length(TrialRecord.User.condition_sequence)) + 1;
end
end        