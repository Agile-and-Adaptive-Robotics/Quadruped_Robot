function [ nA, Perm_Mat ] = MultiSort( A )

As = A(:,1);

As_Sorted = sort(As);
Perm_Mat = zeros(length(As));

for k = 1:length(As_Sorted)
    
    Perm_Row = (As_Sorted(k) == As)';
    
    if sum(Perm_Row) > 1
        
        Flag = 0;
        
        for j = 1:length(Perm_Row)
            Perm_Value = Perm_Row(j);
            if  (Perm_Value == 1) && (Flag == 0)
                
                Perm_Col = Perm_Mat(:,j);
                NumLocs = sum(Perm_Col);
                
                if NumLocs == 0
                    Perm_Row = zeros(1,length(Perm_Row));
                    Perm_Row(j) = 1;
                    %                     Perm_Mat(k,:) = Perm_Row;
                    Flag = 1;
                end
            end
            
        end
        
    end
    
    Perm_Mat(k,:) = Perm_Row;
    
end

nA = Perm_Mat*A;

end

