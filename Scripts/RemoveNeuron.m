function [Data,Parameters]=RemoveNeuron(Data,Parameters,n)

     %Base Fluorescence
    if isfield(Data(1),'F0')
        Data(1).F0(n)=[];
    end

    for i=1:Parameters.n_files+1
        %Fluorescent Signal
        if isfield(Data(i),'F') && ~isempty(Data(i).F)
            Data(i).F(:,n)=[];
        end

        % %Coordinates
        % if isfield(Parameters.Coordinates,'X') && ~isempty(Parameters.Coordinates.X)
        %     Parameters.Coordinates.X(n)=[];
        % end
        % if isfield(Parameters.Coordinates,'Y') && ~isempty(Parameters.Coordinates.Y)
        %     Parameters.Coordinates.Y(n)=[];
        % end
        % if isfield(Parameters.Coordinates,'BdelB') && ~isempty(Parameters.Coordinates.BdelB)
        %     Parameters.Coordinates.BdelB(n)=[];
        % end

        %Lower Envelope
        if isfield(Data(i),'LE') && ~isempty(Data(i).LE)
            Data(i).LE(:,n)=[];
        end

        %Normalized Fluorescence
        if isfield(Data(i),'Fnorm') && ~isempty(Data(i).Fnorm)
            Data(i).Fnorm(:,n)=[];
        end

        %Flux Magnitude
        if isfield(Data(i),'FluxMagnitude') && ~isempty(Data(i).FluxMagnitude)
            Data(i).FluxMagnitude(n)=[];
        end

        % Fluorescence removed influx
        if isfield(Data(i),'FrE') && ~isempty(Data(i).FrE)
            Data(i).FrE(:,n)=[];
        end
        
        %Events
        if isfield(Data(i),'Events') && ~isempty(Data(i).Events)
            Data(i).Events(n)=[];
        end

        %Event Map
        if isfield(Data(i),'EventMap') && ~isempty(Data(i).EventMap)
            Data(i).EventMap(n,:)=[];
        end

        %Event Scatter
        if isfield(Data(i),'EventScatter') && ~isempty(Data(i).EventScatter)
            idx=find(Data(i).EventScatter(:,2)==n);
            Data(i).EventScatter(idx,:)=[];
            for k=1:size(Data(i).EventScatter,1)
                if Data(i).EventScatter(k,2)>n
                    Data(i).EventScatter(k,2)=Data(i).EventScatter(k,2)-1;
                end
            end
        end
    end
end