# Dislin_x_y_plot
A simplified and adjustable Fortran module to quickly create nice 2-D Dislin plots from within a Fortran program.

### Required libraries
This module requires an installed and linked DISLIN graphics library         (https://www.dislin.de/index.html) for your (Fortran) compiler and operating system of choice. See that website for details about Dislin and installation instructions for different platforms.

## Purpose
The purpose of the Fortran module `Mod_Dislin_plots` is to allow a user to generate plots from within a Fortran program nearly as easily as with the provided Dislin "quickplots".
However, unlike the quickplots, this module offers a lot more options for controlling the plot page, axis system and various curve properties. It also makes adding multiple x--y data sets (curves) to a single plot a piece of cake.

## Examples
Two examples for the use of the `Mod_Dislin_plots` module are included in the main program `Prog_Dislin_Examples`. See also the specific comments in that file.

## Structure & options
The module `Mod_Dislin_plots` contains two subroutines:

- subroutine  `add_plot_xydata` allows adding and specifying the x--y data for a curve, with several optional data set characteristics listed below. For adding more than one curve to an existing plot, you simply call this subroutine multiple times (once for each curve).
- subroutine `dislin_plot` is used to generate the plot containing one or more curves. 
- The subroutine call of `dislin_plot` allows for setting arguments for the axis labels, the aspect ratio of the plot, the legend position, and the axis ranges. See the interface details within `Mod_Dislin_plots`.

A number of data set (curve) properties can be controlled via optional arguments in the call of `add_plot_xydata`, these include:

 - arrays of x and y values of data set to be added
 - legend entry text for data set
 - pen width in plot pixels
 - color array of the 3 red, green, blue (RGB) values, each in range [0, 255]
 - line style; options: 'solid', 'dotted', 'dashed', 'dashed_medium'
 - plot curves w/ or w/o symbols or symbols only (options: 'symbols', 'curve', 'both')
 - the symbol ID for dislin (15 = open circle, 5 = open diamond, 3 = +, 4 = X, 16 = filled square, 21 = filled circle, etc.)
 
 Other features from the Dislin graphics library could be added based on your needs.
 
## Editing made plots
My preferred way of editing made plots (when saved as .pdf) outside of the Fortran program is by using a vector graphics editing software like Inkscape (https://inkscape.org). For example, this will allow you to extract the plot in vector graphics format, rearranging several plots into a figure, changing fonts, adding text, and many other things. 
Import the pdf into incscape > mark the plot page > ungroup > delete unwanted things such as the page background; re-group and/or rearrange the plot into a multipanel figure, etc. For changing fonts, such as from Helvetica to Arial, use Extensions > Text > Replace font.
