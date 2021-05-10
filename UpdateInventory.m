function [updated_inventory] = UpdateInventory(inventory) % this is to update the inventory.m file with al the frame names, their origin, length and width.
updated_inventory  = inventory;
chasing_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\chasing');
chasing_frames(1:2) = [];
grooming_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\grooming');
grooming_frames(1:2) = [];
mounting_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\mounting');
mounting_frames(1:2) = [];
holding_frames = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\holding');
holding_frames(1:2) = [];

frame_list = horzcat({chasing_frames.name},{grooming_frames.name},{mounting_frames.name},{holding_frames.name});

for i = 1:length(frame_list)
    if ~ismember(frame_list(i), {inventory.name})
        updated_inventory(end+1).name = frame_list(i);
    end
end

end