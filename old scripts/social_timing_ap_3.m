hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(reward_dur, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');   % manual reward
hotkey('p', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number + 1;');
hotkey('m', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number - 1; dashboard(1, string(TrialRecord.User.progression_number));');
dashboard(1, string(TrialRecord.User.progression_number));
bhv_code(1, 'run_engagement_scene', 2, 'run_video', 3, 'run_answer_scene', 5, 'end_aswer_scene');
%% constants
touch_threshold = 2;
standard_button_size = 2;                                                   % final button size
button_size_difference = 1.5;                                               % the range from beginning button size to final size
% x_axes = [-12 12];
% y_axes = [-10 -3.33 3.33 10];
movie_duration = 3000;
answer_time = 5000;
standard_time_out = 3000;

%  init boxes
% engaging_box = { [1 1 1], [1 1 1], standard_button_size, [10 0] };
% chasing_box = {[1 0 0], [1 0 0], standard_button_size, [x_axes(1) y_axes(1)]};
% grooming_box = {[0 1 0], [0 1 0], standard_button_size, [x_axes(1) y_axes(2)]};
% mounting_box = {[1 1 0], [1 1 0], standard_button_size, [x_axes(1) y_axes(3)]};
% holding_box = {[0 0 1], [0 0 1], standard_button_size, [x_axes(1) y_axes(4)]};
% agent_box = {[0 1 1], [0 1 1], standard_button_size, [x_axes(2) y_axes(2)]};
% patient_box = {[1 0 1], [1 0 1], standard_button_size, [x_axes(2) y_axes(3)]};

x_spacing = 3;
y_spacing = 3.33;
x_center_points = [-13 12];
% y_center_points = 0;
y_center_points = floor(TrialRecord.User.current_sum_buttons/2)*(-y_spacing)+3*y_spacing;

engaging_box = { [1 1 1], [1 1 1], standard_button_size, [10 0] };
chasing_box = {[1 0 0], [1 0 0], standard_button_size, [x_center_points(1)-x_spacing y_center_points-3*y_spacing]};
grooming_box = {[0 1 0], [0 1 0], standard_button_size, [x_center_points(1)+x_spacing y_center_points-3*y_spacing]};
mounting_box = {[1 1 0], [1 1 0], standard_button_size, [x_center_points(1)-x_spacing y_center_points-y_spacing]};
holding_box = {[0 0 1], [0 0 1], standard_button_size, [x_center_points(1)+x_spacing y_center_points-y_spacing]};
agent_box = {[0 1 1], [0 1 1], standard_button_size, [x_center_points(2) y_center_points-y_spacing]};
patient_box = {[1 0 1], [1 0 1], standard_button_size, [x_center_points(2) y_center_points+y_spacing]};

%% sizing buttons
% determining correct button size in case of training
if TrialRecord.User.training_categorization || TrialRecord.User.training_agent_patient
    button_size_step = (1 - TrialRecord.User.size_progression/...               % the step in wich the size decreases, size progression is linked in a 1 to 1 basis with the progression number. So play with the blocksize in order to change #trials per size
        TrialRecord.User.size_progression_factor) * button_size_difference;
    if button_size_step > 0                                                     % if the step is larger than 0
        correct_button_size = 2 + button_size_step;                             % add the button size step to the standard size
        wrong_button_size = 2 - button_size_step;                               % subtract the size step from the standard size
    else
        correct_button_size = standard_button_size;                             % els, it means that maximum progression through the size difference is reached
        wrong_button_size = standard_button_size;                               % thus the button size is the final button size
    end
end

% only adjust last added button to correct, wrong or standard size,
% depending on corrext answer
if TrialRecord.User.training_categorization                                 % if training this
    switch TrialRecord.User.current_sum_buttons                         % if 1 category is active
        case 1
            if TrialRecord.User.chasing                                         % if the stimulus is chasing
                chasing_box(3) = {correct_button_size};                         % then chasing is the correct button and size should be accordingly to the size progression
            else
                chasing_box(3) = {wrong_button_size};                           % else, chasing button is the wrong button
            end
        case 2                         % analogous to the chasing example
            if TrialRecord.User.grooming
                grooming_box(3) = {correct_button_size};
            else
                grooming_box(3) = {wrong_button_size};
            end
        case 3
            if TrialRecord.User.holding
                holding_box(3) = {correct_button_size};
            else
                holding_box(3) = {wrong_button_size};
            end
        case 4
            if TrialRecord.User.mounting
                mounting_box(3) = {correct_button_size};
            else
                mounting_box(3) = {wrong_button_size};
            end
    end
end
if TrialRecord.User.training_agent_patient
    switch TrialRecord.User.current_sum_buttons
        case 1
            if TrialRecord.User.agenting
                agent_box(3) = {correct_button_size};
            else
                agent_box(3) = {wrong_button_size};
            end
        case 2
            if TrialRecord.User.patienting
                patient_box(3) = {correct_button_size};
            else
                patient_box(3) = {wrong_button_size};
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
    trial_box.List = ... 
        all_boxes(1:TrialRecord.User.current_sum_categories, 1:4);          % else, show the number of involved categories
elseif TrialRecord.User.agenting || TrialRecord.User.patienting             % analogous when agent patient
    if TrialRecord.User.current_sum_buttons == 1
        trial_box.List = all_boxes(TrialRecord.CurrentCondition, 1:4);
    else
        trial_box.List = all_boxes(end-1:end, 1:4);
    end
end

% setting touch targets
if TrialRecord.User.current_sum_buttons == 1                             % if only 1 category is active, I have to use single target adapter 
    touch = SingleTarget(touch_);
else
    touch = MultiTarget(touch_);                                            % else, I can use the Multitarget adapter
    touch.WaitTime = 150000;
    touch.HoldTime = 0;
end

if TrialRecord.User.categorizing
    touch.Target = ... 
        all_targets(1:TrialRecord.User.current_sum_categories, :);           % else, show the number of involved categories
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    if TrialRecord.User.current_sum_buttons-TrialRecord.User.current_sum_categories == 1 %% problem 6 buttons when not training
        touch.Target = all_targets(TrialRecord.CurrentCondition, :);
    else
        touch.Target = all_targets(end-1:end, :);                           % hier mag ik maar 1 input geven als progression number 0 is, want singletarget.
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
tc_movie = TimeCounter(null_);
tc_movie.Duration = movie_duration;
tc_answer = TimeCounter(touch);
tc_answer.Duration = answer_time;

% webcam
cam = WebcamMonitor(null_);
cam.CamNumber = 1;

% merging touch and visual for engagement button
con1 = Concurrent(fix);
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

% temporary cue

% cue = CircleGraphic(null_);
% cue.List = {[1 1 1], [1 1 1], 1, [0 0] };
% if TrialRecord.User.agenting
%     con3.add(cue);
% end
%% running scenes
% run engagement scene
scene1 = create_scene(con1);
run_scene(scene1, 1);

% run animation scene

% % tf = istouching; %% maybe ad an adapter to this scene to learn Luca that
% % he should release the button? Give him some idle time to release.
% tf = istouching;
% if ~tf
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
% % make event code line

set_bgcolor([]);        % change it back to the original color
idle(0);

if TrialRecord.User.current_sum_buttons == 1
    answer_time = touch.Time - fliptime;
else
    answer_time = touch.RT;
end
%% evaluate

% make reward scale with ( a fraction of ) progression number correlated
% with the goal for that day?
random_portion = randi(100, 1);
max_reward = 500;
min_reward = 200;
reward_window = max_reward - min_reward;
progression_aim_this_training = 12;                                         % reward goes from min to max over x progression numbers
variable_reward_portion = TrialRecord.User.progression_number* ...          % here the variable portion is calculated based on a fraction of the complete task.
    reward_window/progression_aim_this_training ;
reward_dur1 = min_reward + variable_reward_portion;
if reward_dur1 > max_reward                                                  % stay below max reward
    reward_dur1 = max_reward;
end
reward_dur1 = reward_dur1 + random_portion;

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

[y1, fs1] = audioread('test.wav');
[y2, fs2] = audioread('test2.wav');
if TrialRecord.User.current_sum_buttons == 1 && TrialRecord.User.categorizing
    if touch.Success
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur1);
        idle(0, [0 1 0], 5);
        sound(y1, fs1);
        TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).c_success = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).c_success + 1; %%%% dit ook nog voor de rest doen
        TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_success = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_success + 1;
    elseif tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
        sound(y2, fs2);
        idle(time_out, [1 0 0], 5);
        TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).c_fails = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).c_fails + 1; %%%% dit ook nog voor de rest doen
        TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_fails = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_fails + 1;
    end
