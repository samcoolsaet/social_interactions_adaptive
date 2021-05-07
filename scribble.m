count = mglgetadaptercount
[width,height,refresh_rate] = mglgetadapterdisplaymode(1)
info = mglgetadapteridentifier
rect = mglgetadapterrect(1)

mglcreatesubjectscreen(1)   % Do not use the adapter_no of the current screen
% mglcreatecontrolscreen([400 300 800 600])      % Need to create the subject screen first
id = mgladdbox([1 1 1; 1 1 1],[100 100]);
mglsetproperty(id,'active',1,'origin',[400 300]);
mglrendergraphic
mglpresent

pause(5);

mgldestroygraphic(id)

% mgldestroycontrolscreen                    % Destruction is in the opposite order
mgldestroysubjectscreen