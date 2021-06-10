function [bitmap, origin] = FrameCreator(name, condition)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for frame...
% % img_size in degrees = 15*9, frames sizes (x, y), locations
% % open the file
% fid=fopen('frames.txt'); 
% % set linenum to the desired line number that you want to import
% linenum = 1;
% % use '%s' if you want to read in the entire line or use '%f' if you want to read only the first numeric value
% C = textscan(fid,'%s',4, 'delimiter',';', 'headerlines',linenum-1)
% dimensions = C{1, 1}{2, 1}
% x_degree = C{1, 1}{3, 1}
% y_degree = C{1, 1}{4, 1}
% frewind(fid)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% count = mglgetadaptercount
% [width,height,refresh_rate] = mglgetadapterdisplaymode(2)
% info = mglgetadapteridentifier
% rect = mglgetadapterrect(2)
%

% TrialRecord.User.structure(TrialRecord.User.struct_index).frames = name as input

load('inventory.mat');

identify_frame_inventory = strcmp([inventory.name], name);
inventory_index = find(identify_frame_inventory==1);

if condition == 5
    origin = inventory(inventory_index).a_degrees;
    width = inventory(inventory_index).a_width;
    height = inventory(inventory_index).a_height;
elseif condition == 6
    origin = inventory(inventory_index).p_degrees;
    width = inventory(inventory_index).p_width;
    height = inventory(inventory_index).p_height;
else
    disp('condition not found');
end

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