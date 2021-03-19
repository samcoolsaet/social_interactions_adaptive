hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);');
hotkey('r', 'goodmonkey(reward_dur, ''juiceline'', MLConfig.RewardFuncArgs.JuiceLine, ''eventmarker'', 14, ''nonblocking'', 1);');   % manual reward

%% designing engage_button
% draw button box
engage_box = BoxGraphic(null_);
engage_box.List = { [1 1 1], [1 1 1], 1, [10 0] };

% set touch target
fix = SingleTarget(touch_);
fix.Target = [10 0];
fix.Threshold = 1;
%% designing trial buttons
%drawing button boxes

trial_box = BoxGraphic(null_);

% chasing_box = {[1 0 0], [1 0 0], 1, [-8 -7]};
% grooming_box = {[0 1 0], [0 1 0], 1.25, [-8 -3]};
% holding_box = {[0 0 1], [0 0 1], 1, [-8 3]};
% mounting_box = {[1 1 0], [1 1 0], 1, [-8 7]};

% no_boxes = TrialRecord.User.chasing_on + TrialRecord.User.grooming_on + TrialRecord.User.holding_on + TrialRecord.User.mounting_on;
% box_features = [chasing_box; grooming_box; holding_box; mounting_box]
if TrialRecord.User.categorizing
    trial_box.List = { [1 0 0], [1 0 0], 1, [-8 -7]; ...
        [0 1 0], [0 1 0], 1.25, [-8 -3];...
        [0 0 1], [0 0 1], 1, [-8 3]; ...
        [1 1 0], [1 1 0], 1, [-8 7]};
%     trial_box.List = (no_boxes, 1:4);
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    trial_box.List = {[0 1 1], [0 1 1], 1, [8 -3]; ...
        [1 0 1], [1 0 1], 1, [8 3]};
end

% setting touch targets
mul = MultiTarget(touch_);
if TrialRecord.User.categorizing
    mul.Target = [-8 -7; -8 -3; -8 3; -8 7];
elseif TrialRecord.User.agenting || TrialRecord.User.patienting
    mul.Target = [8 -3; 8 3];
end
mul.Threshold = 1;
mul.WaitTime = 150000;
mul.HoldTime = 0;
%% setting up animations and frames
mov = MovieGraphic(fix);
mov.List = { TrialRecord.User.movie, [0 0], 0, 1.25, 90 };   % movie filename
% tc = TimeCounter(mov);
img = ImageGraphic(null_);
img.List = { TrialRecord.User.frame, [0 0], 0, 1.25, 90 };
%% constructing scenes
% setting timecounter for duration of animation in first scene

tc = TimeCounter(null_);
tc.Duration = 3000;

% merging touch and visual for engagement button
con1 = Concurrent(fix);
con1.add(engage_box);

% running timecounter and showing buttons together for first scene
con2 = Concurrent(tc);
con2.add(mov);
con2.add(trial_box);

% showing buttons and adding touch targets.
con3 = Concurrent(mul);
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
scene3 = create_scene(con3, 1);
run_scene(scene3, 10);

%% evaluate
if TrialRecord.User.chasing & mul.ChosenTarget == 1
    dashboard(2, 'success!!! <3 ');
    trialerror(0);
    goodmonkey(reward_dur);
elseif TrialRecord.User.grooming & mul.ChosenTarget == 2
    dashboard(2, 'success!!! <3 ');
    trialerror(0);
    goodmonkey(reward_dur);
elseif TrialRecord.User.holding & mul.ChosenTarget == 3
    dashboard(2, 'success!!! <3 ');
    trialerror(0);
    goodmonkey(reward_dur);
elseif TrialRecord.User.mounting & mul.ChosenTarget == 4
    dashboard(2, 'success!!! <3 ');
    trialerror(0);
    goodmonkey(reward_dur);
elseif TrialRecord.User.agenting & mul.ChosenTarget == 1
    dashboard(2, 'success!!! <3 ');
    trialerror(0);
    goodmonkey(reward_dur);
elseif TrialRecord.User.patienting & mul.ChosenTarget == 2
    dashboard(2, 'success!!! <3 ');
    trialerror(0)
    goodmonkey(reward_dur);
else
    dashboard(2, 'FAIL!!!');
    trialerror(6);
end

idle(0,[], 20);