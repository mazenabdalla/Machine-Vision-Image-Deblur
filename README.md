# Motion Blur Removal in Images

This code is used to compare manual deconvolution to MATLAB's blind deconvolution technique.

## ManualImageDeblur.m

1. This file can be run directly from the MATLAB console and should open a GUI. The user can load an image by clicking the "Load Image" button.
2. Once the image is loaded, the user may press "Add line" to draw a blur kernel estimate. This should be in the same direction and length of the motion blur in the image.
3. The Wiener NSR can be modified according to the results of the deconvolution. A higher NSR means more noise reduction in the output.
4. Press the "Run Deconvolution" button and click on the Output tab to see the output image. This may take a few seconds or minutes depending on the size of the image and the speed of your computer.
5. The user may alternatively check the "Blind deconvolution" check box before pressing "Run Deconvolution" in order to use MATLAB's built-in blind deconvolution function based off of the mean squared error algorithm. Note that this still requires a blur kernel estimate to be drawn. Also note that this checkbox will significantly increase the processing time for the image.

![alt text](https://i.imgur.com/XmKZJxJ.png)

## getBlurDirection.m

This file is a function for estimating the blur direction in a motion blurred image. This can be implemented in future code to automatically find the blur direction for unsupervised blind deconvolution. The function takes the file location of an image as the input and will output an estimate of the blur direction in degrees.
