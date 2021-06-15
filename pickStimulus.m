function [struct_index] = pickStimulus(condition,structure)
switch condition
    case 1
        index3 = 1;
        indexes_c_incomplete = [];
        while index3 ~= length(structure) + 1          % just iterate over the structure and see which ones are still available (not completed), given the condition
            if (strcmp(structure(index3).folder, 'chasing') || ...
                    strcmp(structure(index3).folder, 'gen_chasing'))...
                    && structure(index3).c_completed == 0
                indexes_c_incomplete(end+1) = index3;
            end
            index3 = index3 + 1;
        end
        index_index = randperm(length(indexes_c_incomplete), 1);
        struct_index = indexes_c_incomplete(index_index);
    case 2
        index3 = 1;
        indexes_c_incomplete = [];
        while index3 ~= length(structure) + 1
            if (strcmp(structure(index3).folder, 'grooming') || ...
                    strcmp(structure(index3).folder, 'gen_grooming'))...
                    && structure(index3).c_completed == 0
                indexes_c_incomplete(end+1) = index3;
            end
            index3 = index3 + 1;
        end
        index_index = randperm(length(indexes_c_incomplete), 1);
        struct_index = indexes_c_incomplete(index_index);
    case 3
        index3 = 1;
        indexes_c_incomplete = [];
        while index3 ~= length(structure) + 1
            if (strcmp(structure(index3).folder, 'mounting') || ...
                    strcmp(structure(index3).folder, 'gen_mounting'))...
                    && structure(index3).c_completed == 0
                indexes_c_incomplete(end+1) = index3;
            end
            index3 = index3 + 1;
        end
        index_index = randperm(length(indexes_c_incomplete), 1);
        struct_index = indexes_c_incomplete(index_index);
    case 4
        index3 = 1;
        indexes_c_incomplete = [];
        while index3 ~= length(structure) + 1
            if (strcmp(structure(index3).folder, 'holding') || ...
                    strcmp(structure(index3).folder, 'gen_holding'))...
                    && structure(index3).c_completed == 0
                indexes_c_incomplete(end+1) = index3;
            end
            index3 = index3 + 1;
        end
        index_index = randperm(length(indexes_c_incomplete), 1);
        struct_index = indexes_c_incomplete(index_index);
    case 5
        indexes_a_incomplete = find([structure.a_completed]==0);
        index_index = randperm(length(indexes_a_incomplete), 1);
        struct_index = indexes_a_incomplete(index_index);
    case 6
        indexes_p_incomplete = find([structure.p_completed]==0);
        index_index = randperm(length(indexes_p_incomplete), 1);
        struct_index = indexes_p_incomplete(index_index);
    otherwise
        disp('indexing into structure failed');
end
end

