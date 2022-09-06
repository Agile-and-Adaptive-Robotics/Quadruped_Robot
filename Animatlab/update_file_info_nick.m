function [ written_file ] = update_file_info_nick( info_cell_array, property_file, standalone_asim_file , aproj_file )
%UPDATE_FILE_INFO Summary of this function goes here
%   input:
%   cell array
%   object names | property name | numerical
%
%   output:
%   take existing file and write new properties, return the file



    fileID = fopen(aproj_file)
    cell_proj_file = textscan(fileID,'%s', 'delimiter','\n')
    cell_proj_file = cell_proj_file{1};
    fclose(fileID);

    fileID = fopen(standalone_asim_file);
    cell_asim_file = textscan(fileID,'%s', 'delimiter','\n');
    cell_asim_file = cell_asim_file{1};
    fclose(fileID);

    size_info = size(info_cell_array);
    size_info = size_info(1);
    row = 1;

    while row <= size_info
%         disp(['processing row ' num2str(row)]);
        % get the right id for the given object name
        [prop_to_find, spec_info] = identify_property(property_file, info_cell_array{row,2});
        if ~strcmp(prop_to_find , 'Error')
            spec_id = find_id(info_cell_array{row,1},cell_asim_file);
            if ~strcmp(spec_id, 'Error')
                %with valid id + property name, process the value (check range
                % + scale)
                [val, sca, act, error] = process_numerical(info_cell_array{row,3}, prop_to_find, property_file);
                if ~error
                    % if the numerical processing doesn't throw an error:
                    % make the changes to the file for item id, property,
                    % value, scale, actual
                    if spec_info == 1
                        disp(['[object] ' info_cell_array{row,1} ...
                            ' [id] ' spec_id ...
                            ' [property] m' prop_to_find ...
                            ' [val/sca/act] ' num2str(val) '/' sca '/' num2str(act)]);
                    elseif spec_info == 2
                        disp(['[object] ' info_cell_array{row,1} ...
                            ' [id] ' spec_id ...
                            ' [property] h' prop_to_find ...
                            ' [val/sca/act] ' num2str(val) '/' sca '/' num2str(act)]);
                    elseif spec_info == 3
                        disp('damping')
                    else
                        disp(['[object] ' info_cell_array{row,1} ...
                            ' [id] ' spec_id ...
                            ' [property] ' prop_to_find ...
                            ' [val/sca/act] ' num2str(val) '/' sca '/' num2str(act)]);
                    end
                    cell_proj_file = set_info(spec_id, prop_to_find, spec_info, val, sca, act, cell_proj_file);
                end
            else
                disp(['[ERROR] No ID found for [object] ' info_cell_array{row,1}]);
            end
        else
            disp(['[ERROR] Invalid property for [object] ' info_cell_array{row,1} ...
                ' [property] ' info_cell_array{row,2}]);
        end
        row = row + 1;

    end
    % write the new file to disk with the old data + changes
    disp('ran to file write');
    fid = fopen([aproj_file(1:length(aproj_file)-6) '_mod.aproj'], 'wt');
    % celldisp(cell_lengthmap_file);
    fprintf(fid, '%s\n' , cell_proj_file{:});
    fclose(fid);

    written_file = [aproj_file(1:length(aproj_file)-6) '_mod.aproj'];
end

function [full_id] = find_id(object_name, cell_asim_file)
%     disp(['[object name] ' object_name]);
    full_id = 'Error';
    % while there are lines to lookup...
    index = 1;
    size_info = size(cell_asim_file);
    size_info = size_info(1);
    found_flag = 0;
    while ~found_flag && index <= size_info
        % if the current line is long enough to have a name...
        curr_line = cell_asim_file{index};
        if (length(curr_line)> length('<Name></Name>') && strncmpi(curr_line,'<Name>',6)) ||...
                (length(curr_line)> length('<ModuleName></ModuleName>') && strncmpi(curr_line,'<ModuleName>',12))
            % disp(['[name_found] ' curr_line]);
            short_name = curr_line(7:length(curr_line)-7);
            short_name2 = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
            if (length(curr_line)> length('<ModuleName></ModuleName>'))
                short_name2 = curr_line(13:length(curr_line)-13);
            end
            % disp(['[short_name] ' short_name ' vs. [input] ' object_name]);
            % if the name is correct...
            if strcmp(object_name,short_name) || strcmp(object_name,short_name2)
                % now to find the id
                % disp('correct name found');
                %process backwards to the opening of the object tag
                % (open tag w/o data)
                object_start_flag = 0;
                while(~object_start_flag && index>0)
                    curr_line = cell_asim_file{index};
                    num_open_tags = length(strfind(curr_line,'<'));
                    num_close_tags = length(strfind(curr_line,'>'));
                    num_slash = length(strfind(curr_line,'/'));
                    if (length(curr_line)> length('<>') && num_open_tags == 1 ...
                            && num_close_tags == 1  && num_slash == 0)
                        % if the current line has just a tag
                        % disp(['[object type] ' curr_line(2:length(curr_line)-1)]);
                        object_start_flag = 1;
                    else
                        index = index -1;
                    end
                end
                % then move down until an <ID> is found
                links_flag = 0;
                while ~found_flag && index<length(cell_asim_file) && length(curr_line)>4 && (links_flag || ~strncmpi(curr_line,'<ID>',4))
                    curr_line = cell_asim_file{index};
                    if strncmpi(curr_line,'<InLinks>',length('<InLinks>')) || strncmpi(curr_line,'<OutLinks>',length('<OutLinks>'))
                        links_flag = 1;
                    elseif strncmpi(curr_line,'</InLinks>',length('</InLinks>')) || strncmpi(curr_line,'</OutLinks>',length('</OutLinks>'))
                        links_flag = 0;
                    else
                        % otherwise, we have a valid id
                        if length(curr_line) > length('<ID></ID>') && strncmpi(curr_line,'<ID>',4)
                            id_line = curr_line;
                            full_id = id_line(5:length(id_line)-5);
                            found_flag = 1;
                        end
                    end

                    index = index+1;
                end
            end
        end
        index = index+1;
    end
