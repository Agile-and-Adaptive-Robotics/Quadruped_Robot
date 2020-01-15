function [ bValid ] = TestWordValidity( Ltrs, Valid_Ltrs )

%This function takes in a user supplied list of letters can assess whether all of the letters are valid.  If all of the letters are valid, it returns bValid = true.  Otherwise, it returns bValid = false.

%Set the number of letter matches to start at zero.
bMatches = 0;

%Compute the total number of valid letters in the list of user supplied letters.
for k = 1:length(Ltrs)                                                  %Iterate through all of the user supplied letters...
    %Add up the total number of valid letters in the user supplied list of letters.
    bMatches = bMatches + (sum(Ltrs(k) == char(Valid_Ltrs)) == 1);
end

%Determine whether all of the user supplied letters are valid.
if bMatches == length(Ltrs)             %If all of the user supplied letters are valid...
   bValid = true;                       %Set the bValid flag to true.
else                                    %Otherwise...
    bValid = false;                     %Set the bValid flag to false.
end

end

