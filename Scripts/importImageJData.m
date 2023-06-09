function [Data,Parameters]=importImageJData(Parameters)
    %Check if there are multiple files to import
    if iscell(Parameters.Multifile)
        Parameters.n_files=size(Parameters.Multifile,2);
        filename=cell(Parameters.n_files,1);
        for i=1:length(Parameters.Multifile)
            name=Parameters.Multifile{i};
            filename{i}=strcat(Parameters.file,name);
        end
    else
        Parameters.n_files=1;
        filename{1}=Parameters.file;
    end
    
    for i=1:Parameters.n_files
        count=1;
        T=readtable(filename{i});
        varNames=T.Properties.VariableNames;
        for j=1:size(T,2)
            if length(varNames{j})>=4
                if strcmp(varNames{j}(1:4),'Mean')
                    Data(i).F(:,count)=table2array(T(:,j));
                    count=count+1;
                end
            end
        end
        Data(i).N=size(Data(i).F,2);
        Data(i).T=size(Data(i).F,1);
    end

    
    %Remove any signals with NaN (ROI analysis pushes some ROIs out of the frame when shifted
    %during mag and post videos)
    
    count=0;
    for n=1:Data(1).N
        delete=false;
        for i=1:Parameters.n_files
            if any(isnan(Data(i).F(:,n-count)))
                delete=true; 
            end
        end
        if delete
            for i=1:Parameters.n_files
                Data(i).F(:,n-count)=[];
                Data(i).N=Data(i).N-1;
            end
            count=count+1;
        end
    end
end