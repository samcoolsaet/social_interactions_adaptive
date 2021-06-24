function [structure, performance] = evaluate(inputArg1,inputArg2)
% evaluate old structure and create new one
% ik heb hier wel het probleem dat ik de structure al reset wnr die
% eigenlijk nog niet compleet is, dit zorgt ervoor dat ik bepaalde stimuli
% niet ga tonen en andere meerdere keren. ik zou dit kunnen oplossen met
% een extra field te creeeren waarin staat of ze gedurende de laatste block
% gebruikt zijn, zo kan ik nog altijd enkel die blok evalueren zonder aan
% te passen of zo completed zijn.
indexes_used_c_stimuli = find([TrialRecord.User.structure.c_completed]==1); % find the completed stimuli
indexes_used_a_stimuli = find([TrialRecord.User.structure.a_completed]==1); % 
indexes_used_p_stimuli = find([TrialRecord.User.structure.p_completed]==1); %
fails = [TrialRecord.User.structure(indexes_used_c_stimuli).c_fails...      % isolate the fails field of these completed stimuli
    TrialRecord.User.structure(indexes_used_a_stimuli).a_fails...
    TrialRecord.User.structure(indexes_used_p_stimuli).p_fails];
corrects = (fails == 0);                                                % correct for the first time means that there are no fails
TrialRecord.User.performance = mean(corrects);                          % performance is the corrects/completed stimuli
if TrialRecord.User.performance >= succes_threshold                     % if performance is over the threshold, add a progression number
        TrialRecord.NextBlock = ... 
            TrialRecord.CurrentBlock + 1;
elseif TrialRecord.User.performance <= fail_threshold                   % if performance is under the threshold and progression number is not already at the min progression number, substract a progression number
    TrialRecord.NextBlock = ... 
        TrialRecord.CurrentBlock - 1;
end
[TrialRecord.User.structure(indexes_used_c_stimuli).c_success] = deal(0);   % reset all the completed stimuli
[TrialRecord.User.structure(indexes_used_c_stimuli).c_fails] = deal(0);     % this way, the data of the used, but not completed ones stays in there
[TrialRecord.User.structure(indexes_used_c_stimuli).c_completed] = deal(0);
[TrialRecord.User.structure(indexes_used_a_stimuli).a_success] = deal(0);
[TrialRecord.User.structure(indexes_used_a_stimuli).a_fails] = deal(0);
[TrialRecord.User.structure(indexes_used_c_stimuli).a_completed] = deal(0);
[TrialRecord.User.structure(indexes_used_p_stimuli).p_success] = deal(0);
[TrialRecord.User.structure(indexes_used_p_stimuli).p_fails] = deal(0);
[TrialRecord.User.structure(indexes_used_c_stimuli).p_completed] = deal(0);
disp(['performance:' string(TrialRecord.User.performance)]);
disp('last blocksize reset in struct');
end

