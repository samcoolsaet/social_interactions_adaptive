function [struct_index] = Copy_of_pickStimulus(condition,structure, struct_conditions)

switch condition
    case 1
        [this_condition_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==1, struct_conditions(:,:,1))));
        [not_completed_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==0, struct_conditions(:,:,2))));
        available_indexes = intersect(this_condition_indexes, not_completed_indexes(1:length(structure)));
        struct_index = available_indexes(randperm(length(available_indexes), 1));
    case 2
        [this_condition_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==2, struct_conditions(:,:,1))));
        [not_completed_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==0, struct_conditions(:,:,2))));
        available_indexes = intersect(this_condition_indexes, not_completed_indexes(1:length(structure)));
        struct_index = available_indexes(randperm(length(available_indexes), 1));
    case 3
        [this_condition_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==3, struct_conditions(:,:,1))));
        [not_completed_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==0, struct_conditions(:,:,2))));
        available_indexes = intersect(this_condition_indexes, not_completed_indexes(1:length(structure)));
        struct_index = available_indexes(randperm(length(available_indexes), 1));
    case 4
        [this_condition_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==4, struct_conditions(:,:,1))));
        [not_completed_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==0, struct_conditions(:,:,2))));
        available_indexes = intersect(this_condition_indexes, not_completed_indexes(1:length(structure)));
        struct_index = available_indexes(randperm(length(available_indexes), 1));
    case 5
        [this_condition_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==5, struct_conditions(:,:,1))));
        [not_completed_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==0, struct_conditions(:,:,2))));
        available_indexes = intersect(this_condition_indexes, not_completed_indexes(1:length(structure)));
        struct_index = available_indexes(randperm(length(available_indexes), 1));
    case 6
        [this_condition_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==6, struct_conditions(:,:,1))));
        [not_completed_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==0, struct_conditions(:,:,2))));
        available_indexes = intersect(this_condition_indexes, not_completed_indexes(1:length(structure)));
        struct_index = available_indexes(randperm(length(available_indexes), 1));
    case 7 % cellfun(@(x) x==1,a)
        [this_condition_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==7, struct_conditions(:,:,1))));
        [not_completed_indexes, ~] = ind2sub(size(struct_conditions(:,:,1)),...
            find(cellfun(@(x) x==0, struct_conditions(:,:,2))));
        available_indexes = intersect(this_condition_indexes, not_completed_indexes(1:length(structure)));
        struct_index = available_indexes(randperm(length(available_indexes), 1));
    otherwise
        disp('indexing into structure failed');
end
end

