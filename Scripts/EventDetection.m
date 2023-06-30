function Data=EventDetection(Data,Parameters)
    %% Event Detection
    
    for i=1:Parameters.n_files
        %Initialize values
        Data(i).EventMap=zeros(Data(i).N,Data(i).T);
        Data(i).EventScatter=[];

        %Remove the lower envelope from deltaF/F
        Data(i).FrE=Data(i).Fnorm-Data(i).LE;

        %loop through each neuron and locate all possible peaks, then
        %elimitate
        for n=1:Data(1).N
            [tmp.pks,tmp.locs] = findpeaks(Data(i).FrE(:,n),'MinPeakWidth',Parameters.SamplingRate/2,'MinPeakProminence',Parameters.standardDev*std(Data(i).FrE(:,n)));
            k=find(tmp.pks<Parameters.noiseThreshold);
            tmp.pks(k)=[];
            tmp.locs(k)=[];

            Data(i).Events(n).Time=tmp.locs;
            Data(i).Events(n).InfluxMagnitude=tmp.pks;
            
            evnts=cat(2,tmp.locs,n*ones(size(tmp.locs)));
            if ~isempty(evnts)
                Data(i).EventScatter=cat(1,Data(i).EventScatter,evnts);
                for k=1:length(tmp.locs)
                    Data(i).EventMap(n,tmp.locs(k))=1;
                end
            end 
        end
    end
end