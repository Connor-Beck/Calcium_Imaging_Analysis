function PlotEvents(Data,Parameters)
    for i=1:Parameters.n_files
        subplot(1,Parameters.n_files,i);
        scatter(Data(i).EventScatter(:,1),Data(i).EventScatter(:,2),3,'k','filled')
        
        xlabel('Time (min)')
        
        xlim([0,Data(i).T/(60*Parameters.SamplingRate)])

        ylabel('Neuron #')
        ylim([0,Parameters.N])
        
        title([Parameters.Multifile{i}])
    end
end