end

function [value, scale, actual, error] = process_numerical(actual, property, prop_file)
    actual_check = str2double(actual);
    if isnan(actual_check)
        value = actual;
        scale = [];
        error = 1;
        warning(['Property ',property,' is Nan.'])
    else
        actual = actual_check;
        value = num2str(0);
        scale = 'None';
        error = 0;
        if ischar(property)
            available_properties = load(prop_file);
            prop_set = available_properties.Properties;
            % lookup the property in the animatlab file
            set_flag = 0;
            for i = 1:5
                current_page = prop_set{i,1};
                size_info = size(current_page);
                size_info = size_info(1);
                for j = 1:size_info % the length of the cell
                    if strcmp(current_page{j,4},property)
                        minval = current_page{j,2};
                        maxval = current_page{j,3};
                        set_flag = 1;
                        break;
                    end
                end
            end
            %Range errors do not correctly identify properties
    %         if (~set_flag || actual < minval || actual > maxval)
    %             new_str = ['[ERROR] Actual ' ...
    %                 num2str(actual) ' out of range (' ...
    %                 num2str(minval) ',' ...
    %                 num2str(maxval) ') for property ' ...
    %                 property];
    %             disp(new_str);
    %             error = 1;
    %         end
        end
        % disp(['[actual] ' actual]);
        if actual == 0
            value = num2str(0);
            scale = 'None';
        else
            minor_count = 0;
            temp_act = actual;
            if abs(temp_act) > 1000
                while abs(temp_act)>1000
                    temp_act = temp_act/1000;
                    minor_count = minor_count + 1;
                end
                value = num2str(temp_act);
                if minor_count == 0
                    scale = 'None';
                elseif minor_count == 1
                    scale = 'kilo';
                elseif minor_count == 2
                    scale = 'mega';
                elseif minor_count == 3
                    scale = 'giga';
                elseif minor_count == 4
                    scale = 'tera';
                else
                    scale = 'Error'
                end
            elseif abs(temp_act) <.1
                while abs(temp_act)<.1
                    temp_act = temp_act*1000;
                    minor_count = minor_count + 1;
                end
                value = num2str(temp_act);
                if minor_count == 0
                    scale = 'None';
                elseif minor_count == 1
                    scale = 'milli';
                elseif minor_count == 2
                    scale = 'micro';
                elseif minor_count == 3
                    scale = 'nano';
                elseif minor_count == 4
                    scale = 'pico';
                else
                    scale = 'Error'
                end
            else
                scale = 'None';
                value = actual;
            end
        end
    end
end

function [prop_to_find,special_info] = identify_property(prop_file, lookup_string)
    if strncmpi(lookup_string,'m',1)
        special_info = 1;
    elseif strncmpi(lookup_string,'h',1)
        special_info = 2;
    elseif strncmpi(lookup_string,'damping',7)
        special_info = 3;
    else
        special_info = 0;
    end
    available_properties = load(prop_file);
    prop_set = available_properties.Properties;
    prop_to_find = 'Error';
    % lookup the property in the animatlab file
    for i = 1:5
        current_page = prop_set{i,1};
        size_info = size(current_page);
        size_info = size_info(1);
        for j = 1:size_info % the length of the cell
            if strcmp(current_page{j,1},lookup_string)
                prop_to_find = current_page{j,4};
                %fprintf('prop_to_find: %s',prop_to_find);
                return;
            end
        end
    end
end

function file_with_edit = set_info(full_id, property_name, modifier, value, scale, actual, celled_proj_file)    
    % Test
    % find the correct line by linear scan
    index = 1;
    file_with_edit = [];
    %celldisp(celled_lengthmap_file);
    replaced = 0;
    size_info = size(celled_proj_file);
    size_info = size_info(1);

    m_mod_flag = 0;
    h_mod_flag = 0;
    skip_entry = 0;
    if modifier == 1
        m_mod_flag = 1;
    elseif modifier == 2
        h_mod_flag = 1;
    elseif modifier == 3
        skip_entry = 1;
    end
    while(index < size_info && ~replaced)
        if ischar(celled_proj_file{index}) && length(celled_proj_file{index}) > length('<ID></ID>')...
                && strncmpi(celled_proj_file{index},'<ID>',4)
            
            %identify the ID, if this line has one.
            to_compare = celled_proj_file{index};
            to_compare = to_compare(5:length(to_compare)-5);
            % if the correct ID is found
            if strcmp(to_compare,full_id)
