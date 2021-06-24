function [chasing_list, grooming_list, mounting_list, holding_list,...
    gen_chasing_list, gen_grooming_list, gen_mounting_list, gen_holding_list,...
    chasing_frame_list, grooming_frame_list, mounting_frame_list, holding_frame_list,...
    gen_chasing_frame_list, gen_grooming_frame_list, gen_mounting_frame_list, gen_holding_frame_list,...
    chasing_folder, grooming_folder, mounting_folder, holding_folder,...
    gen_chasing_folder, gen_grooming_folder, gen_mounting_folder, gen_holding_folder,...
    general_stimulus_list, general_frame_list] = stimulusList(root, generalizing) % 'D:\onedrive\OneDrive - KU Leuven\social_interactions'

    % dir() gives a struct of the contents of the path
    chasing_struct = dir(strcat(root,'\stimuli\chasing'));
    grooming_struct = dir(strcat(root,'\stimuli\grooming'));
    mounting_struct = dir(strcat(root,'\stimuli\mounting'));
    holding_struct = dir(strcat(root,'\stimuli\holding'));
    
    chasing_path = regexp(chasing_struct(1).folder,filesep,'split');
    grooming_path = regexp(grooming_struct(1).folder,filesep,'split');
    mounting_path = regexp(mounting_struct(1).folder,filesep,'split');
    holding_path = regexp(holding_struct(1).folder,filesep,'split');
    
    chasing_folder = chasing_path{1, end};
    grooming_folder = grooming_path{1, end};
    mounting_folder = mounting_path{1, end};
    holding_folder = holding_path{1, end};
    
    % isolating the name field
    chasing_list = {chasing_struct.name};
    grooming_list = {grooming_struct.name};
    mounting_list = {mounting_struct.name};
    holding_list = {holding_struct.name};
    
    % deleting the 2 empty spots from the name field
    chasing_list(1:2) = [];
    grooming_list(1:2) = [];
    mounting_list(1:2) = [];
    holding_list(1:2) = [];
    

    % analogous for the frames
    chasing_frame_struct = dir(strcat(root,'\frames\chasing'));
    grooming_frame_struct = dir(strcat(root,'\frames\grooming'));
    mounting_frame_struct = dir(strcat(root,'\frames\mounting'));
    holding_frame_struct = dir(strcat(root,'\frames\holding'));

    chasing_frame_list = {chasing_frame_struct.name};
    grooming_frame_list = {grooming_frame_struct.name};
    mounting_frame_list = {mounting_frame_struct.name};
    holding_frame_list = {holding_frame_struct.name};

    chasing_frame_list(1:2) = [];
    grooming_frame_list(1:2) = [];
    mounting_frame_list(1:2) = [];
    holding_frame_list(1:2) = [];

if generalizing
    gen_chasing_struct = dir(strcat(root,'\stimuli\gen_chasing'));
    gen_grooming_struct = dir(strcat(root,'\stimuli\gen_grooming'));
    gen_mounting_struct = dir(strcat(root,'\stimuli\gen_mounting'));
    gen_holding_struct = dir(strcat(root,'\stimuli\gen_holding'));
    
    gen_chasing_path = regexp(gen_chasing_struct(1).folder,filesep,'split');
    gen_grooming_path = regexp(gen_grooming_struct(1).folder,filesep,'split');
    gen_mounting_path = regexp(gen_mounting_struct(1).folder,filesep,'split');
    gen_holding_path = regexp(gen_holding_struct(1).folder,filesep,'split');
    
    gen_chasing_folder = gen_chasing_path{1, end};
    gen_grooming_folder = gen_grooming_path{1, end};
    gen_mounting_folder = gen_mounting_path{1, end};
    gen_holding_folder = gen_holding_path{1, end};

    gen_chasing_list = {gen_chasing_struct.name};
    gen_grooming_list = {gen_grooming_struct.name};
    gen_mounting_list = {gen_mounting_struct.name};
    gen_holding_list = {gen_holding_struct.name};
    
    gen_chasing_list(1:2) = [];
    gen_grooming_list(1:2) = [];
    gen_mounting_list(1:2) = [];
    gen_holding_list(1:2) = [];
    
    gen_chasing_frame_struct = dir(strcat(root,'\frames\gen_chasing'));
    gen_grooming_frame_struct = dir(strcat(root,'\frames\gen_grooming'));
    gen_mounting_frame_struct = dir(strcat(root,'\frames\gen_mounting'));
    gen_holding_frame_struct = dir(strcat(root,'\frames\gen_holding'));
    
    gen_chasing_frame_list = {gen_chasing_frame_struct.name};
    gen_grooming_frame_list = {gen_grooming_frame_struct.name};
    gen_mounting_frame_list = {gen_mounting_frame_struct.name};
    gen_holding_frame_list = {gen_holding_frame_struct.name};

    gen_chasing_frame_list(1:2) = [];
    gen_grooming_frame_list(1:2) = [];
    gen_mounting_frame_list(1:2) = [];
    gen_holding_frame_list(1:2) = [];
else
    gen_chasing_list = [];
    gen_grooming_list = [];
    gen_mounting_list = [];
    gen_holding_list = [];
    
    gen_chasing_frame_list = [];
    gen_grooming_frame_list = [];
    gen_mounting_frame_list = [];
    gen_holding_frame_list = [];
end

    % creating general lists with all the files
    general_stimulus_list = [chasing_list, ...
        gen_chasing_list, grooming_list,...
        gen_grooming_list, mounting_list,...
        gen_mounting_list, holding_list, gen_holding_list]; 
    general_frame_list = [chasing_frame_list,...
        gen_chasing_frame_list, grooming_frame_list,...
        gen_grooming_frame_list,mounting_frame_list,...
        gen_mounting_frame_list, holding_frame_list,...
        gen_holding_frame_list];
end

