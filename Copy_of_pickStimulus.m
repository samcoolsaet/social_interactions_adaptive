function [struct_index] = Copy_of_pickStimulus(condition,structure, struct_conditions)

struct_conditions = zeros(length(structure), 3);
for i = 1:length(structure)
    struct_conditions(i, :) = structure(i).condition;
end
switch condition
    case 1
        not_completed = find([structure.c_completed]==0);
        [this_condition placeholder] = find(struct_conditions==1);
        available_indexes = intersect(not_completed, this_condition);
        struct_index = available_indexes(randperm(length(available_indexes), 1));
%         index3 = 1;
%         indexes_c_incomplete = [];
%         while index3 ~= length(structure) + 1          % just iterate over the structure and see which ones are still available (not completed), given the condition
%             if (strcmp(structure(index3).folder, 'chasing') || ...
%                     strcmp(structure(index3).folder, 'gen_chasing'))...
%                     && structure(index3).c_completed == 0
%                 indexes_c_incomplete(end+1) = index3;
%             end
%             index3 = index3 + 1;
%         end
%         index_index = randperm(length(indexes_c_incomplete), 1);
%         struct_index = indexes_c_incomplete(index_index);
    case 2
        not_completed = find([structure.c_completed]==0);
        [this_condition placeholder] = find(struct_conditions==2);
        available_indexes = intersect(not_completed, this_condition);
        struct_index = available_indexes(randperm(length(available_indexes), 1));
%         index3 = 1;
%         indexes_c_incomplete = [];
%         while index3 ~= length(structure) + 1
%             if (strcmp(structure(index3).folder, 'grooming') || ...
%                     strcmp(structure(index3).folder, 'gen_grooming'))...
%                     && structure(index3).c_completed == 0
%                 indexes_c_incomplete(end+1) = index3;
%             end
%             index3 = index3 + 1;
%         end
%         index_index = randperm(length(indexes_c_incomplete), 1);
%         struct_index = indexes_c_incomplete(index_index);
    case 3
        not_completed = find([structure.c_completed]==0);
        [this_condition placeholder] = find(struct_conditions==3);
        available_indexes = intersect(not_completed, this_condition);
        struct_index = available_indexes(randperm(length(available_indexes), 1));
%         index3 = 1;
%         indexes_c_incomplete = [];
%         while index3 ~= length(structure) + 1
%             if (strcmp(structure(index3).folder, 'mounting') || ...
%                     strcmp(structure(index3).folder, 'gen_mounting'))...
%                     && structure(index3).c_completed == 0
%                 indexes_c_incomplete(end+1) = index3;
%             end
%             index3 = index3 + 1;
%         end
%         index_index = randperm(length(indexes_c_incomplete), 1);
%         struct_index = indexes_c_incomplete(index_index);
    case 4
        not_completed = find([structure.c_completed]==0);
        [this_condition placeholder] = find(struct_conditions==4);
        available_indexes = intersect(not_completed, this_condition);
        struct_index = available_indexes(randperm(length(available_indexes), 1));
%         index3 = 1;
%         indexes_c_incomplete = [];
%         while index3 ~= length(structure) + 1
%             if (strcmp(structure(index3).folder, 'holding') || ...
%                     strcmp(structure(index3).folder, 'gen_holding'))...
%                     && structure(index3).c_completed == 0
%                 indexes_c_incomplete(end+1) = index3;
%             end
%             index3 = index3 + 1;
%         end
%         index_index = randperm(length(indexes_c_incomplete), 1);
%         struct_index = indexes_c_incomplete(index_index);
    case 5
        available_indexes = find([structure.a_completed]==0);
        struct_index = available_indexes(randperm(length(available_indexes), 1));
%         index_index = randperm(length(indexes_a_incomplete), 1);
%         struct_index = indexes_a_incomplete(index_index);
    case 6
        available_indexes = find([structure.p_completed]==0);
        struct_index = available_indexes(randperm(length(available_indexes), 1));
%         index_index = randperm(length(indexes_p_incomplete), 1);
%         struct_index = indexes_p_incomplete(index_index);
    otherwise
        disp('indexing into structure failed');
end
end

