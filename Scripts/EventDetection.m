function [Data,Parameters]=EventDetection(Data,Parameters)
    %% Event Detection
    r_list=randperm(Parameters.N,Parameters.N);
    for i=1:Parameters.n_files
        %Initialize values
        Data(i).EventMap=zeros(Parameters.N,Data(i).T);
        Data(i).EventScatter=[];
        
        %loop through each neuron and locate all possible peaks, then
        %elimitate
        for n=1:Parameters.N
            %Remove the lower envelope from deltaF/F
            Data(i).FrE(:,n)=Data(i).Fnorm(:,n)-Data(i).LE(:,n);
            [tmp.pks,tmp.locs] = findpeaks(Data(i).FrE(:,n),'MinPeakWidth',Parameters.SamplingRate/2,'MinPeakProminence',Parameters.standardDev*std(Data(i).FrE(:,n)));
            k=find(tmp.pks<Parameters.noiseThreshold);
            tmp.pks(k)=[];
            tmp.locs(k)=[];

            Data(i).Events(n).Time=tmp.locs;
            Data(i).Events(n).InfluxMagnitude=Data(i).Fnorm(tmp.locs,n);
            
            evnts=cat(2,tmp.locs./(60*Parameters.SamplingRate),r_list(n)*ones(size(tmp.locs)));
            if ~isempty(evnts)
                Data(i).EventScatter=cat(1,Data(i).EventScatter,evnts);
                for k=1:length(tmp.locs)
                    Data(i).EventMap(n,tmp.locs(k))=1;
                end
            end 
        end
    end
    count=0;
    for n=1:Parameters.N
        if isempty(Data(1).Events(n-count).Time) && Parameters.removeinactive
            [Data,Parameters]=RemoveNeuron(Data,Parameters,n-count);
            Parameters.N=Parameters.N-1;
            count=count+1;
        end
    end
end