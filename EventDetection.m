function Data=EventDetection(Data,Parameters)
    %% Event Detection
    
    for i=1:length(Data)
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
    
    % for n=1:Data(1).N
    % 
    %     Data.EventsPerMin(n).Min1=sum(Data.EventMap.Pre(n,1:240));
    %     Data.EventsPerMin(n).Min2=sum(Data.EventMap.Pre(n,241:480));
    %     Data.EventsPerMin(n).Min3=sum(Data.EventMap.Pre(n,481:720));
    %     Data.EventsPerMin(n).Min4=sum(Data.EventMap.Pre(n,721:end));
    % 
    %     Data.EventsPerMin(n).Min5=sum(Data.EventMap.Mag(n,1:240));
    %     Data.EventsPerMin(n).Min6=sum(Data.EventMap.Mag(n,241:480));
    %     Data.EventsPerMin(n).Min7=sum(Data.EventMap.Mag(n,481:720));
    %     Data.EventsPerMin(n).Min8=sum(Data.EventMap.Mag(n,721:end));
    % 
    %     Data.EventsPerMin(n).Min9=sum(Data.EventMap.Post(n,1:240));
    %     Data.EventsPerMin(n).Min10=sum(Data.EventMap.Post(n,241:480));
    %     Data.EventsPerMin(n).Min11=sum(Data.EventMap.Post(n,481:720));
    %     Data.EventsPerMin(n).Min12=sum(Data.EventMap.Post(n,721:end));
    % end
    % Data.MeanEventPerMin(1,1)=mean([Data.EventsPerMin.Min1]);
    % Data.MeanEventPerMin(2,1)=mean([Data.EventsPerMin.Min2]);
    % Data.MeanEventPerMin(3,1)=mean([Data.EventsPerMin.Min3]);
    % Data.MeanEventPerMin(4,1)=mean([Data.EventsPerMin.Min4]);
    % Data.MeanEventPerMin(5,1)=mean([Data.EventsPerMin.Min5]);
    % Data.MeanEventPerMin(6,1)=mean([Data.EventsPerMin.Min6]);
    % Data.MeanEventPerMin(7,1)=mean([Data.EventsPerMin.Min7]);
    % Data.MeanEventPerMin(8,1)=mean([Data.EventsPerMin.Min8]);
    % Data.MeanEventPerMin(9,1)=mean([Data.EventsPerMin.Min9]);
    % Data.MeanEventPerMin(10,1)=mean([Data.EventsPerMin.Min10]);
    % Data.MeanEventPerMin(11,1)=mean([Data.EventsPerMin.Min11]);
    % Data.MeanEventPerMin(12,1)=mean([Data.EventsPerMin.Min12]);
    % 
    % Data.MeanEventPerMin(1,2)=std([Data.EventsPerMin.Min1])./sqrt(Data.N);
    % Data.MeanEventPerMin(2,2)=std([Data.EventsPerMin.Min2])./sqrt(Data.N);
    % Data.MeanEventPerMin(3,2)=std([Data.EventsPerMin.Min3])./sqrt(Data.N);
    % Data.MeanEventPerMin(4,2)=std([Data.EventsPerMin.Min4])./sqrt(Data.N);
    % Data.MeanEventPerMin(5,2)=std([Data.EventsPerMin.Min5])./sqrt(Data.N);
    % Data.MeanEventPerMin(6,2)=std([Data.EventsPerMin.Min6])./sqrt(Data.N);
    % Data.MeanEventPerMin(7,2)=std([Data.EventsPerMin.Min7])./sqrt(Data.N);
    % Data.MeanEventPerMin(8,2)=std([Data.EventsPerMin.Min8])./sqrt(Data.N);
    % Data.MeanEventPerMin(9,2)=std([Data.EventsPerMin.Min9])./sqrt(Data.N);
    % Data.MeanEventPerMin(10,2)=std([Data.EventsPerMin.Min10])./sqrt(Data.N);
    % Data.MeanEventPerMin(11,2)=std([Data.EventsPerMin.Min11])./sqrt(Data.N);
    % Data.MeanEventPerMin(12,2)=std([Data.EventsPerMin.Min12])./sqrt(Data.N);
end