elseif TrialRecord.User.current_sum_buttons == 1 && TrialRecord.User.agenting_patienting
    if touch.Success
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur1);
        idle(0, [0 1 0], 5);
        sound(y1, fs1);
        TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).a_success = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).a_success + 1; %%%% dit ook nog voor de rest doen
        TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_success = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_success + 1;
    elseif tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
        idle(time_out, [1 0 0], 5);
        sound(y2, fs2);
        TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).a_fails = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).a_fails + 1; %%%% dit ook nog voor de rest doen
        TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_fails = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_fails + 1;
        if tc_answer.Success
            dashboard(2, 'no response');
            trialerror(1);
        else
            dashboard(2, 'FAIL!!!');
            trialerror(6);
        end
    end
elseif TrialRecord.User.categorizing & TrialRecord.User.current_sum_buttons ~= 1
    if (TrialRecord.User.chasing & touch.ChosenTarget == 1) | ...
            (TrialRecord.User.grooming & touch.ChosenTarget == 2) | ...
            (TrialRecord.User.mounting & touch.ChosenTarget == 3) | ...
            (TrialRecord.User.holding & touch.ChosenTarget == 4) 
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur1);
        idle(0, [0 1 0], 5);
        sound(y1, fs1);
        TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).c_success = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).c_success + 1; %%%% dit ook nog voor de rest doen
        TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_success = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_success + 1;
    else
        TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).c_fails = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).c_fails + 1; %%%% dit ook nog voor de rest doen        
        TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_fails = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_fails + 1;
        idle(time_out, [1 0 0], 5);
        sound(y2, fs2);
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
    goodmonkey(reward_dur1);
    idle(0, [0 1 0], 5);
    sound(y1, fs1);
    TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).a_success = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).a_success + 1; %%%% dit ook nog voor de rest doen
    TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_success = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_success + 1;
