function [Data,Parameters]=Normalization(Data,Parameters)
    
    if isnan(Parameters.ModulationTime)
        T=Data(1).T;
    else
        T=Parameters.ModulationTime;
    end

    %% Smooth Signals (e.g. Mag initial is much stronger than Pre because of focus point shift)
    if Parameters.Smoothing && length(Data)>1
        for i=1:Parameters.n_files-1
            First_End=mean(Data(i).F(end-40:end,:),1);
            Second_Beginning=mean(Data(i+1).F(1:40,:),1);

            difference=First_End-Second_Beginning;
            Data(i+1).F=Data(i+1).F+difference;
        end
    elseif Parameters.SelectSmoothing
        for i=1:size(Parameters.SelectSmoothingList,1)
            A=Parameters.SelectSmoothingList(i,1);
            B=Parameters.SelectSmoothingList(i,2);

            First_End=mean(Data(A).F(end-40:end,:),1);
            Second_Beginning=mean(Data(B).F(1:40,:),1);

            difference=First_End-Second_Beginning;
            Data(B).F=Data(B).F+difference;
        end
    end
    
    %Concatenate all data together on time dimension for smooth lower envelope
    
    Sg=[];
    for i=1:Parameters.n_files
        Sg=cat(1,Sg,Data(i).F);
    end
    
    %Calculate the lower envelope of the time period
    if Parameters.TimeJumps
        
        N=Parameters.n_files;

        if Parameters.SelectSmoothing
            for j=1:size(Parameters.SelectSmoothingList,1)
                A=[Parameters.SelectSmoothingList(j,1)];
                B=[Parameters.SelectSmoothingList(j,2)];
                Sg=cat(1,[Data(A).F],Data(B).F);
                Data(N+1).CombinedSignal(j).Sg=Sg;
            end
        end
        
        LE=[];
        SkipNext=false;
        for i=1:N
            if ~SkipNext
                LE_tmp=[];
                if Parameters.SelectSmoothing && ismember(i,Parameters.SelectSmoothingList(:,1))
                    j=find(Parameters.SelectSmoothingList(:,1)==i);
                    Sg=Data(N+1).CombinedSignal(j).Sg;

                    SkipNext=true;
                else
                    Sg=Data(i).F;
                end
                for n=1:Parameters.N 
                    [~,lo] = envelope(Sg(:,n),Parameters.SamplingRate*30,'peak');%was 10
                    if i==1
                        % F0 only occurs from the first video
                        Data(1).F0(n)=mean(lo(floor(0.1*T):ceil(0.9*T),:),1);
                    end
        
                    %Compute the normalized resting potential: [Lower Envelope - F0)/F0] 
                    LE_tmp(:,n)=(lo-Data(1).F0(n))./Data(1).F0(n);  
                end
                LE=cat(1,LE,LE_tmp);
            else
                SkipNext=false;
            end
        end
        Data(Parameters.n_files+1).LE=LE;
    else      
        for n=1:Parameters.N
            [~,lo] = envelope(Sg(:,n),Parameters.SamplingRate*30,'peak');%was 10
            Data(1).lo(:,n)=lo;
            % F0 only occurs from the first video
            Data(1).F0(n)=mean(lo(floor(0.1*T):ceil(0.9*T),:),1);
    
            %Compute the normalized resting potential: [Lower Envelope - F0)/F0] 
            LE(:,n)=(lo-Data(1).F0(n))./Data(1).F0(n);
        end
    end
    
    %Add the resting potential, compute deltaF/F (Fnorm), and the flux
    %magnitude over each series.
    count=0;
    if ~Parameters.SelectSmoothing
        Data(Parameters.n_files+1).LE=[];
        Data(Parameters.n_files+1).LEavg=[];
        Data(Parameters.n_files+1).Fnorm=[];
    end
    for i=1:Parameters.n_files
        %Compute individual values for each of the files  
        Data(i).LE=LE(1+count:count+Data(i).T,:);
        Data(i).Fnorm=(Data(i).F-Data(1).F0)./Data(1).F0;
        Data(i).FluxMagnitude=sum(Data(i).LE-Data(i).LE(1,:),1)';
        count=count+Data(i).T;

        %Create a Data entry at the end which contains the total signals
        if ~Parameters.SelectSmoothing
            if Parameters.n_files>1
                Data(Parameters.n_files+1).LE=cat(1,Data(Parameters.n_files+1).LE,Data(i).LE);
                Data(Parameters.n_files+1).LEavg=cat(1,Data(Parameters.n_files+1).LEavg,mean(Data(i).LE,2));
                Data(Parameters.n_files+1).Fnorm=cat(1,Data(Parameters.n_files+1).Fnorm,Data(i).Fnorm);
            end
        end
    end
    if Parameters.InfluxOnly
        if ~isnan(Parameters.InfluxTimepoint)
            Timepoint=Parameters.InfluxTimepoint;
        else
            Timepoint=2;
        end
        count=0;
        for n=1:Parameters.N
            if Data(Timepoint).FluxMagnitude(n-count)<50
                [Data,Parameters]=RemoveNeuron(Data,Parameters,n-count);
                if Parameters.ForceCalculation
                    Parameters.Coordinates.X(n-count)=[];
                    Parameters.Coordinates.Y(n-count)=[];
                    Parameters.Coordinates.BdelB(n-count)=[];
                end
                Parameters.N=Parameters.N-1;
                count=count+1;
            end
        end
        Data(Parameters.n_files+1).LEavg=[];
        for i=1:Parameters.n_files
            Data(Parameters.n_files+1).LEavg=cat(1,Data(Parameters.n_files+1).LEavg,mean(Data(i).LE,2));
        end
    end
end