function PlotFNormSignals(Data,Parameters)
    clims = [-0.1 0.5];
    for i=1:Parameters.n_files
        subplot(1,Parameters.n_files,i)
        imagesc(Data(i).Fnorm',clims);
        colormap jet
        xlabel('Time (min)')
        
        t=0:Parameters.SamplingRate*60:Data(i).T;
        for m=1:length(t)
            Labels{m}=num2str(m-1);
        end
        xticks(t);
        xticklabels(Labels);

        xlim([0,Data(i).T])

        ylabel('Neuron #')
        ylim([0,Parameters.N])

        title([Parameters.Multifile{i}])
    end
    colorbar();
    if ~isempty(Parameters.CaPlot.Position)
        set(gcf,'Units','normalized','position',Parameters.CaPlot.Position)
    end
    %Save figure if selected
    if ~isempty(Parameters.CaPlot.SaveCaPlot.Path)
        filepath=Parameters.CaPlot.SaveCaPlot.Path;
        if ~exist(filepath, 'dir')
            mkdir(filepath);
        end
        filename=Parameters.CaPlot.SaveCaPlot.File;
        saveas(gcf,filename,'png')
        close(gcf);
    end        
end