function [Data,Parameters]=AnalyzeCalcium(varargin)
% Written and maintained by Connor Beck
% Updated April 2024

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
%   C) %NOT AVAILABLE YET. .
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
%
%   ''Reduce Cells''        integer (Default no reduction)
%                           Randomly samples from the total population of 
%                           neurons based on the given value.
%
%   ''Multifile''           Cell Array, String Values
%                           If your signals are separated in multiple
%                           files, you can enter them as a 'Multifile' by
%                           inserting a cell array with each file (within
%                           the same folder) as a string value. E.g.:
%                           {'Results_Baseline.csv','Results_Modulation.csv',
%                           'Results_Recovery.csv'}
%
%   ''Smoothing''           True/False (Default False) - Requires Multifile
%                           If using 'Multifile' and the intensity value
%                           jumps between files (focus, minor xy shifts)
%                           these can be normalized to create an
%                           artificially 'smooth' signal. *Note this must
%                           be used with caution as it can artifically
%                           adjust intensity values if used incorrectly.
%
%   ''Lower Envelope''      True/False (Default False)
%                           In cases where neuron's influx calcium for a
%                           long period of time (I.E. nanomagnetic forces), 
%                           measuring the Lower Envelope can be used to
%                           quantify the results.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Event Detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   ''Standard Deviation''  integer (Recommended >1) (Default 1.5)
%                           Event detection uses a standard deviation of
%                           the total signal to isolate events, along with
%                           a static noise threshold. These can be tuned to
%                           appropriately detect calcium influx events.
%
%   ''Noise threshold''     integer (Recommended >0.1) (Default 1.5)
%                           Event detection uses a nosie threshold based on 
%                           deltaF/F to isolate events, along with a
%                           standard deviation threshold. These can be tuned 
%                           to appropriately detect calcium influx events.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   ''Plot Calcium''        True/False (Default False)
%                           Outputs an image of the calcium signals, where
%                           the x-axis is time and the y-axis is the neuron index
%
%   ''SetCaPosition''       *Requires Plot Calcium*
%                           4-value array [x0,y0,width,height]
%                           Adjusts the Plot Calcium figure to a specified
%                           window size. All values are percentage of
%                           screen size. E.g. 0.1 -> 10%
%
%   ''Plot Events''         True/False (Default False)
%                           Outputs an plot of the detected calcium influx 
%                           events, where the x-axis is time and the y-axis 
%                           is the neuron index
%


    %Base plot settings
    Parameters.CaPlot.PlotCa=false;
    Parameters.CaPlot.Position=[];
    Parameters.CaPlot.SaveCaPlotFile={};
    Parameters.CaPlot.SaveCaPlot.Path=[];
    
    Parameters.PlotEvents=false;

    %Base parameter settings
    Parameters.Multifile=NaN;
    Parameters.ImportType='Mean';
    Parameters.Smoothing=false;
    Parameters.ForceCalculation=false;
    Parameters.TimeJumps=false;
    Parameters.Reduction=NaN;
    Parameters.Outputs=false;
    Parameters.InfluxOnly=false;
    Parameters.InfluxTimepoint=NaN;
    Parameters.PhotobleachCorrection.state=false;
    Parameters.SelectSmoothing=false;

    Parameters.standardDev=3;
    Parameters.noiseThreshold=0.005;
    Parameters.SamplingRate=4;
    Parameters.ModulationTime=NaN;
    Parameters.removeinactive=true;
    

    switch nargin
        case 0
            [filename,path] = uigetfile('*.csv');
            Parameters.file=strcat(path,filename);
        case 1
            Parameters.file=varargin{1};
        case 2
            Parameters.file=varargin{1};
            Parameters.Multifile=varargin{2};
        otherwise
            if ~mod(nargin,2)
                error('incorrect number of inputs');
            else
                Parameters.file=varargin{1};
                for i=2:2:nargin
                    if strcmp(varargin{i},'Reduce Cells')
                        Parameters.Reduction=varargin{i+1};
                    elseif strcmp(varargin{i},'Standard Deviation')
                        Parameters.standardDev=varargin{i+1};
                    elseif strcmp(varargin{i},'Photobleach Correction')
                        Parameters.PhotobleachCorrection.state=varargin{i+1};
                    elseif strcmp(varargin{i},'Noise Threshold')
                        Parameters.noiseThreshold=varargin{i+1};
                    elseif strcmp(varargin{i},'Force Calculation')
                        Parameters.ForceCalculation=varargin{i+1};
                    elseif strcmp(varargin{i},'Sampling Rate')
                        Parameters.SamplingRate=varargin{i+1};
                    elseif strcmp(varargin{i},'Smoothing')
                        Parameters.Smoothing=varargin{i+1};
                    elseif strcmp(varargin{i},'Select Smoothing')
                        Parameters.SelectSmoothing=true;
                        Parameters.SelectSmoothingList=varargin{i+1};
                    elseif strcmp(varargin{i},'ModulationTime')
                        Parameters.ModulationTime=varargin{i+1};
                    elseif strcmp(varargin{i},'Multifile')
                        Parameters.Multifile=varargin{i+1};
                    elseif strcmp(varargin{i},'Time Jumps')
                        Parameters.TimeJumps=varargin{i+1};
                    elseif strcmp(varargin{i},'remove inactive')
                        Parameters.removeinactive=varargin{i+1};
                    elseif strcmp(varargin{i},'Outputs')
                        Parameters.Outputs=varargin{i+1};
                    elseif strcmp(varargin{i},'Plot Calcium')
                        Parameters.CaPlot.PlotCa=varargin{i+1};
                    elseif strcmp(varargin{i},'SetCaPosition')
                        Parameters.CaPlot.Position=varargin{i+1};
                    elseif strcmp(varargin{i},'Influx Only')
                        Parameters.InfluxOnly=varargin{i+1};
                    elseif strcmp(varargin{i},'Influx Timepoint')
                        Parameters.InfluxTimepoint=varargin{i+1};
                    elseif strcmp(varargin{i},'Import Type')
                        Parameters.ImportType=varargin{i+1};
                    elseif strcmp(varargin{i},'SaveCaPlot')
                        if length(varargin{i+1})==2
                            Parameters.CaPlot.SaveCaPlot.Path=varargin{i+1}{1};
                            Parameters.CaPlot.SaveCaPlot.ID=varargin{i+1}{2};
                            Parameters.CaPlot.SaveCaPlot.File=strcat(string(Parameters.CaPlot.SaveCaPlot.Path),"\",string(Parameters.CaPlot.SaveCaPlot.ID));
                        else
                            if isstring(Parameters.CaPlot.SaveCaPlot)
                                Parameters.CaPlot.SaveCaPlot.File=[Parameters.CaPlotSaveCaPlot.Path,'\',Parameters.CaPlot.SaveCaPlot.ID];
                            else
                                [Parameters.CaPlot.SaveCaPlot.ID,Parameters.CaPlot.SaveCaPlot.Path] = uiputfile;
                                Parameters.CaPlot.SaveCaPlot.File=strcat(string(Parameters.CaPlot.SaveCaPlot.Path),"\",string(Parameters.CaPlot.SaveCaPlot.ID));
                            end
                        end
                    elseif strcmp(varargin{i},'Plot Events')
                        PlotEvents=varargin{i+1};
                    else
                        error('The argument is not recognized')
                    end
                end
            end
            
    end
    
    %% Core Code
    % Import the data
    [Data,Parameters]=importImageJData(Parameters);
    
    
    %All signals will be normalized to deltaF/F using the lower envelope
    %method.
    [Data,Parameters]=Normalization(Data,Parameters);

    %Detection of Influx events
    [Data,Parameters]=EventDetection(Data,Parameters);


        % If you are looking for a specific N(Neurons) - Set reduction to the
    % desired value
    if ~isnan(Parameters.Reduction)
        Data=reduceNumber(Data,Parameters);
    end
    %% Other useful post-analysis functions    

    %     Data=EventChanges(Data);
    %     Data=correlateSynch(Data);
    if Parameters.Outputs
        Data=EventOutputs(Data,Parameters);
    end

    %% Plotting

    if Parameters.CaPlot.PlotCa
        figure('Name','Calcium Heatmap')

        PlotFNormSignals(Data,Parameters)
    end

    if Parameters.PlotEvents
        figure('Name','Calcium Events');
        PlotEvents(Data,Parameters)
    end

end