function Data=Normalization(Data,Parameters)
    
    if isnan(Parameters.ModulationTime)
        T=Data(1).T;
    else
        T=Parameters.ModulationTime;
    end

    %% Smooth Signals (e.g. Mag initial is much stronger than Pre because of focus point shift)
    if Parameters.Smoothing && length(Data)>1 && Data(1).N==Data(2).N
        for i=1:length(Data)-1
            First_End=mean(Data(i).F(end-5:end,:),1);
            Second_Beginning=mean(Data(i+1).F(1:5,:),1);

            difference=First_End-Second_Beginning;
            Data(i).F=Data(i).F+difference;
        end
    end
    
    %Concatenate all data together on time dimension for smooth lower envelope
    Sg=[];
    for i=1:length(Data)
        Sg=cat(1,Sg,Data(i).F);
    end
    
    
    %Calculate the lower envelope of the time period
    for n=1:Data(1).N
        [~,lo] = envelope(Sg(:,n),Parameters.SamplingRate*10,'peak');
        S(:,n)=lo;
    end
    % F0 only occurs from the first video
    Data(1).F0=mean(S(1:ceil(0.9*T),:),1);
        
    %Compute the normalized resting potential: [Lower Envelope - F0)/F0] 
    LE=(S-Data(1).F0)/Data(1).F0;

    %Add the resting potential, compute deltaF/F (Fnorm), and the flux
    %magnitude over each series.
    count=0;
    for i=1:length(Data)
        Data(i).LE=LE(1+count:count+Data(i).T,:);
        Data(i).Fnorm=(Data(i).F-Data(1).F0)./Data(1).F0;
        Data(i).FluxMagnitude=sum(Data(i).LE,1)';
        count=count+Data(i).T;
    end

end