%                 disp(['[tocompare] ' to_compare ' vs. [fullid] ' full_id]);
                links_flag = 0;
                caA_m_flag = 0;
                caD_h_flag = 0;
                index = index+1;
                % cycle through the properties until it hits the next id
                curr_line = celled_proj_file{index};
                
                while index<length(celled_proj_file) && length(curr_line)>4 && (links_flag || ~strncmpi(curr_line,'<ID>',4))
%                     disp('INSIDE WHILE')
                    if (strncmpi(curr_line,'<InLinks>',length('<InLinks>')) ...
                            || strncmpi(curr_line,'<OutLinks>',length('<OutLinks>')) ...
                            || strncmpi(curr_line,'<CaActivation>',length('<CaActivation>'))...
                            || strncmpi(curr_line,'<CaDeactivation>',length('<CaDeactivation>'))...
                            || strncmpi(curr_line,'<Gain>',length('<Gain>'))...
                            || strncmpi(curr_line,'<LengthTension>',length('<LengthTension>'))...
                            || strncmpi(curr_line,'<StimulusTension>',length('<StimulusTension>')));
                        links_flag = 1;
                    end
                    
                    if (strncmpi(curr_line,'<CaActivation>',length('<CaActivation>')))
                        caA_m_flag = 1;
                    elseif (strncmpi(curr_line,'<CaDeactivation>',length('<CaDeactivation>')))
                        caD_h_flag = 1;
                    elseif (strncmpi(curr_line,'</CaActivation>',length('</CaActivation>')))
                        caA_m_flag = 0;
                    elseif (strncmpi(curr_line,'</CaDeactivation>',length('</CaDeactivation>')))
                        caD_h_flag = 0;
                    end
                    if (strncmpi(curr_line,'</InLinks>',length('</InLinks>')) ...
                            || strncmpi(curr_line,'</OutLinks>',length('</OutLinks>'))...
                            || strncmpi(curr_line,'</CaActivation>',length('</CaActivation>'))...
                            || strncmpi(curr_line,'</CaDeactivation>',length('</CaDeactivation>'))...
                            || strncmpi(curr_line,'</Gain>',length('</Gain>'))...
                            || strncmpi(curr_line,'</LengthTension>',length('</LengthTension>'))...
                            || strncmpi(curr_line,'</StimulusTension>',length('</StimulusTension>')));
                        links_flag = 0;
                    end
                        
                    if length(curr_line)>length(property_name)+length('</>') && strncmpi(curr_line,['<' property_name],length(property_name)+1)
                        if skip_entry
                            %do nothing
                            
                            disp('Doing nothing!')
                            skip_entry = 0;
                        else

                            % if the property is found, read/write the property value
                            comp_line3 = curr_line(length(curr_line)-1:length(curr_line));
                            % swap out the info in the cell array
                            if ((m_mod_flag && caA_m_flag) || (h_mod_flag && caD_h_flag) || ...
                                    (~m_mod_flag && ~h_mod_flag && ~caA_m_flag && ~caD_h_flag))
                                if strcmp(comp_line3,'/>')
                                    % then the files are embedded in the tag, and look
                                    % for the beginning of the value data field
                                    start_index = strfind(curr_line,'Value="');
                                    start_index = start_index(1)+length('Value="');
                                    % (current line up through value=") + value +
                                    % ' Scale="' + scale + ' Actual="' + actual + '"/>'
                                    %disp(['[value value] ' value]);
                                    
                                    new_string = [curr_line(1:start_index-1) num2str(value) '" Scale="' scale '" Actual="' num2str(actual) '"/>'];
                                    
%                                     disp(['[old line] ' curr_line]);
%                                     disp(['[new line] ' new_string]);
                                    celled_proj_file{index} = new_string;
%                                     disp('got to file_with_edit assignment...');
                                    file_with_edit = celled_proj_file;
                                    replaced = 1;
                                    break;
                                else
                                    %We have a nonstandard property. These
                                    %are usually booleans, which have a
                                    %different format in the .aproj files
                                    new_string = ['<',property_name,'>',value,'</',property_name,'>'];
                                    celled_proj_file{index} = new_string;
                                    file_with_edit = celled_proj_file;
                                    replaced = 1;
                                    break;
                                        
                                end
                            end
                        end
                    else
                        %Do nothing
                    end
                    
                    index = index+1;
                    curr_line = celled_proj_file{index};
                end
            end
        end
        index = index + 1;
    end
    if isempty(file_with_edit)
        disp('The current property may not exist within the simulation.')
        disp('Please add it to the simulation, save it, and export another standalone simulation.')
        keyboard
    end
end