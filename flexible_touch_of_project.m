hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(reward_dur, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');   % manual reward
hotkey('p', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number + 1;');
hotkey('m', 'TrialRecord.User.progression_number = TrialRecord.User.progression_number - 1; dashboard(1, string(TrialRecord.User.progression_number));');
dashboard(1, string(TrialRecord.User.progression_number));
%% designing engage_button
% draw button box
engage_box = BoxGraphic(null_);
engage_box.List = { [1 1 1], [1 1 1], 2, [10 0] };

% set touch target
fix = SingleTarget(touch_);
fix.Target = [10 0];
fix.Threshold = 2;
%% designing trial buttons

% determining correct button in case of training

standard_button_size = 2;
button_size_difference = 1.5;
button_size_step = (1 - TrialRecord.User.size_progression * 0.2) * button_size_difference;
if button_size_step > 0
    correct_button_size = 2 + button_size_step;
    if TrialRecord.User.current_sum_categories == 2
        wrong_button_size = 2 - button_size_step; %%%%%%%% hier schort toch nog iets, ik wil vanaf 3 knoppen, alleen de nieuwe nieuwe knop aanpassen.
    else
        wrong_button_size = standard_button_size;
    end
else
    correct_button_size = standard_button_size;
    wrong_button_size = standard_button_size; %%%% aanpassen met if statement naargelang category progression
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if TrialRecord.User.current_sum_categories == 2
%     new_button = grooming_box;
% elseif TrialRecord.User.current_sum_categories == 3
%     new_button = holding_box;
% elseif TrialRecord.User.current_sum_categories == 4
%     new_button = mounting_box;
% end

new_button_size = % de new_button is altijd de laatste button

%drawing button boxes

trial_box = BoxGraphic(null_);

chasing_box = {[1 0 0], [1 0 0], 2, [-8 -7]};
grooming_box = {[0 1 0], [0 1 0], 2, [-8 -2.34]};
holding_box = {[0 0 1], [0 0 1], 2, [-8 2.34]};
mounting_box = {[1 1 0], [1 1 0], 2, [-8 7]};
agent_box = {[0 1 1], [0 1 1], 2, [8 -3]};
patient_box = {[1 0 1], [1 0 1], 2, [8 3]};
    
if TrialRecord.User.training_categorization
    if TrialRecord.User.chasing
        chasing_box = {[1 0 0], [1 0 0], correct_button_size, [-8 -7]};
        grooming_box = {[0 1 0], [0 1 0], wrong_button_size, [-8 -2.34]};
        holding_box = {[0 0 1], [0 0 1], wrong_button_size, [-8 2.34]};
        mounting_box = {[1 1 0], [1 1 0], wrong_button_size, [-8 7]};
    elseif TrialRecord.User.grooming
        chasing_box = {[1 0 0], [1 0 0], wrong_button_size, [-8 -7]};
        grooming_box = {[0 1 0], [0 1 0], correct_button_size, [-8 -2.34]};
        holding_box = {[0 0 1], [0 0 1], wrong_button_size, [-8 2.34]};
        mounting_box = {[1 1 0], [1 1 0], wrong_button_size, [-8 7]};
    elseif TrialRecord.User.holding
        chasing_box = {[1 0 0], [1 0 0], wrong_button_size, [-8 -7]};
        grooming_box = {[0 1 0], [0 1 0], wrong_button_size, [-8 -2.34]};
        holding_box = {[0 0 1], [0 0 1], correct_button_size, [-8 2.34]};
        mounting_box = {[1 1 0], [1 1 0], wrong_button_size, [-8 7]};
    elseif TrialRecord.User.mounting
        chasing_box = {[1 0 0], [1 0 0], wrong_button_size, [-8 -7]};
        grooming_box = {[0 1 0], [0 1 0], wrong_button_size, [-8 -2.34]};
        holding_box = {[0 0 1], [0 0 1], wrong_button_size, [-8 2.34]};
        mounting_box = {[1 1 0], [1 1 0], correct_button_size, [-8 7]};
    end
end
if TrialRecord.User.training_agent_patient
    if TrialRecord.User.agenting
        agent_box = {[0 1 1], [0 1 1], correct_button_size, [8 -3]};
        patient_box = {[1 0 1], [1 0 1], wrong_button_size, [8 3]};
    elseif TrialRecord.User.patienting
        agent_box = {[0 1 1], [0 1 1], wrong_button_size, [8 -3]};
        patient_box = {[1 0 1], [1 0 1], correct_button_size, [8 3]};
    end
end

nr_boxes = TrialRecord.User.current_sum_categories;
all_boxes = [chasing_box; grooming_box; holding_box; mounting_box; agent_box; patient_box];
if TrialRecord.User.categorizing
    trial_box.List = all_boxes(1:nr_boxes, 1:4);
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    if nr_boxes == 1
        trial_box.List = all_boxes(TrialRecord.CurrentCondition, 1:4);
    else
        trial_box.List = all_boxes(5:6, 1:4); % hier mag ik maar 1 input geven als progression number 0 is, want singletarget.
    end
end

% setting touch targets
if nr_boxes == 1
    touch = SingleTarget(touch_);
else
    touch = MultiTarget(touch_);
    touch.WaitTime = 150000;
    touch.HoldTime = 0;
end
all_targets = [all_boxes{1, 4}; all_boxes{2, 4}; all_boxes{3, 4}; all_boxes{4, 4}; all_boxes{5, 4}; all_boxes{6, 4}];
if TrialRecord.User.categorizing
    touch.Target = all_targets(1:nr_boxes, :);
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    if nr_boxes == 1
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

tc_movie = TimeCounter(null_);
tc_movie.Duration = 3000;
tc_answer = TimeCounter(null_);
tc_answer.Duration = 5000;

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
while istouching
    idle(0);
end
if TrialRecord.User.categorizing
    set_bgcolor([1 0.5 1]);   % change the background color  
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    set_bgcolor([1 1 1]);
end

scene3 = create_scene(con3, 1); % something goes wrong here with the task object for some reason, works without task object
run_scene(scene3, 10);

set_bgcolor([]);        % change it back to the original color
idle(0);
%% evaluate
[y, fs] = audioread('test.wav');
if nr_boxes == 1
    if touch.Success
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y, fs);
    end
else
    if TrialRecord.User.chasing & touch.ChosenTarget == 1
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y, fs);
    elseif TrialRecord.User.grooming & touch.ChosenTarget == 2
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y, fs);
    elseif TrialRecord.User.holding & touch.ChosenTarget == 3
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y, fs);
    elseif TrialRecord.User.mounting & touch.ChosenTarget == 4
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y, fs);
    elseif TrialRecord.User.agenting & touch.ChosenTarget == 1
        dashboard(2, 'success!!! <3 ');
        trialerror(0);
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y, fs);
    elseif TrialRecord.User.patienting & touch.ChosenTarget == 2
        dashboard(2, 'success!!! <3 ');
        trialerror(0)
        goodmonkey(reward_dur);
        idle(0, [0 1 0], 20);
        TrialRecord.User.repeat = false;
        sound(y, fs);
    elseif tc_answer.Success
        dashboard(2, 'no response');
        trialerror(1);
        idle(5000, [1 0 0], 20);
        TrialRecord.User.repeat = true;  % if repeat, progression number should not change!!!
    else
        dashboard(2, 'FAIL!!!');
        trialerror(6);
        idle(5000, [1 0 0], 20);
        TrialRecord.User.repeat = true;
    end
end