function dstr = GetOppositeString(astr, bstr, cstr)

% This function returns the string, dstr, which is either astr or bstr -- whichever is opposite of cstr.

% Determine which string to return.
if strcmp(astr, cstr)               % If cstr is the same as astr...
    dstr = bstr;                    % Set dstr to be bstr.
elseif strcmp(bstr, cstr)           % If cstr is the same as bstr...
    dstr = astr;                    % Set dstr to be astr.
else                                % Otherwise...
    dstr = '';                      % Set dstr to be an empty string.
end


end

