function [updated_inventory] = UpdateInventory(inventory) % this is to update the inventory.m file with al the frame names, their origin, length and width.
updated_inventory  = inventory;
chasing_frames = dir('G:\sam\frames\frames\chasing');
chasing_frames(1:2) = [];
grooming_frames = dir('G:\sam\frames\frames\grooming');
grooming_frames(1:2) = [];
mounting_frames = dir('G:\sam\frames\frames\mounting');
mounting_frames(1:2) = [];
holding_frames = dir('G:\sam\frames\frames\holding');
holding_frames(1:2) = [];

frame_list = horzcat({chasing_frames.name},{grooming_frames.name},{mounting_frames.name},{holding_frames.name});

for i = 1:length(frame_list)
    if ~ismember(frame_list(i), {inventory.name})
        updated_inventory.name(end+1) = frame_list(i);
    end
end

end