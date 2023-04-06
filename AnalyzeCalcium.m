function Data=AnalyzeCalcium(varargin)
%   Written by Connor Beck 2023

%   AnalyzeCalcium takes raw ImageJ mean intensity files of calcium and
%   computes DeltaF/F (the research standard for calcium signals) and calcium 
%   influx event detection to characterize network communication. A couple
%   of other resources are included with descriptions below.
%   
%   IMPORTANT: All input files must be saved directly from ImageJ with the
%   mean intensity after multimeasure - see ImageJ analysis for
%   clarification.
%
%   Recommended:
%   Data=AnalyzeCalcium('Dataset_A.csv','Plot Calcium',true,'Plot Events',true)
%   
%   OUTPUT
%   Invoking AnalyzeCalcium returns:
%   Data

%   Everything computed within the function is passed through the data
%   structure.
%
%   REQUIRED INPUT ARGUMENT
%   The argument csv_file_or_data is either 
%   A)  Nothing - you will be prompted to select a file to analyze.
%   B)  A char array identifying a CSV text file containing the data to be
%       analyzed.
%   C) %NOT AVAILABLE YET. A numeric matrix to be reduced; a numeric matrix.
%
%     
%
%   The CSV file must follow ImageJ formatting with
%   measurements 'Mean Intensity' selected in set measurements.
%
%   Invoke AnalyzeCalcium with no arguments to search for a Dataset on your computer.
%
%%   OPTIONAL NAME VALUE PAIR ARGUMENTS
%   The base AnalyzeCalcium function can be used with these optional input
%   arguements to quickly observe data before moving on to further
%   analysis.

%   The optional argument name/value pairs are:
%
%    NAME                   VALUE

%   ''Standard Deviation''  integer (Recommended >1) (Default 1.5)
%                           Event detection uses a standard deviation of
%                           the total signal to isolate events, along with
%                           a static noise threshold. These can be tuned to
%                           appropriately detect calcium influx events.

%   ''Noise threshold''     integer (Recommended >0.1) (Default 1.5)
%                           Event detection uses a nosie threshold based on 
%                           deltaF/F to isolate events, along with a
%                           standard deviation threshold. These can be tuned 
%                           to appropriately detect calcium influx events.

%   ''Lower Envelope''      True/False (Default False)
%                           In cases where neuron's influx calcium for a
%                           long period of time (I.E. nanomagnetic forces), 
%                           measuring the Lower Envelope can be used to
%                           quantify the results.
%
%   ''Reduce Cells''        integer (Default no reduction)
%                           Randomly samples from the total population of 
%                           neurons based on the given value.
%
%   'Plot Calcium'          True/False (Default False)
%                           Outputs an image of the calcium signals, where
%                           the x-axis is time and the y-axis is the neuron index
%
%   'Plot Events'           True/False (Default False)
%                           Outputs an plot of the detected calcium influx 
%                           events, where the x-axis is time and the y-axis 
%                           is the neuron index




    pltCa=false;
    pltEvents=false;

    Parameters.Smoothing=false;
    Parameters.Reduction=NaN;
    
    Parameters.standardDev=1.5;
    Parameters.noiseThreshold=0.1;
    Parameters.SamplingRate=4;
    Parameters.ModulationTime=NaN;

    switch nargin
        case 0
            [filename,path] = uigetfile('*.csv');
            file=strcat(path,filename);
        case 1
            file=varargin{1};
        case 2
            file=varargin{1};
            type=varargin{2};
        otherwise
            if ~mod(nargin,2)
                error('incorrect number of inputs');
            else
                file=varargin{1};
                for i=2:2:nargin
                    if strcmp(varargin{i},'Plot Calcium')
                        pltCa=varargin{i+1};
                    elseif strcmp(varargin{i},'Plot Events')
                        pltEvents=varargin{i+1};
                    elseif strcmp(varargin{i},'Reduce Cells')
                        Parameters.Reduction=varargin{i+1};
                    elseif strcmp(varargin{i},'Standard Deviation')
                        Parameters.standardDev=varargin{i+1};
                    elseif strcmp(varargin{i},'Noise Threshold')
                        Parameters.noiseThreshold=varargin{i+1};
                    elseif strcmp(varargin{i},'Sampling Rate')
                        Parameters.SamplingRate=varargin{i+1};
                    elseif strcmp(varargin{i},'Smoothing')
                        Parameters.Smoothing=varargin{i+1};
                    elseif strcmp(varargin{i},'ModulationTime')
                        Parameters.ModulationTime=varargin{i+1};
                    else
                        error('The argument is not recognized')
                    end
                end
            end
            
    end
    
    %% Core Code
    % Import the data
    Data=importData(file);
    
    % If you are looking for a specific N(Neurons) - Set reduction to the
    % desired value
    if ~isnan(Parameters.Reduction)
        Data=reduceNumber(Data,Parameters.Reduction);
    end
    
    %All signals will be normalized to deltaF/F using the lower envelope
    %method.
    Data=Normalization(Data,Parameters);
   
    %Detection of Influx events
    Data=EventDetection(Data,Parameters);
    
    %% Other useful post-analysis functions    

    %     Data=EventOutputs(Data);
    %     Data=EventChanges(Data);
    %     Data=correlateSynch(Data);


    %% Plotting

    if pltCa
        figure('Name','Calcium Heatmap')
        
        PlotFNormSignals(Data)
    end
    
    if pltEvents
        figure('Name','Calcium Events');
        PlotEvents(Data)
    end

end