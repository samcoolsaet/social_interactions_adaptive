path = "D:\onedrive\OneDrive - KU Leuven\social_interactions\edgeless\frames\chasing";
directory = dir(path);
stimuli = string({directory.name});
stimuli(1:2) = [];
size_ratio = 288/215;
for i = stimuli
    edgeless_index = find([inventory.name] == i);
    char_array = convertStringsToChars(i);
    start_index = strfind(char_array, '_edgeless.');
    char_array(start_index:start_index+length('edgeless')) = [];
    old_index = find([inventory.name] == char_array);
%     origin : neem het verschill met het midden ( 144 pixels ) doe dat verschal maal de ratio en tel het verschil weer op bij het midden
%     height kan ik gewoon vermenigvuldigen met ratio
    inventory(edgeless_index).a_origin = [inventory(old_index).a_origin(1) ...
        round((inventory(old_index).a_origin(2)-144)*size_ratio)+144];
    inventory(edgeless_index).p_origin = [inventory(old_index).p_origin(1) ...
        round((inventory(old_index).p_origin(2)-144)*size_ratio)+144];
    inventory(edgeless_index).a_height = round(inventory(old_index).a_height*size_ratio);
    inventory(edgeless_index).p_height = round(inventory(old_index).p_height*size_ratio);
    inventory(edgeless_index).a_width = inventory(old_index).a_width;
    inventory(edgeless_index).p_width = inventory(old_index).p_width;
end
    
