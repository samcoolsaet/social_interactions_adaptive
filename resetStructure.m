function [structure] = resetStructure(structure)
indexes_c_completed = find([structure.c_completed]==1);
indexes_c_last_block = find([structure.c_last_block]==1);
indexes_c_reset = setdiff(indexes_c_completed, indexes_c_last_block);
indexes_a_completed = find([structure.a_completed]==1);
indexes_a_last_block = find([structure.a_last_block]==1);
indexes_a_reset = setdiff(indexes_a_completed, indexes_a_last_block);
indexes_p_completed = find([structure.p_completed]==1);
indexes_p_last_block = find([structure.p_last_block]==1);
indexes_p_reset = setdiff(indexes_p_completed, indexes_p_last_block);

[structure(indexes_c_reset).c_success] = deal(0);   % reset all the completed stimuli
[structure(indexes_c_reset).c_fails] = deal(0);     % this way, the data of the used, but not completed ones stays in there
[structure(indexes_c_reset).c_completed] = deal(0);
[structure(indexes_a_reset).a_success] = deal(0);
[structure(indexes_a_reset).a_fails] = deal(0);
[structure(indexes_a_reset).a_completed] = deal(0);
[structure(indexes_p_reset).p_success] = deal(0);
[structure(indexes_p_reset).p_fails] = deal(0);
[structure(indexes_p_reset).p_completed] = deal(0);
disp('struct reset');
end

