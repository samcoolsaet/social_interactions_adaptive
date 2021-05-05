[y3, fs3] = audioread('alarm.wav');
hotkey('k','sound(y3, fs3);');
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(reward_dur, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');   % manual reward
hotkey('p', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number + 1;');
hotkey('o', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number + (TrialRecord.User.size_progression_factor - TrialRecord.User.size_progression)+1;');
hotkey('l', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number - TrialRecord.User.size_progression;');
hotkey('m', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number - 1; dashboard(1, string(TrialRecord.User.progression_number));');
bhv_code(1, 'run_engagement_scene', 2, 'run_video', 3, 'run_answer_scene', 5, 'end_aswer_scene');
%% constants
touch_threshold = 2;
standard_button_size = 2;                                                   % final button size
correct_button_size_difference = 3;                                         % the range from beginning button size to final size
wrong_button_size_difference = 1.75;
x_axes = [-12 12];
y_axes = [-10 -3.33 3.33 10];
y_spacing = 6.66;
y_center = -(TrialRecord.User.current_sum_buttons-1)*y_spacing/2;
movie_duration = 1000;
answer_time = 8000;
standard_time_out = 5000;
engagement_duration = 8000;
repeating = true;
TrialRecord.User.repeat = false;

%  init boxes
engaging_box = { [1 1 1], [1 1 1], standard_button_size, [10 0] };
chasing_box = {[1 0.8 0.6], [1 0.8 0.6], standard_button_size, [x_axes(1) y_center]};
grooming_box = {[0.5 1 1], [0.5 1 1], standard_button_size, [x_axes(1) (y_center + y_spacing)]};
mounting_box = {[1 1 0], [1 1 0], standard_button_size, [x_axes(1) (y_center + 2*y_spacing)]};
holding_box = {[0 0 1], [0 0 1], standard_button_size, [x_axes(1) (y_center + 3*y_spacing)]};
agent_box = {[0 1 1], [0 1 1], standard_button_size, [x_axes(2) y_center]};
patient_box = {[1 0 1], [1 0 1], standard_button_size, [x_axes(2) (y_center + y_spacing)]};

% x_spacing = 3;
% y_spacing = 3.33;
% x_center_points = [-13 12];
% % y_center_points = 0;
% y_center_points = floor(TrialRecord.User.current_sum_categories/2)*(-y_spacing)+3*y_spacing;
% 
% engaging_box = { [1 1 1], [1 1 1], standard_button_size, [10 0] };
% chasing_box = {[1 0 0], [1 0 0], standard_button_size, [x_center_points(1)-x_spacing y_center_points-3*y_spacing]};
% grooming_box = {[0 1 0], [0 1 0], standard_button_size, [x_center_points(1)+x_spacing y_center_points-3*y_spacing]};
% mounting_box = {[1 1 0], [1 1 0], standard_button_size, [x_center_points(1)-x_spacing y_center_points-y_spacing]};
% holding_box = {[0 0 1], [0 0 1], standard_button_size, [x_center_points(1)+x_spacing y_center_points-y_spacing]};
% agent_box = {[0 1 1], [0 1 1], standard_button_size, [x_center_points(2) y_center_points-y_spacing]};
% patient_box = {[1 0 1], [1 0 1], standard_button_size, [x_center_points(2) y_center_points+y_spacing]};

%% sizing buttons
% determining correct button size in case of training
correct_button_size_step = (1 - TrialRecord.User.size_progression/...               % the step in wich the size decreases, size progression is linked in a 1 to 1 basis with the progression number. So play with the blocksize in order to change #trials per size
    TrialRecord.User.size_progression_factor) * correct_button_size_difference;
wrong_button_size_step = (1 - TrialRecord.User.size_progression/...               % the step in wich the size decreases, size progression is linked in a 1 to 1 basis with the progression number. So play with the blocksize in order to change #trials per size
    TrialRecord.User.size_progression_factor) * wrong_button_size_difference;
if correct_button_size_step > 0                                                     % if the step is larger than 0
    correct_button_size = 2 + correct_button_size_step;                             % add the button size step to the standard size
    wrong_button_size = 2 - wrong_button_size_step;                               % subtract the size step from the standard size
else
    correct_button_size = standard_button_size;                             % els, it means that maximum progression through the size difference is reached
    wrong_button_size = standard_button_size;                               % thus the button size is the final button size
end

% only adjust last added button to correct, wrong or standard size,
% depending on corrext answer
if TrialRecord.User.training_categorization                                 % if training this
    switch TrialRecord.User.current_sum_categories                         % if 1 category is active
        case 1
            if TrialRecord.User.chasing                                         % if the stimulus is chasing
                chasing_box(3) = {standard_button_size};                         % then chasing is the correct button and size should be accordingly to the size progression
            else
                chasing_box(3) = {wrong_button_size};                           % else, chasing button is the wrong button
            end
        case 2                         % analogous to the chasing example
            if TrialRecord.User.grooming
                grooming_box(3) = {standard_button_size};
                chasing_box(3) = {wrong_button_size};
            else
                grooming_box(3) = {wrong_button_size};
            end
        case 3
            if TrialRecord.User.mounting
                mounting_box(3) = {standard_button_size};
                chasing_box(3) = {wrong_button_size};
                grooming_box(3) = {wrong_button_size};
            else
                mounting_box(3) = {wrong_button_size};
            end
        case 4
            if TrialRecord.User.holding
                holding_box(3) = {standard_button_size};
                chasing_box(3) = {wrong_button_size};
                grooming_box(3) = {wrong_button_size};
                mounting_box(3) = {wrong_button_size};
            else
                holding_box(3) = {wrong_button_size};
            end
    end
end
if TrialRecord.User.training_agent_patient
    switch TrialRecord.User.current_sum_buttons
        case 1
            if TrialRecord.User.agenting
                agent_box(3) = {standard_button_size};
            else
                agent_box(3) = {wrong_button_size};
            end
        case 2
            if TrialRecord.User.patienting
                patient_box(3) = {standard_button_size};
                agent_box(3) = {wrong_button_size};
            else
                patient_box(3) = {wrong_button_size};
                agent_box(3) = {standard_button_size};
            end
    end
end

all_boxes = [chasing_box; grooming_box; mounting_box; ...                    % making a list with all the boxes
    holding_box; agent_box; patient_box];
all_targets = [all_boxes{1, 4}; all_boxes{2, 4}; all_boxes{3, 4}; ...       % isolating the coordinates from the boxes
    all_boxes{4, 4}; all_boxes{5, 4}; all_boxes{6, 4}];

%% designing engage_button
% draw button box
engage_box = BoxGraphic(null_);
engage_box.List = engaging_box;

% set touch target
fix = SingleTarget(touch_);
fix.Target = [10 0];
fix.Threshold = touch_threshold;
%% designing trial buttons
% drawing button boxes
trial_box = BoxGraphic(null_);

if TrialRecord.User.categorizing                                            % if question is related to category
    if TrialRecord.User.current_sum_categories >= 4                         % if all categories are involved, show the 4 boxes
        trial_box.List = all_boxes(1:4, 1:4);
    else
        trial_box.List = ... 
            all_boxes(1:TrialRecord.User.current_sum_categories, 1:4);      % else, show the number of involved categories
    end
elseif TrialRecord.User.agenting || TrialRecord.User.patienting             % analogous when agent patient
    if TrialRecord.User.current_sum_categories == 1
        trial_box.List = all_boxes(TrialRecord.CurrentCondition, 1:4);
    else
        trial_box.List = all_boxes(5:6, 1:4);
    end
end

% setting touch targets
if TrialRecord.User.current_sum_categories == 1                             % if only 1 category is active, I have to use single target adapter 
    touch = SingleTarget(touch_);
else
    touch = MultiTarget(touch_);                                            % else, I can use the Multitarget adapter
    touch.WaitTime = 150000;
    touch.HoldTime = 0;
end

if TrialRecord.User.categorizing
    if TrialRecord.User.current_sum_categories >= 4                         % if all categories are involved, 4 targets are active
        touch.Target = all_targets(1:4, :);
    else
        touch.Target = ... 
            all_targets(1:TrialRecord.User.current_sum_categories, :);      % else, show the number of involved categories
    end
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    if TrialRecord.User.current_sum_categories == 1
        touch.Target = all_targets(TrialRecord.CurrentCondition, :);
    else
        touch.Target = all_targets(5:6, :);
    end
end
touch.Threshold = touch_threshold;
%% setting up animations and frames
mov = MovieGraphic(fix);
mov.List = { TrialRecord.User.movie, [0 0], 0, 1.25, 90 };   % movie filename
% tc = TimeCounter(mov);
img = ImageGraphic(null_);
img.List = { TrialRecord.User.frame, [0 0], 0, 1.25, 90 };
%% constructing scenes
% setting timecounter for duration of animation in first scene and time to
% answer
tc_engagement = TimeCounter(fix);
tc_engagement.Duration = engagement_duration;
tc_movie = TimeCounter(null_);
tc_movie.Duration = movie_duration;
tc_answer = TimeCounter(touch);
tc_answer.Duration = answer_time;

% webcam
cam = WebcamMonitor(null_);
cam.CamNumber = 1;

% merging touch and visual for engagement button
ac = OrAdapter(fix);
ac.add(tc_engagement);
con1 = Concurrent(ac);
con1.add(engage_box);
con1.add(cam);

% running timecounter and showing buttons together for first scene
con2 = Concurrent(tc_movie);
con2.add(mov)
con2.add(cam);

% showing buttons and adding touch targets. restricted by answer
% timecounter
or = OrAdapter(touch);
or.add(tc_answer);
con3 = Concurrent(or);
con3.add(img);
con3.add(trial_box);
con3.add(cam);
%% running scenes
% run engagement scene
scene1 = create_scene(con1);
run_scene(scene1, 1);
if tc_engagement.Success
    TrialRecord.User.engaged = false;
    disp('not engaged');
    trialerror(8);
    return
else
    TrialRecord.User.engaged = true;
end

% run animation scene
scene2 = create_scene(con2);
run_scene(scene2, 2);

% run frame and answering scene
tf = istouching;
while istouching  % while touching, do not proceed to the buttons
    idle(2000);
end
if TrialRecord.User.categorizing
    set_bgcolor([1 0.5 1]);   % change the background color  
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    set_bgcolor([1 1 1]);
end

scene3 = create_scene(con3);
fliptime = run_scene(scene3, 3);

set_bgcolor([]);        % change it back to the original color
idle(0);

if TrialRecord.User.current_sum_categories == 1
    answer_time = touch.Time - fliptime;
else
    answer_time = touch.RT;
end
%% evaluate

% make reward scale with ( a fraction of ) progression number correlated
% with the goal for that day?
random_portion = randi(100, 1);
max_reward = 400;
min_reward = 150;
category_bonus = 300; % maybe just add category bonus when switch
extra_reward = 100;
progression_goal_window = (2*TrialRecord.User.size_progression_factor +2) - TrialRecord.User.start_progression_number;
progression_relative_start = TrialRecord.User.progression_number - TrialRecord.User.start_progression_number;      % reward goes from min to max over x progression numbers
reward_window = max_reward - min_reward;
variable_reward_portion = progression_relative_start* ...                   % here the variable portion is calculated based on a fraction of the complete task.
    reward_window/progression_goal_window + floor(progression_relative_start/TrialRecord.User.size_progression_factor) * category_bonus;
reward_dur1 = min_reward + variable_reward_portion;
if reward_dur1 > max_reward                                                 % stay below max reward
    reward_dur1 = max_reward;
elseif reward_dur1 < min_reward
    reward_dur1 = min_reward;
end
if TrialRecord.CurrentTrialNumber ~= 1 && TrialRecord.ConditionsPlayed(end)...
        ~= TrialRecord.CurrentCondition
    reward_dur1 = reward_dur1 + random_portion + extra_reward;
else
    reward_dur1 = reward_dur1 + random_portion;
end


if TrialRecord.CurrentTrialNumber <= 10
    time_out = standard_time_out;
else
    boolean_last_ten = TrialRecord.TrialErrors(end-9:end) == 0;
    performance_last_ten = mean(boolean_last_ten);
    time_out = standard_time_out / sqrt(TrialRecord.User.performance);
    if time_out > 7000
        time_out = 7000;
    end
end

[y1, fs1] = audioread('right.wav');
[y2, fs2] = audioread('wrong.wav');
if TrialRecord.User.current_sum_categories == 1 && TrialRecord.User.categorizing
    if touch.Success
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        TrialRecord.User.structure(TrialRecord.User.struct_index).c_success = TrialRecord.User.structure(TrialRecord.User.struct_index).c_success + 1; %%%% dit ook nog voor de rest doen
        reward = true;
    elseif tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
        TrialRecord.User.structure(TrialRecord.User.struct_index).c_fails = TrialRecord.User.structure(TrialRecord.User.struct_index).c_fails + 1; %%%% dit ook nog voor de rest doen
        reward = false;
    end
elseif TrialRecord.User.current_sum_buttons == 1 && TrialRecord.User.agenting_patienting
    if touch.Success
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        TrialRecord.User.structure(TrialRecord.User.struct_index).a_success = TrialRecord.User.structure(TrialRecord.User.struct_index).a_success + 1; %%%% dit ook nog voor de rest doen
        reward = true;
    elseif tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
        TrialRecord.User.structure(TrialRecord.User.struct_index).a_fails = TrialRecord.User.structure(TrialRecord.User.struct_index).a_fails + 1; %%%% dit ook nog voor de rest doen
        reward = false;
        if tc_answer.Success
            dashboard(2, 'no response');
            trialerror(1);
        else
            dashboard(2, 'FAIL!!!');
            trialerror(6);
        end
    end
elseif TrialRecord.User.categorizing & TrialRecord.User.current_sum_categories ~= 1
    if (TrialRecord.User.chasing & touch.ChosenTarget == 1) | ...
            (TrialRecord.User.grooming & touch.ChosenTarget == 2) | ...
            (TrialRecord.User.mounting & touch.ChosenTarget == 3) | ...
            (TrialRecord.User.holding & touch.ChosenTarget == 4) 
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        TrialRecord.User.structure(TrialRecord.User.struct_index).c_success = TrialRecord.User.structure(TrialRecord.User.struct_index).c_success + 1; %%%% dit ook nog voor de rest doen
        reward = true;
    else
        TrialRecord.User.structure(TrialRecord.User.struct_index).c_fails = TrialRecord.User.structure(TrialRecord.User.struct_index).c_fails + 1; %%%% dit ook nog voor de rest doen        
        reward = false;
        if tc_answer.Success
            dashboard(2, 'no response');
            trialerror(1);
        else
            dashboard(2, 'FAIL!!!');
            trialerror(6);
        end
    end
elseif TrialRecord.User.agenting & touch.ChosenTarget == 1
    dashboard(2, 'success!!! <3 ');
    trialerror(0);
    TrialRecord.User.structure(TrialRecord.User.struct_index).a_success = TrialRecord.User.structure(TrialRecord.User.struct_index).a_success + 1; %%%% dit ook nog voor de rest doen
    reward = true;
elseif TrialRecord.User.agenting & touch.ChosenTarget ~= 1
    TrialRecord.User.structure(TrialRecord.User.struct_index).a_fails = TrialRecord.User.structure(TrialRecord.User.struct_index).a_fails + 1; %%%% dit ook nog voor de rest doen    
    reward = false;    
    if tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
    else
        dashboard(2, 'FAIL!!!');
        trialerror(6);
    end
elseif TrialRecord.User.patienting & touch.ChosenTarget == 2
    dashboard(2, 'success!!! <3 ');
    trialerror(0)
    TrialRecord.User.structure(TrialRecord.User.struct_index).p_success = TrialRecord.User.structure(TrialRecord.User.struct_index).p_success + 1; %%%% dit ook nog voor de rest doen
    reward = true;
elseif TrialRecord.User.patienting & touch.ChosenTarget ~= 2
    TrialRecord.User.structure(TrialRecord.User.struct_index).p_fails = TrialRecord.User.structure(TrialRecord.User.struct_index).p_fails + 1; %%%% dit ook nog voor de rest doen       
    reward = false;
    if tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
    else
        dashboard(2, 'FAIL!!!');
        trialerror(6);
    end
end

if reward
%     sound(y1, fs1);
    goodmonkey(reward_dur1);
    background = [0 1 0 1000];
    disp(['reward given:' string(reward_dur1)]);
else
%     sound(y2, fs2);
    background = [1 0 0 time_out];
    disp(['no reward, time out' string(time_out)]);
end
reward_scene = BackgroundColorChanger(null_);
reward_scene.List = background;
reward_scene.DurationUnit = 'msec';
con4 = Concurrent(reward_scene);
con4.add(cam);
scene4 = create_scene(con4);
run_scene(scene4);

if TrialRecord.User.structure(TrialRecord.User.struct_index).c_success == 1 ...
        || TrialRecord.User.structure(TrialRecord.User.struct_index).c_fails >= TrialRecord.User.max_fails
    TrialRecord.User.structure(TrialRecord.User.struct_index).c_completed = 1;
    disp('stimulus set to complete, should not be repeated');
elseif TrialRecord.User.structure(TrialRecord.User.struct_index).a_success == 1 ...
        || TrialRecord.User.structure(TrialRecord.User.struct_index).a_fails >= TrialRecord.User.max_fails
    TrialRecord.User.structure(TrialRecord.User.struct_index).a_completed = 1;
    disp('stimulus set to complete, should not be repeated');
elseif TrialRecord.User.structure(TrialRecord.User.struct_index).p_success == 1 ...
        || TrialRecord.User.structure(TrialRecord.User.struct_index).p_fails >= TrialRecord.User.max_fails
    TrialRecord.User.structure(TrialRecord.User.struct_index).p_completed = 1;
    disp('stimulus set to complete, should not be repeated');
else
    if repeating
        TrialRecord.User.repeat = true;
        disp('stimulus will be repeated');
    end
end

% for initial_active_stim
TrialRecord.User.c_structure_completion = mean([TrialRecord.User.structure.c_completed]);
TrialRecord.User.a_structure_completion = mean([TrialRecord.User.structure.a_completed]);
TrialRecord.User.p_structure_completion = mean([TrialRecord.User.structure.p_completed]);

TrialRecord.User.structure_completion = mean([TrialRecord.User.structure.c_completed] + ...
    [TrialRecord.User.structure.a_completed] + [TrialRecord.User.structure.p_completed])/...
    (TrialRecord.User.agent_on+TrialRecord.User.patient_on+TrialRecord.User.category);

TrialRecord.User.completed_stimuli = sum([TrialRecord.User.structure.c_completed] + [TrialRecord.User.structure.a_completed] + [TrialRecord.User.structure.p_completed], 'all');

bhv_variable('size_progression', TrialRecord.User.size_progression,...
    'category_progression', TrialRecord.User.category_progression,...
    'performance_previous_block', TrialRecord.User.performance,...
    'progression_number', TrialRecord.User.progression_number,...
    'stimulus_name', TrialRecord.User.structure(TrialRecord.User.struct_index).stimuli,...
    'structure_completion', TrialRecord.User.structure_completion, ...
    'structure', TrialRecord.User.structure, ...
    'completed_stim', TrialRecord.User.completed_stimuli,...
    'random_condition_order_index', TrialRecord.User.random_condition_order_index);