elseif TrialRecord.User.agenting & touch.ChosenTarget ~= 1
    TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).a_fails = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).a_fails + 1; %%%% dit ook nog voor de rest doen    
    TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_fails = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_fails + 1;
    idle(time_out, [1 0 0], 5);
    sound(y2, fs2);
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
    goodmonkey(reward_dur1);
    idle(0, [0 1 0], 5);
    sound(y1, fs1);
    TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).p_success = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).p_success + 1; %%%% dit ook nog voor de rest doen
    TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).p_success = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).p_success + 1;
elseif TrialRecord.User.patienting & touch.ChosenTarget ~= 2
    TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).p_fails = TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).p_fails + 1; %%%% dit ook nog voor de rest doen       
    TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).p_fails = TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).p_fails + 1;
    idle(time_out, [1 0 0], 5);
    sound(y2, fs2);
    if tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
    else
        dashboard(2, 'FAIL!!!');
        trialerror(6);
    end
end

if TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_success == 1 ...
        || TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_fails == TrialRecord.User.max_fails
    TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_completed = 1;
end
if TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_success == 1 ...
        || TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_fails == TrialRecord.User.max_fails
    TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).a_completed = 1;
end
if TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).p_success == 1 ...
        || TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).c_fails == TrialRecord.User.max_fails
    TrialRecord.User.initial_active_stim(TrialRecord.User.stimulus_chosen_in_initial_index).p_completed = 1;
end

% for initial_active_stim
c_boolean_fails = [TrialRecord.User.initial_active_stim.c_fails] == TrialRecord.User.max_fails;
TrialRecord.User.c_structure_completion = mean([TrialRecord.User.initial_active_stim.c_completed]);
a_boolean_fails = [TrialRecord.User.initial_active_stim.a_fails] == TrialRecord.User.max_fails;
TrialRecord.User.a_structure_completion = mean([TrialRecord.User.initial_active_stim.a_completed]);
p_boolean_fails = [TrialRecord.User.initial_active_stim.p_fails] == TrialRecord.User.max_fails;
TrialRecord.User.p_structure_completion = mean([TrialRecord.User.initial_active_stim.p_completed]);

% TrialRecord.User.overall_completion = mean(c_boolean_fails + [TrialRecord.User.initial_active_stim.c_success] ...
% + a_boolean_fails + [TrialRecord.User.initial_active_stim.a_success] + p_boolean_fails + [TrialRecord.User.initial_active_stim.p_success]) ... 
% /(TrialRecord.User.agent_on+TrialRecord.User.patient_on+TrialRecord.User.category);
TrialRecord.User.overall_active_completion = mean([TrialRecord.User.initial_active_stim.c_completed] + [TrialRecord.User.initial_active_stim.a_completed] + [TrialRecord.User.initial_active_stim.p_completed])/(TrialRecord.User.agent_on+TrialRecord.User.patient_on+TrialRecord.User.category);

% TrialRecord.User.active_stim_completion = (mean(c_boolean_fails + [TrialRecord.User.structure.c_success] ...
% + a_boolean_fails + [TrialRecord.User.structure.a_success] + p_boolean_fails + [TrialRecord.User.structure.p_success]) ... 
% /(TrialRecord.User.agent_on+TrialRecord.User.patient_on+TrialRecord.User.category)) * length(TrialRecord.User.structure)/TrialRecord.User.blocksize;


TrialRecord.User.completed_stimuli = sum([TrialRecord.User.initial_active_stim.c_completed] + [TrialRecord.User.initial_active_stim.a_completed] + [TrialRecord.User.initial_active_stim.p_completed], 'all');

%%%%%%%%%%%%%%%%%
% add parameters to the bhv2 files with function from monkeylogic
% size progressie, category or agent patient prgression, performance, time
% to answer, stimulus name.
bhv_variable('performance_previous_block', TrialRecord.User.performance,...
    'progression_number', TrialRecord.User.progression_number,...
    'stimulus_name', TrialRecord.User.structure(TrialRecord.User.stimulus_chosen_in_structure_index).stimuli,...
    'init_active_stim_completion', TrialRecord.User.overall_active_completion, ...
    'init_active_stim', TrialRecord.User.initial_active_stim, ...
    'completed_stim', TrialRecord.User.completed_stimuli);
if TrialRecord.User.training_categorization || TrialRecord.User.training_agent_patient
    bhv_variable('size_progression', TrialRecord.User.size_progression,...
        'category_progression', TrialRecord.User.category_progression);
end