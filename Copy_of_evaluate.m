function [performance, nextblock, repeat_vector] = ...
    Copy_of_evaluate(trialerrors, repeat_vector, succes_threshold, fail_threshold, currentblock)

trialerrors = trialerrors(end-(length(repeat_vector)-1):end);
boolean_trialerrors = trialerrors == 0;
performance = mean(boolean_trialerrors(repeat_vector == 0));
if performance >= succes_threshold                     % if performance is over the threshold, add a progression number
        nextblock = ... 
            currentblock + 1;
elseif performance <= fail_threshold                   % if performance is under the threshold and progression number is not already at the min progression number, substract a progression number
    nextblock = ... 
        currentblock - 1;
else
    nextblock = currentblock;
end
repeat_vector = [];
% [structure(indexes_used_c_stimuli).c_last_block] = deal(0);
% [structure(indexes_used_a_stimuli).a_last_block] = deal(0);
% [structure(indexes_used_p_stimuli).p_last_block] = deal(0);
disp(['performance:' string(performance)]);
disp('last blocksize reset in struct');
end

