function [ Ltrs ] = SetTargetLetter( Valid_Ltrs )

%This function requests that the user enter the target letter that will be drawn later.  It takes in the valid letter options, and returns the option entered by the user.

% %Print that we are defining which letter to write.
% fprintf('\n\nLETTER DEFINITION\n')
% 
% %Request the user type a letter on the keyboard.
% Ltrs = input('Enter a letter: Ltr = ');
% 
% %Validate the user input by comparing it to the array of possible lettersd defined during the setup.
% while sum(Ltrs == char(Valid_Ltrs)) == 0                                       %While the user input is invalid...
%     
%     %State that the character is not valid and display valid letters.
%     fprintf('\nInvalid letter. The following letters are valid:')
%     disp(Valid_Ltrs)
%     fprintf('Try Again.\n\n')
%     
%     %Request the letter to write.
%     Ltrs = input('Enter a letter: Ltr = ');
%     
% end
% 
% %Print that the letter is accepted.
% fprintf('\nDone: Valid Letter Confirmed.\n')

%Print that we are defining which letter to write.
fprintf('\n\nLETTER DEFINITION\n')

%Request the user type a letter on the keyboard.
Ltrs = input('Enter a letter: Ltr = ');

%Check whether the user supplied word is valid.
bValid = TestWordValidity( Ltrs, Valid_Ltrs );

%Validate the user input by comparing it to the array of possible lettersd defined during the setup.
while ~bValid                                       %While the user input is invalid...
    
    %State that the character is not valid and display valid letters.
    fprintf('\nInvalid letter. The following letters are valid:')
    disp(Valid_Ltrs)
    fprintf('Try Again.\n\n')
    
    %Request the letter to write.
    Ltrs = input('Enter a letter: Ltr = ');
    
    %Check whether the user supplied word is valid.
    bValid = TestWordValidity( Ltrs, Valid_Ltrs );
    
end

%Print that the letter is accepted.
fprintf('\nDone: Valid Letter Confirmed.\n')

end

