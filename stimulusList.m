function [chasing_list, grooming_list, mounting_list, holding_list,...
    gen_chasing_list, gen_grooming_list, gen_mounting_list, gen_holding_list,...
    chasing_frame_list, grooming_frame_list, mounting_frame_list, holding_frame_list,...
    gen_chasing_frame_list, gen_grooming_frame_list, gen_mounting_frame_list, gen_holding_frame_list,...
    chasing_folder, grooming_folder, mounting_folder, holding_folder,...
    gen_chasing_folder, gen_grooming_folder, gen_mounting_folder, gen_holding_folder,...
    general_stimulus_list, general_frame_list] = stimulusList(inputArg1,inputArg2)

end
    % dir() gives a struct of the contents of the path
    chasing_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\chasing');
    grooming_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\grooming');
    mounting_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\mounting');
    holding_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\holding');
    
    chasing_path = regexp(chasing_struct(1).folder,filesep,'split');
    grooming_path = regexp(grooming_struct(1).folder,filesep,'split');
    mounting_path = regexp(mounting_struct(1).folder,filesep,'split');
    holding_path = regexp(holding_struct(1).folder,filesep,'split');
    
    TrialRecord.User.chasing_folder = chasing_path{1, end};
    TrialRecord.User.grooming_folder = grooming_path{1, end};
    TrialRecord.User.mounting_folder = mounting_path{1, end};
    TrialRecord.User.holding_folder = holding_path{1, end};
    
    % isolating the name field
    TrialRecord.User.chasing_list = {chasing_struct.name};
    TrialRecord.User.grooming_list = {grooming_struct.name};
    TrialRecord.User.mounting_list = {mounting_struct.name};
    TrialRecord.User.holding_list = {holding_struct.name};
    
    % deleting the 2 empty spots from the name field
    TrialRecord.User.chasing_list(1:2) = [];
    TrialRecord.User.grooming_list(1:2) = [];
    TrialRecord.User.mounting_list(1:2) = [];
    TrialRecord.User.holding_list(1:2) = [];
    

    % analogous for the frames
    chasing_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\chasing');
    grooming_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\grooming');
    mounting_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\mounting');
    holding_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\holding');

    TrialRecord.User.chasing_frame_list = {chasing_frame_struct.name};
    TrialRecord.User.grooming_frame_list = {grooming_frame_struct.name};
    TrialRecord.User.mounting_frame_list = {mounting_frame_struct.name};
    TrialRecord.User.holding_frame_list = {holding_frame_struct.name};

    TrialRecord.User.chasing_frame_list(1:2) = [];
    TrialRecord.User.grooming_frame_list(1:2) = [];
    TrialRecord.User.mounting_frame_list(1:2) = [];
    TrialRecord.User.holding_frame_list(1:2) = [];

if TrialRecord.User.generalizing
    gen_chasing_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\gen_chasing');
    gen_grooming_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\gen_grooming');
    gen_mounting_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\gen_mounting');
    gen_holding_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\stimuli\gen_holding');
    
    gen_chasing_path = regexp(gen_chasing_struct(1).folder,filesep,'split');
    gen_grooming_path = regexp(gen_grooming_struct(1).folder,filesep,'split');
    gen_mounting_path = regexp(gen_mounting_struct(1).folder,filesep,'split');
    gen_holding_path = regexp(gen_holding_struct(1).folder,filesep,'split');
    
    TrialRecord.User.gen_chasing_folder = gen_chasing_path{1, end};
    TrialRecord.User.gen_grooming_folder = gen_grooming_path{1, end};
    TrialRecord.User.gen_mounting_folder = gen_mounting_path{1, end};
    TrialRecord.User.gen_holding_folder = gen_holding_path{1, end};

    TrialRecord.User.gen_chasing_list = {gen_chasing_struct.name};
    TrialRecord.User.gen_grooming_list = {gen_grooming_struct.name};
    TrialRecord.User.gen_mounting_list = {gen_mounting_struct.name};
    TrialRecord.User.gen_holding_list = {gen_holding_struct.name};
    
    TrialRecord.User.gen_chasing_list(1:2) = [];
    TrialRecord.User.gen_grooming_list(1:2) = [];
    TrialRecord.User.gen_mounting_list(1:2) = [];
    TrialRecord.User.gen_holding_list(1:2) = [];
    
    gen_chasing_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\gen_chasing');
    gen_grooming_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\gen_grooming');
    gen_mounting_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\gen_mounting');
    gen_holding_frame_struct = dir('D:\onedrive\OneDrive - KU Leuven\social_interactions\frames\gen_holding');
    
    TrialRecord.User.gen_chasing_frame_list = {gen_chasing_frame_struct.name};
    TrialRecord.User.gen_grooming_frame_list = {gen_grooming_frame_struct.name};
    TrialRecord.User.gen_mounting_frame_list = {gen_mounting_frame_struct.name};
    TrialRecord.User.gen_holding_frame_list = {gen_holding_frame_struct.name};

    TrialRecord.User.gen_chasing_frame_list(1:2) = [];
    TrialRecord.User.gen_grooming_frame_list(1:2) = [];
    TrialRecord.User.gen_mounting_frame_list(1:2) = [];
    TrialRecord.User.gen_holding_frame_list(1:2) = [];
else
    TrialRecord.User.gen_chasing_list = [];
    TrialRecord.User.gen_grooming_list = [];
    TrialRecord.User.gen_mounting_list = [];
    TrialRecord.User.gen_holding_list = [];
    
    TrialRecord.User.gen_chasing_frame_list = [];
    TrialRecord.User.gen_grooming_frame_list = [];
    TrialRecord.User.gen_mounting_frame_list = [];
    TrialRecord.User.gen_holding_frame_list = [];
end

    % creating general lists with all the files
    TrialRecord.User.general_stimulus_list = [TrialRecord.User.chasing_list, ...
        TrialRecord.User.gen_chasing_list, TrialRecord.User.grooming_list,...
        TrialRecord.User.gen_grooming_list, TrialRecord.User.mounting_list,...
        TrialRecord.User.gen_mounting_list, TrialRecord.User.holding_list, TrialRecord.User.gen_holding_list]; 
    TrialRecord.User.general_frame_list = [TrialRecord.User.chasing_frame_list,...
        TrialRecord.User.gen_chasing_frame_list, TrialRecord.User.grooming_frame_list,...
        TrialRecord.User.gen_grooming_frame_list,TrialRecord.User.mounting_frame_list,...
        TrialRecord.User.gen_mounting_frame_list, TrialRecord.User.holding_frame_list,...
        TrialRecord.User.gen_holding_frame_list];

