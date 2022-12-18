classdef ManualImageDeblur < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        GridLayout              matlab.ui.container.GridLayout
        EdgeDetect              matlab.ui.control.CheckBox
        BlindCheckBox           matlab.ui.control.CheckBox
        ExportImageButton       matlab.ui.control.Button
        BeginbyloadingyourblurredimageLabel  matlab.ui.control.Label
        LoadImageButton         matlab.ui.control.Button
        RunDeconvolutionButton  matlab.ui.control.Button
        WienerNSRLabel          matlab.ui.control.Label
        Spinner                 matlab.ui.control.Spinner
        AddlineButton           matlab.ui.control.Button
        BlurkernelLabel         matlab.ui.control.Label
        TabGroup                matlab.ui.container.TabGroup
        InputTab                matlab.ui.container.Tab
        MainAxes                matlab.ui.control.UIAxes
        OutputTab               matlab.ui.container.Tab
        KernelAxes              matlab.ui.control.UIAxes
        TitleLabel              matlab.ui.control.Label
    end

    
    properties (Access = private)
        InputImage % Description
        Kernel % Description
        Line % Description
        NSR % Description
        Unblurred % Description
    end
    
    methods (Access = private)
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
            app.MainAxes.Visible = 'off';
            app.KernelAxes.Visible = 'off';
            app.NSR = 0.001;

        end

        % Button pushed function: LoadImageButton
        function LoadImageButtonPushed(app, event)
            try
                [file,path] = uigetfile('*.jpg;*.png;*.tif');  %open an image file
                            
                app.InputImage = double(imread(strcat(path,file))) ./ 255;

                if app.EdgeDetect.Value == 1

                    E1 = [0, -1, 0; 0, 2, -1; 0, 0, 0];
                    edge_detect = conv2(E1, im2gray(app.InputImage));
                    imshow(edge_detect ./ max(max(max(edge_detect))), 'parent', app.MainAxes);

                else

                    imshow(app.InputImage, 'parent', app.MainAxes);

                end

            catch e
                
            end

        end

        % Button pushed function: AddlineButton
        function AddlineButtonPushed(app, event)

            app.Line = drawline(app.MainAxes, 'Color', 'r');
            
        end

        % Button pushed function: RunDeconvolutionButton
        function RunDeconvolutionButtonPushed(app, event)

            % Get drawn line coordinates
            coords = floor(app.Line.Position);

            % Find kernel given line coordinates
            len = sqrt((coords(1,1) - coords(2,1))^2 + (coords(1,2) - coords(2,2))^2);
            theta = -1 * atand((coords(1,2) - coords(2,2))/(coords(1,1) - coords(2,1)));
            kernel = fspecial('motion', len, theta);

            % Deconvolve
            if app.BlindCheckBox.Value == 1

                [app.Unblurred, ~] = deconvblind(app.InputImage, kernel);

            else
    
                blurred_f = fft2(app.InputImage);
                K_f = fft2(kernel, size(app.InputImage, 1), size(app.InputImage, 2));

                % Ensure K_f is never zero
                if min(min(K_f)) == 0
                    K_f = K_f + 2e-38;
                end

                unblur_f = (blurred_f ./ K_f) ./ (1 + app.NSR./(abs(K_f).^2));
                app.Unblurred = abs(ifft2(unblur_f));
                
            end

            % Display the resulting deconvolved image
            imshow(app.Unblurred, 'parent', app.KernelAxes);

        end

        % Value changed function: Spinner
        function SpinnerValueChanged(app, event)
            
            app.NSR = app.Spinner.Value;
            
        end

        % Button pushed function: ExportImageButton
        function ExportImageButtonPushed(app, event)
            
            try

                [file, path] = uiputfile({'*.jpg';'*.png';'*.tif';'*.*'});
                imwrite(app.Unblurred, strcat(path, file));

            catch e

            end

        end

        % Value changed function: EdgeDetect
        function EdgeDetectValueChanged(app, event)

            if app.EdgeDetect.Value == 1

                E1 = [0, -1, 0; 0, 2, -1; 0, 0, 0];
                edge_detect = conv2(E1, im2gray(app.InputImage));
                imshow(edge_detect ./ max(max(max(edge_detect))), 'parent', app.MainAxes);
                
            else
                
                imshow(app.InputImage, 'parent', app.MainAxes);
                
            end
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 997 785];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'2.34x', 199, 100, '25x', '3.14x', 140, '1x', '2x'};
            app.GridLayout.RowHeight = {47, 25, '2x', 22, '2.73x', 22, 22, '1.93x', 22, 22, 28, 22, '24x', 25, 25};

            % Create TitleLabel
            app.TitleLabel = uilabel(app.GridLayout);
            app.TitleLabel.HorizontalAlignment = 'center';
            app.TitleLabel.FontSize = 36;
            app.TitleLabel.Layout.Row = 1;
            app.TitleLabel.Layout.Column = [3 4];
            app.TitleLabel.Text = 'Motion Blur Remover';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = [3 15];
            app.TabGroup.Layout.Column = [1 5];

            % Create InputTab
            app.InputTab = uitab(app.TabGroup);
            app.InputTab.Title = 'Input';

            % Create MainAxes
            app.MainAxes = uiaxes(app.InputTab);
            title(app.MainAxes, 'Input image')
            app.MainAxes.Position = [2 1 775 648];

            % Create OutputTab
            app.OutputTab = uitab(app.TabGroup);
            app.OutputTab.Title = 'Output';

            % Create KernelAxes
            app.KernelAxes = uiaxes(app.OutputTab);
            title(app.KernelAxes, 'Output')
            app.KernelAxes.Position = [3 1 774 648];

            % Create BlurkernelLabel
            app.BlurkernelLabel = uilabel(app.GridLayout);
            app.BlurkernelLabel.Layout.Row = 3;
            app.BlurkernelLabel.Layout.Column = [6 7];
            app.BlurkernelLabel.Text = 'Blur kernel:';

            % Create AddlineButton
            app.AddlineButton = uibutton(app.GridLayout, 'push');
            app.AddlineButton.ButtonPushedFcn = createCallbackFcn(app, @AddlineButtonPushed, true);
            app.AddlineButton.Layout.Row = 4;
            app.AddlineButton.Layout.Column = [6 7];
            app.AddlineButton.Text = 'Add line';

            % Create Spinner
            app.Spinner = uispinner(app.GridLayout);
            app.Spinner.Step = 0.0005;
            app.Spinner.ValueChangedFcn = createCallbackFcn(app, @SpinnerValueChanged, true);
            app.Spinner.Layout.Row = 7;
            app.Spinner.Layout.Column = [6 7];
            app.Spinner.Value = 0.001;

            % Create WienerNSRLabel
            app.WienerNSRLabel = uilabel(app.GridLayout);
            app.WienerNSRLabel.Layout.Row = 6;
            app.WienerNSRLabel.Layout.Column = [6 7];
            app.WienerNSRLabel.Text = 'Wiener NSR:';

            % Create RunDeconvolutionButton
            app.RunDeconvolutionButton = uibutton(app.GridLayout, 'push');
            app.RunDeconvolutionButton.ButtonPushedFcn = createCallbackFcn(app, @RunDeconvolutionButtonPushed, true);
            app.RunDeconvolutionButton.Layout.Row = 11;
            app.RunDeconvolutionButton.Layout.Column = [6 7];
            app.RunDeconvolutionButton.Text = 'Run Deconvolution';

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.GridLayout, 'push');
            app.LoadImageButton.ButtonPushedFcn = createCallbackFcn(app, @LoadImageButtonPushed, true);
            app.LoadImageButton.Layout.Row = 2;
            app.LoadImageButton.Layout.Column = 3;
            app.LoadImageButton.Text = 'Load Image';

            % Create BeginbyloadingyourblurredimageLabel
            app.BeginbyloadingyourblurredimageLabel = uilabel(app.GridLayout);
            app.BeginbyloadingyourblurredimageLabel.Layout.Row = 2;
            app.BeginbyloadingyourblurredimageLabel.Layout.Column = 2;
            app.BeginbyloadingyourblurredimageLabel.Text = 'Begin by loading your blurred image';

            % Create ExportImageButton
            app.ExportImageButton = uibutton(app.GridLayout, 'push');
            app.ExportImageButton.ButtonPushedFcn = createCallbackFcn(app, @ExportImageButtonPushed, true);
            app.ExportImageButton.Layout.Row = 14;
            app.ExportImageButton.Layout.Column = [6 7];
            app.ExportImageButton.Text = 'Export Image';

            % Create BlindCheckBox
            app.BlindCheckBox = uicheckbox(app.GridLayout);
            app.BlindCheckBox.Text = 'Blind deconvolution (takes longer)';
            app.BlindCheckBox.Layout.Row = 9;
            app.BlindCheckBox.Layout.Column = [6 8];

            % Create EdgeDetect
            app.EdgeDetect = uicheckbox(app.GridLayout);
            app.EdgeDetect.ValueChangedFcn = createCallbackFcn(app, @EdgeDetectValueChanged, true);
            app.EdgeDetect.Text = 'Show edge-detected version';
            app.EdgeDetect.Layout.Row = 2;
            app.EdgeDetect.Layout.Column = 4;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = ManualImageDeblur

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end