function Data=EventOutputs(Data,Parameters)
    SynchWindow=2;

    count=1;

    BaseSpikes=sum(Data(1).EventMap,2);
    ModSpikes=sum(Data(2).EventMap(:,1:960/4),2);
    FluxMagnitude=Data(2).FluxMagnitude;

    Data(Parameters.n_files+1).Output=cat(2,BaseSpikes,ModSpikes,FluxMagnitude);
    
    for i=1:Parameters.n_files
        %Compute Synchrony Measures
        Synch=sum(Data(i).EventMap,1)./Parameters.N;
        Synch=imbinarize(Synch,0.1);
        Data(i).Synch=Synch;
        AsyncronousEventMap=zeros(Parameters.N,length(Synch));
        for t=1:length(Synch)
            if ~Synch(t)
                AsyncronousEventMap(:,t)=Data(i).EventMap(:,t);
            end
        end
        

        for t=1:SynchWindow*Parameters.SamplingRate-1:Data(i).T-SynchWindow*Parameters.SamplingRate
            timeframe=t:t+SynchWindow*Parameters.SamplingRate;
            SynchEvents=Synch(timeframe);
            AvgAsyncEvents=mean(AsyncronousEventMap(:,timeframe),1);
            AsynchEvents=AsyncronousEventMap(:,timeframe);
            Events=Data(i).EventMap(:,timeframe);
            Data(Parameters.n_files+1).SpikeRate.Data(:,count)=sum(Events,2);
            Data(Parameters.n_files+1).TimeFrame.Data(:,count)=timeframe./(SynchWindow*Parameters.SamplingRate);
            
            Data(Parameters.n_files+1).SynchronyMeasures(:,count).SynchEvents=sum(SynchEvents)./(SynchWindow/60);
            Data(Parameters.n_files+1).SynchronyMeasures(:,count).AvgAsynchEvents=sum(AvgAsyncEvents)./(SynchWindow/60);
            Data(Parameters.n_files+1).SynchronyMeasures(:,count).AsynchEvents=sum(AsynchEvents,2);
            count=count+1;
        end
       Data(Parameters.n_files+1).SpikeRate.Mean=mean(Data(Parameters.n_files+1).SpikeRate.Data,1);
       Data(Parameters.n_files+1).SpikeRate.Dev=std(Data(Parameters.n_files+1).SpikeRate.Data,[],2);

        % AvgSpikeRate=mean(Data(Parameters.n_files+1).SpikeRate.Data,1);
    end

    Data(Parameters.n_files+1).SpikeRateNormalized.Mean=[Data(Parameters.n_files+1).SynchronyMeasures.AvgAsynchEvents];
    Data(Parameters.n_files+1).SpikeRateNormalized.Norm=(Data(Parameters.n_files+1).SpikeRateNormalized.Mean'-mean(Data(Parameters.n_files+1).SpikeRateNormalized.Mean(1:4)))./(Data(Parameters.n_files+1).SpikeRateNormalized.Mean'+mean(Data(Parameters.n_files+1).SpikeRateNormalized.Mean(1:4)));
end
        
    