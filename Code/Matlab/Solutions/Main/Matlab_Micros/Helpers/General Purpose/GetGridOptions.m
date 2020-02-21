function M = GetGridOptions(dim)

%Define the number of options.
num_options = 3;

%Preallocate a matrix to store the options.
M = zeros(dim, num_options^dim);

%Create a matrix to store all of the options.
for k1 = 1:dim                  %Iterate through each of the dimensions.
    
    %Compute the number of individual instances per section.
    num_instances = num_options^(dim - k1);
    
    %Compute a single row section.
    row_section = [-1*ones(1, num_instances) zeros(1, num_instances) ones(1, num_instances)];
    
    %Compute the number of sections.
%     num_sections = 3^(k1 - 1);
        num_sections = num_options^(k1 - 1);

    %Initialize an empty row.
    row = [];
    
    %Fill in the current row.
    for k2 = 1:num_sections                     %Iterate through each of the sections...
        row = [row row_section];                %Append another row section to the row.
    end
    
    %Store this row in the matrix of options.
    M(k1, :) = row;
    
end

end

