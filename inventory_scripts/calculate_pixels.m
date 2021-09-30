x1_bystander = input('geef x1 bystander: ');
y1_bystander = input('geef y1 bystander: ');
x2_bystander = input('geef x2 bystander: ');
y2_bystander = input('geef y2 bystander: ');

width_bystander = x2_bystander-x1_bystander;
height_bystander = y2_bystander-y1_bystander;
origin_bystander = [x1_bystander y1_bystander] + [width_bystander/2 height_bystander/2];

% x1_agent = input('geef x1 agent: ');
% y1_agent = input('geef y1 agent: ');
% x2_agent = input('geef x2 agent: ');
% y2_agent = input('geef y2 agent: ');
% 
% width_agent = x2_agent-x1_agent;
% height_agent = y2_agent-y1_agent;
% origin_agent = [x1_agent y1_agent] + [width_agent/2 height_agent/2];
% 
% x1_patient = input('geef x1 patient: ');
% y1_patient = input('geef y1 patient: ');
% x2_patient = input('geef x2 patient: ');
% y2_patient = input('geef y2 patient: ');
% 
% width_patient = x2_patient-x1_patient;
% height_patient = y2_patient-y1_patient;
% origin_patient = [x1_patient y1_patient] + [width_patient/2 height_patient/2];

inventory_index = input('geef inventory index: ');

inventory(inventory_index).b_origin = origin_bystander;
inventory(inventory_index).b_width = width_bystander;
inventory(inventory_index).b_height = height_bystander;

% inventory(inventory_index).a_origin = origin_agent;
% inventory(inventory_index).a_width = width_agent;
% inventory(inventory_index).a_height = height_agent;
% 
% inventory(inventory_index).p_origin = origin_patient;
% inventory(inventory_index).p_width = width_patient;
% inventory(inventory_index).p_height = height_patient;

% inventory_index = input('geef inventory index: ');
% 
% inventory(inventory_index).a_origin = origin_agent;
% inventory(inventory_index).a_width = width_agent;
% inventory(inventory_index).a_height = height_agent;
% 
% inventory(inventory_index).p_origin = origin_patient;
% inventory(inventory_index).p_width = width_patient;
% inventory(inventory_index).p_height = height_patient;