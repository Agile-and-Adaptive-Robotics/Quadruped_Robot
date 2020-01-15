function [ Wpts ] = GetWordTemplatePoints( Ltrs )

%Define the letter spacing.
% Ltr_Spacing = 0.125;
Ltr_Spacing = 0.25;

%Preallocate the word points.
Wpts = [];

%Define the retract distance.
d_retract = 1;

%Get the letter templates and space them out in a word.
for k = 1:length(Ltrs)
    
    %Read in the current letter template points.
    Lpts = GetLetterTemplate( Ltrs(k) );
    
    %Compute the width of the letter.
    Ltr_Widths = max(Lpts, [], 2) - min(Lpts, [], 2);
    
    %Define scaling matrix parameters to scale the letter to have unit width.
    [xscl, yscl] = deal( 1/Ltr_Widths(1), 1/Ltr_Widths(2) );
    
    %Create a scaling matrix to scale the letter to have unit width.
    SclMat = [xscl 0 0; 0 yscl 0; 0 0 1];
    
    %Scale the letter to have unit widths.
    Lpts = SclMat*Lpts;
    
    %Center the letter.
    Lpts = CenterLetter(Lpts);
    
    %Define the spacing size between the letters.
    Spacing_Size = Ltr_Spacing*Ltr_Widths(1)*xscl;
    
    if mod(length(Ltrs), 2) == 1        %If the total quantity of letters to write is odd...
        dx = -((length(Ltrs) - 2*(k - 1) - 1)/2)*(Ltr_Widths(1)*xscl + Spacing_Size);
    else
        dx = -((length(Ltrs) - 2*(k - 1) - 1)/2)*(Ltr_Widths(1)*xscl + Spacing_Size);
    end
    
    %Shift the letter by the appropriate amount to its location in the word.
    Lpts(1, :) = Lpts(1, :) + dx;
    
%     if k ~= 1
       
        %Add a point at the beginning of the letter immediately above the starting point of the letter.
%         Lpts = cat(2, Lpts(:, 1) + [0; 0; d_retract], Lpts);
        Lpts = cat(2, [Lpts(:, 1) + [0; 0; d_retract], Lpts(:, 1) + [0; 0; d_retract/2]], Lpts); 

        
%     end
    
    %Add a point at the end of the letter immediatlye above the ending point of the letter.
%     Lpts = cat(2, Lpts, Lpts(:, end) + [0; 0; d_retract]);
    Lpts = cat(2, Lpts, [Lpts(:, end) + [0; 0; d_retract/2], Lpts(:, end) + [0; 0; d_retract]]);
    
    %Add the current letter to the word.
    Wpts = cat(2, Wpts, Lpts);
    
end

end

