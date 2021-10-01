function [bitmap, origin, width_degrees, height_degrees] = FrameCreator(name, condition)
load('inventory.mat');

identify_frame_inventory = strcmp([inventory.name], name);
inventory_index = find(identify_frame_inventory==1);
pix_per_deg = 26.6462;

if condition == 5
    origin = [inventory(inventory_index).a_degrees(1) inventory(inventory_index).a_degrees(2)];
    width = inventory(inventory_index).a_width;
    height = inventory(inventory_index).a_height;
elseif condition == 6
    origin = [inventory(inventory_index).p_degrees(1) inventory(inventory_index).p_degrees(2)];
    width = inventory(inventory_index).p_width;
    height = inventory(inventory_index).p_height;
elseif condition == 7
    origin = [inventory(inventory_index).b_degrees(1) inventory(inventory_index).b_degrees(2)];
    width = inventory(inventory_index).b_width;
    height = inventory(inventory_index).b_height;    
else
    disp('condition not found');
end

width_degrees = width/pix_per_deg;
height_degrees = height/pix_per_deg;

% pix_per_deg =  MLConfig.PixelsPerDegree.

line_thickness = 5;

alpha = zeros(height, width);
red = zeros(height, width);
green = zeros(height, width);
blue = zeros(height, width);

red(1:line_thickness,:) = ones(line_thickness, width);
red(end-(line_thickness-1):end,:) = ones(line_thickness, width);
red(:,1:line_thickness) = ones(height, line_thickness);
red(:,end-(line_thickness-1):end) = ones(height, line_thickness);

alpha(1:line_thickness,:) = ones(line_thickness, width);
alpha(end-(line_thickness-1):end,:) = ones(line_thickness, width);
alpha(:,1:line_thickness) = ones(height, line_thickness);
alpha(:,end-(line_thickness-1):end) = ones(height, line_thickness);


bitmap = cat(3, alpha, red, green, blue);
% bitmap = cat(3, red, green, blue);


% mglcreatesubjectscreen(2, [1 1 1])   % Do not use the adapter_no of the current screen
% % mglcreatecontrolscreen([400 300 800 600])      % Need to create the subject screen first
% % id = mgladdbox([1 1 1; 1 1 1],[100 100]);
% id = mgladdbitmap(bitmap);
% mglsetproperty(id,'active',1,'origin',origin);
% mglrendergraphic
% mglpresent
% 
% pause(2);
% 
% mgldestroygraphic(id)
% 
% % mgldestroycontrolscreen                    % Destruction is in the opposite order
% mgldestroysubjectscreen

end