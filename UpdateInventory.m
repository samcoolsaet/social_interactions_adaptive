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
frame_list = string(frame_list);

for i = 1:length(frame_list)
    if ~ismember(frame_list(i), string({inventory.name}))
        updated_inventory(end+1).name = frame_list(i);
    end
end

% pix_per_deg =  MLConfig.PixelsPerDegree.
% Images are 512*288
% I tilt the images 90 degrees to the left, so my start pixel ( upper left corner ) point becomes [0 512], so y pixels become x and x pixels become (512-y)
% I'm scaling images up with 1.25, which makes the size 640*360 during the task
% Keeping both of this into account, the center ( where degrees start 0 ) is [180 320] in pixels
% to centralize the source to the middle of the screen in pixels, I would have have to substract the center [ 320 180 ]from the original pixel coordinates.

end