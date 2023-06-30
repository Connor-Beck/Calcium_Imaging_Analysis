function Data=reduceNumber(Data,k)
    if Data.N<k
        warning('Data Less than Reduction')
    else
        p = randperm(Data.N,k);
        count=0;
        
        
        for n=1:Data.N
            if ~ismember(n,p)
                for i=1:Data.n_files
                    Data(i).F(:,n-count)=[];
                    count=count+1;
                end
            end
        end
        Data.N=k;
    end
end