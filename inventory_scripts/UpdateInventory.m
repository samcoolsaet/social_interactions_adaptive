function [updated_inventory] = UpdateInventory(inventory) % this is to update the inventory.m file with al the frame names, their origin, length and width.
updated_inventory  = inventory;
chasing_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\categorizing\frames\chasing');
chasing_frames(1:2) = [];
grooming_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\categorizing\frames\grooming');
grooming_frames(1:2) = [];
mounting_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\categorizing\frames\mounting');
mounting_frames(1:2) = [];
holding_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\categorizing\frames\holding');
holding_frames(1:2) = [];
gen_chasing_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\categorizing\frames\gen_chasing');
gen_chasing_frames(1:2) = [];
gen_grooming_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\categorizing\frames\gen_grooming');
gen_grooming_frames(1:2) = [];
gen_mounting_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\categorizing\frames\gen_mounting');
gen_mounting_frames(1:2) = [];
gen_holding_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\categorizing\frames\gen_holding');
gen_holding_frames(1:2) = [];

edgeless = dir("D:\onedrive\OneDrive - KU Leuven\social_interactions\agent_patient\frames\gen_grooming");
edgeless(1:2) = [];
frame_list = string({edgeless.name});

% frame_list = horzcat({chasing_frames.name},{grooming_frames.name},{mounting_frames.name},{holding_frames.name},...
%     {gen_chasing_frames.name},{gen_grooming_frames.name},{gen_mounting_frames.name},{gen_holding_frames.name});
% frame_list = string(frame_list);

for i = 1:length(frame_list)
    if ~ismember(frame_list(i), string({inventory.name}))
        updated_inventory(end+1).name = frame_list(i);
    end
end

% sort alphabetically
order = sort(lower([updated_inventory.name]));
match_list = [];
for i = 1:length([updated_inventory.name])
    match = find(matches(lower([updated_inventory.name]), order(i)));
    match_list(end+1) = match;
end
updated_inventory = updated_inventory(match_list);
inventory = updated_inventory;
% fill in gray coordinates
for i = 1:length(inventory)
    if contains(inventory(i).name, '_gray.')
        char_array = convertStringsToChars(inventory(i).name);
        start_index = strfind(char_array, '_gray.');
        char_array(start_index:start_index+length('gray')) = [];
        if ismember(char_array, [inventory.name])
            index = find(matches([inventory.name], char_array));
            if ~isempty(inventory(index).a_origin)
                inventory(i).a_origin = inventory(index).a_origin;
                inventory(i).a_width = inventory(index).a_width;
                inventory(i).a_height = inventory(index).a_height;
                inventory(i).p_origin = inventory(index).p_origin;
                inventory(i).p_width = inventory(index).p_width;
                inventory(i).p_height = inventory(index).p_height;
                inventory(i).a_degrees = inventory(index).a_degrees;
                inventory(i).p_degrees = inventory(index).p_degrees;
            end
        end
    end
end

% calculate mirrored origins
for i = 1:length(inventory)
    if contains(inventory(i).name, '_mirror')
        char_array = convertStringsToChars(inventory(i).name);
        start_index = strfind(char_array, '_mirror');
        char_array(start_index:start_index+length('mirror')) = [];
        if ismember(char_array, [inventory.name])
            index = find(matches([inventory.name], char_array));
            if ~isempty(inventory(index).a_origin)
                inventory(i).a_origin = [512-inventory(index).a_origin(1) inventory(index).a_origin(2)];
                inventory(i).a_width = inventory(index).a_width;
                inventory(i).a_height = inventory(index).a_height;
                inventory(i).p_origin = [512-inventory(index).p_origin(1) inventory(index).p_origin(2)];
                inventory(i).p_width = inventory(index).p_width;
                inventory(i).p_height = inventory(index).p_height;
                inventory(i).a_degrees = inventory(index).a_degrees;
                inventory(i).p_degrees = inventory(index).p_degrees;
            end
        end
    end
end




% pix_per_deg =  MLConfig.PixelsPerDegree.
% Images are 512*288
% I tilt the images 90 degrees to the left, so my start pixel ( upper left corner ) point becomes [0 512], so x pixels become y and y pixels become (512-x)
tilted_pixels = zeros(2, length(inventory),2);
for i = 1:length(inventory)
    if ~isempty(inventory(i).a_origin)
        tilted_pixels(1,i,1:2) = [inventory(i).a_origin(2) (512-inventory(i).a_origin(1))];
        tilted_pixels(2,i,1:2) = [inventory(i).p_origin(2) (512-inventory(i).p_origin(1))];
    end
end
% Keeping this into account, the center ( where degrees start 0 ) is [144 256] in pixels
% to centralize the source to the middle of the screen in pixels, I would have have to substract the center [ 320 180 ]from the original pixel coordinates.
centralized_pixels = zeros(2, length(inventory),2);
for i = 1:length(inventory)
    if ~isempty(inventory(i).a_origin)
        centralized_pixels(1,i,1:2) = [(tilted_pixels(1,i,1)-144) (256-tilted_pixels(1,i,2))];
        centralized_pixels(2,i,1:2) = [(tilted_pixels(2,i,1)-144) (256-tilted_pixels(2,i,2))];
    end
end

pix_per_deg = 26.6462;
degrees = zeros(2, length(inventory),2);
for i = 1:length(inventory)
    if ~isempty(inventory(i).a_origin)
        degrees(1,i,1:2) = [centralized_pixels(1,i,1)/pix_per_deg centralized_pixels(1,i,2)/pix_per_deg]*1.25; % I'm scaling images up with 1.25, which makes the size 640*360 during the task
        degrees(2,i,1:2) = [centralized_pixels(2,i,1)/pix_per_deg centralized_pixels(2,i,2)/pix_per_deg]*1.25; % I'm scaling images up with 1.25, which makes the size 640*360 during the task
    end
end
for i = 1:length(inventory)
    inventory(i).a_degrees = degrees(1,i,:);
    inventory(i).p_degrees = degrees(2,i,:);
end
end