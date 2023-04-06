function PlotFNormSignals(Data)
    clims = [-0.1 0.5];
    for i=1:length(Data)
        subplot(1,length(Data),i)
        imagesc(Data(i).Fnorm',clims);
        colormap jet
        xlabel('Time (samples)')
        xlim([0,Data(i).T])

        ylabel('Neuron #')
        ylim([0,Data(i).N])
    end
    colorbar();
end