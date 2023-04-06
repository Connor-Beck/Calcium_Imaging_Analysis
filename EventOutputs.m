function Data=EventOutputs(Data)

    Data.OutputEvents.Pre=[];
    for i=1:Data.N
        if ~isempty(Data.Events(i).Pre)
            for j=1:size(Data.Events(i).Pre,1)
                Event=[Data.Events(i).Pre(j,1)/(4*60),i];
                Data.OutputEvents.Pre=cat(1,Data.OutputEvents.Pre,Event);
            end
        end
    end
    
    Data.OutputEvents.Mag=[];
    for i=1:Data.N
        if ~isempty(Data.Events(i).Mag)
            for j=1:size(Data.Events(i).Mag,1)
                Event=[Data.Events(i).Mag(j,1)/(4*60)+4,i];
                Data.OutputEvents.Mag=cat(1,Data.OutputEvents.Mag,Event);
            end
        end
    end
    
    Data.OutputEvents.Post=[];
    for i=1:Data.N
        if ~isempty(Data.Events(i).Post)
            for j=1:size(Data.Events(i).Post,1)
                Event=[Data.Events(i).Post(j,1)/(4*60)+8,i];
                Data.OutputEvents.Post=cat(1,Data.OutputEvents.Post,Event);
            end
        end
    end
end
        
    