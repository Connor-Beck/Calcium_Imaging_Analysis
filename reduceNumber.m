function Data=reduceNumber(Data,k)
    if Data.N<k
        warning('Data Less than Reduction')
    else
        p = randperm(Data.N,k);
        count=0;
        for n=1:Data.N
            if ~ismember(n,p)
                Data.F.Pre(:,n-count)=[];
                Data.F.Mag(:,n-count)=[];
                Data.F.Post(:,n-count)=[];
                count=count+1;
            end
        end
        Data.N=k;
    end
end