hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(reward_dur, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');   % manual reward
hotkey('p', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number + 1;');
hotkey('m', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number - 1; dashboard(1, string(TrialRecord.User.progression_number));');
dashboard(1, string(TrialRecord.User.progression_number));

%%%%%%%%%%%%%
% add parameters to the bhv2 files with function from monkeylogic
% size progressie, category or agent patient prgression, performance, time
% to answer, stimulus name.
%%%%%%%%%%%%%
%% designing engage_button
% draw button box
engage_box = BoxGraphic(null_);
engage_box.List = { [1 1 1], [1 1 1], 2, [10 0] };

% set touch target
fix = SingleTarget(touch_);
fix.Target = [10 0];
fix.Threshold = 2;
%% designing trial buttons

% determining correct button size in case of training

standard_button_size = 2;
button_size_difference = 1.5;
button_size_step = (1 - TrialRecord.User.size_progression/...
    TrialRecord.User.size_progression_factor) * button_size_difference;
if button_size_step > 0
    correct_button_size = 2 + button_size_step;
    wrong_button_size = 2 - button_size_step;
else
    correct_button_size = standard_button_size;
    wrong_button_size = standard_button_size;
end

%  init boxes
chasing_box = {[1 0 0], [1 0 0], 2, [-8 -7]};
grooming_box = {[0 1 0], [0 1 0], 2, [-8 -2.34]};
holding_box = {[0 0 1], [0 0 1], 2, [-8 2.34]};
mounting_box = {[1 1 0], [1 1 0], 2, [-8 7]};
agent_box = {[0 1 1], [0 1 1], 2, [8 -3]};
patient_box = {[1 0 1], [1 0 1], 2, [8 3]};

% only adjust last added button to correct, wrong or standard size,
% depending on corrext answer
if TrialRecord.User.training_categorization
    if TrialRecord.User.current_sum_categories == 1
        if TrialRecord.User.chasing
            chasing_box = {[1 0 0], [1 0 0], correct_button_size, [-8 -7]};
        else
            chasing_box = {[1 0 0], [1 0 0], wrong_button_size, [-8 -7]};
        end
    else
        chasing_box = {[1 0 0], [1 0 0], standard_button_size, [-8 -7]};
    end
    if TrialRecord.User.current_sum_categories == 2
        if TrialRecord.User.grooming
            grooming_box = {[0 1 0], [0 1 0], correct_button_size, [-8 -2.34]};
        else
            grooming_box = {[0 1 0], [0 1 0], wrong_button_size, [-8 -2.34]};
        end
    else
        grooming_box = {[0 1 0], [0 1 0], standard_button_size, [-8 -2.34]};
    end
    if TrialRecord.User.current_sum_categories == 3
        if TrialRecord.User.holding
            holding_box = {[0 0 1], [0 0 1], correct_button_size, [-8 2.34]};
        else
            holding_box = {[0 0 1], [0 0 1], wrong_button_size, [-8 2.34]};
        end
    else
        holding_box = {[0 0 1], [0 0 1], standard_button_size, [-8 2.34]};
    end
    if TrialRecord.User.current_sum_categories == 4
        if TrialRecord.User.mounting
            mounting_box = {[1 1 0], [1 1 0], correct_button_size, [-8 7]};
        else
            mounting_box = {[1 1 0], [1 1 0], wrong_button_size, [-8 7]};
        end
    else
        mounting_box = {[1 1 0], [1 1 0], standard_button_size, [-8 7]};
    end
end
if TrialRecord.User.training_agent_patient
    if TrialRecord.User.current_sum_categories == 1
        if TrialRecord.User.agenting
            agent_box = {[0 1 1], [0 1 1], correct_button_size, [8 -3]};
        else
            agent_box = {[0 1 1], [0 1 1], wrong_button_size, [8 -3]};
        end
    else
        agent_box = {[0 1 1], [0 1 1], standard_button_size, [8 -3]};
    end
    if TrialRecord.User.current_sum_categories == 2
        if TrialRecord.User.patienting
            patient_box = {[1 0 1], [1 0 1], correct_button_size, [8 3]};
        else
            patient_box = {[1 0 1], [1 0 1], wrong_button_size, [8 3]};
        end
    else
        patient_box = {[1 0 1], [1 0 1], standard_button_size, [8 3]};
    end
end

%drawing button boxes

trial_box = BoxGraphic(null_);

all_boxes = [chasing_box; grooming_box; holding_box; mounting_box; agent_box; patient_box];
if TrialRecord.User.categorizing
    if TrialRecord.User.current_sum_categories >= 4 % if all categories are involved, show the 4 boxes
        trial_box.List = all_boxes(1:4, 1:4);
    else
        trial_box.List = all_boxes(1:TrialRecord.User.current_sum_categories, 1:4);% else, show the number of involved categories
    end
elseif TrialRecord.User.agenting || TrialRecord.User.patienting % analogous when agent patient
    if TrialRecord.User.current_sum_categories == 1
        trial_box.List = all_boxes(TrialRecord.CurrentCondition, 1:4);
    else
        trial_box.List = all_boxes(5:6, 1:4); % hier mag ik maar 1 input geven als progression number 0 is, want singletarget.
    end
end

% setting touch targets
if TrialRecord.User.current_sum_categories == 1
    touch = SingleTarget(touch_);
else
    touch = MultiTarget(touch_);
    touch.WaitTime = 150000;
    touch.HoldTime = 0;
end
all_targets = [all_boxes{1, 4}; all_boxes{2, 4}; all_boxes{3, 4}; all_boxes{4, 4}; all_boxes{5, 4}; all_boxes{6, 4}];
if TrialRecord.User.categorizing
    if TrialRecord.User.current_sum_categories >= 4 % if all categories are involved, show the 4 boxes
        touch.Target = all_targets(1:4, :);
    else
        touch.Target = all_targets(1:TrialRecord.User.current_sum_categories, :); % else, show the number of involved categories
    end
% touch.Target = all_targets(1:TrialRecord.User.current_sum_categories, :);
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    if TrialRecord.User.current_sum_categories == 1
        touch.Target = all_targets(TrialRecord.CurrentCondition, :);
    else
        touch.Target = all_targets(5:6, :); % hier mag ik maar 1 input geven als progression number 0 is, want singletarget.
    end
end
touch.Threshold = 2;
%% setting up animations and frames
mov = MovieGraphic(fix);
mov.List = { TrialRecord.User.movie, [0 0], 0, 1.25, 90 };   % movie filename
% tc = TimeCounter(mov);
img = ImageGraphic(null_);
img.List = { TrialRecord.User.frame, [0 0], 0, 1.25, 90 };
%% constructing scenes
% setting timecounter for duration of animation in first scene and time to
% answer
% movie_duration = 3000;
% answer_time = 5000;
% tc_movie = TimeCounter(null_);
% tc_movie.Duration = movie_duration;
% tc_answer = TimeCounter(null_);
% tc_answer.Duration = answer_time;

movie_duration = 3000;
answer_time = 5000;
tc_movie = TimeCounter(null_);
tc_movie.Duration = movie_duration;
tc_answer = TimeCounter(touch);
tc_answer.Duration = answer_time;

% webcam
% cam = WebcamMonitor(null_);
% cam.CamNumber = 1;

% merging touch and visual for engagement button
con1 = Concurrent(fix);
con1.add(engage_box);

% running timecounter and showing buttons together for first scene
con2 = Concurrent(tc_movie);
con2.add(mov);

% showing buttons and adding touch targets. restricted by answer
% timecounter
or = OrAdapter(touch);
or.add(tc_answer);
con3 = Concurrent(or);
con3.add(img);
con3.add(trial_box);

% temporary cue

cue = CircleGraphic(null_);
cue.List = {[1 1 1], [1 1 1], 1, [0 0] };
if TrialRecord.User.agenting
    con3.add(cue);
end
%% running scenes
% run engagement scene
scene1 = create_scene(con1);
run_scene(scene1, 10);

% run animation scene

% % tf = istouching; %% maybe ad an adapter to this scene to learn Luca that
% % he should release the button? Give him some idle time to release.
% tf = istouching;
% if ~tf
scene2 = create_scene(con2);
run_scene(scene2, 10);

% run frame and answering scene
tf = istouching;
while istouching  % while touching, do not proceed to the buttons
    idle(0);
end
if TrialRecord.User.categorizing
    set_bgcolor([1 0.5 1]);   % change the background color  
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    set_bgcolor([1 1 1]);
end

scene3 = create_scene(con3, 1);
fliptime = run_scene(scene3, 10);

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
% reward_factor = 0.25;
% max_reward_dur = 100;
% min_reward_dur = 50;
% reward_window = max_reward_dur - min_reward_dur;
% % expected_progression = 10; % reward goes from min to max over 10
% % progression numbers
% variable_reward_portion = TrialRecord.User.progression_number/ ...          % here the variable portion is calculated based on a fraction of the complete task.
%     (TrialRecord.User.max_c_progression_number*reward_factor) * reward_window;
% % % this is the same but with a set progression number as goal for that day
% % variable_reward_portion = TrialRecord.User.progression_number/ ...    
% %     (expected_progression) * reward_window;
% 
% if variable_reward_portion <= 50                                            % I want to stay below max reward
%     reward_dur = min_reward_dur + variable_reward_portion;
% else
%     reward_dur = max_reward_dur;
% end

[y1, fs1] = audioread('test.wav');
[y2, fs2] = audioread('test2.wav');
if TrialRecord.User.current_sum_categories == 1
    if touch.Success
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y1, fs1);
    elseif tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
        sound(y2, fs2);
        idle(5000, [1 0 0], 20);
        TrialRecord.User.repeat = true;  % if repeat, progression number should not change!!!
    end
else
    if TrialRecord.User.chasing & touch.ChosenTarget == 1
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y1, fs1);
    elseif TrialRecord.User.grooming & touch.ChosenTarget == 2
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y1, fs1);
    elseif TrialRecord.User.holding & touch.ChosenTarget == 3
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y1, fs1);
    elseif TrialRecord.User.mounting & touch.ChosenTarget == 4
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y1, fs1);
    elseif TrialRecord.User.agenting & touch.ChosenTarget == 1
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y1, fs1);
    elseif TrialRecord.User.patienting & touch.ChosenTarget == 2
        dashboard(2, 'success!!! <3 ');
        trialerror(0)
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y1, fs1);
    elseif tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
        sound(y2, fs2);
        idle(5000, [1 0 0], 20);
        TrialRecord.User.repeat = true;  % if repeat, progression number should not change!!!
    else
        dashboard(2, 'FAIL!!!');
        trialerror(6);
        sound(y2, fs2);
        idle(5000, [1 0 0], 20);
        TrialRecord.User.repeat = true;
    end
end
% add parameters to the bhv2 files with function from monkeylogic
% size progressie, category or agent patient prgression, performance, time
% to answer, stimulus name.
bhv_variable('size_progression', TrialRecord.User.size_progression,...
    'category_progression', TrialRecord.User.category_progression,...
    'performance', TrialRecord.User.performance,...
    'progression_number', TrialRecord.User.progression_number,...
    'stimulus_name', TrialRecord.User.movie,...
    'index',TrialRecord.User.stimulus_sequence_index,...
    'answer_time', answer_time);