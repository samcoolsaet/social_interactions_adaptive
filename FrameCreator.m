function [image_list] = FrameCreator()

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
origin = [400 300];
x_length = 100;
y_length = 100;
line_thickness = 5;

alpha = zeros(x_length, y_length);
red = zeros(x_length, y_length);
green = zeros(x_length, y_length);
blue = zeros(x_length, y_length);

red(1:line_thickness,:) = ones(line_thickness, x_length);
red(end-(line_thickness-1):end,:) = ones(line_thickness, x_length);
red(:,1:line_thickness) = ones(y_length, line_thickness);
red(:,end-(line_thickness-1):end) = ones(y_length, line_thickness);

alpha(1:line_thickness,:) = ones(line_thickness, x_length);
alpha(end-(line_thickness-1):end,:) = ones(line_thickness, x_length);
alpha(:,1:line_thickness) = ones(y_length, line_thickness);
alpha(:,end-(line_thickness-1):end) = ones(y_length, line_thickness);


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