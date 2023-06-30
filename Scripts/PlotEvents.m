function PlotEvents(Data,Parameters)
    for i=1:Parameters.n_files
        subplot(1,Parameters.n_files,i);
        scatter(Data(i).EventScatter(:,1),Data(i).EventScatter(:,2),3,'k','filled')
        
        xlabel('Time (samples)')
        xlim([0,Data(i).T])

        ylabel('Neuron #')
        ylim([0,Data(i).N])

    end
end
