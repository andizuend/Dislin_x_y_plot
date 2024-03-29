# Dislin_x_y_plot
A simplified and adjustable Fortran module to quickly create nice 2D Dislin plots from within a Fortran program.

### Required libraries
This module requires an installed and linked DISLIN graphics library (https://www.dislin.de/index.html) for your (Fortran) compiler and operating system of choice. See that website for details about Dislin and installation instructions for different platforms. Some information is also given below.

## Purpose
The purpose of the Fortran module `Mod_Dislin_plots` is to allow a user to generate plots from within a Fortran program nearly as easily as with the provided Dislin "quickplots". However, unlike the "quickplots", this module offers a lot more options for controlling the plot page, axis system and various curve properties while only needing two subroutine calls to set the plot properties&mdash;rather than coding the whole plot with plain Dislin. It also makes adding multiple x&ndash;y data sets (curves) to a single plot a straightforward task. Importantly, the purpose of this module is *not* to repackage the whole suite of options Dislin provides&mdash;just a selection of options and settings that are often used in relatively simple 2D plots. It may also serve as a template for your own, customized interface to the Dislin library and its use for your needs.

## Examples
Two examples for the use of the `Mod_Dislin_plots` module are included in the main program `Prog_Dislin_Examples`. See also the specific comments in that file.
For convenience, this repository includes a MS Visual Studio project and solution (.sln) file for use with Intel's Fortran compilers (ifort or ifx via Intel oneAPI) on a Windows operating system ([Intel oneAPI Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler.html), see also [this how-to install oneAPI for Fortran use](https://community.intel.com/t5/Intel-Fortran-Compiler/The-Easy-and-Fast-Way-to-Install-JUST-Fortran-with-Intel-oneAPI/td-p/1360571), and Visual Studio need to be installed on your system).

## How to link your program to the Dislin library
#### ... using MS Visual Studio
If you use the provided MS Visual Studio (VS) solution on Windows, the Dislin distribution expected to be installed is the one for Windows 64-bit, for compiler: "Intel compilers icl, ifort 64-bit" [found here](https://www.dislin.de/win64.html). It also expects that Dislin is installed to its default path (c:\dislin; otherwise, you will need to edit the path to your Dislin installation in Visual Studio. Here is how that would be done as well as general information about how to link from VS to the installed dislin library: navigate in VS to menu Project > Properties > Fortran, then 
1. under General > Additional Include Directories, set `c:\dislin\ifc\real64`. Adjust the c:\dislin path part to point to your installation directory. 
2. check that under Fortran > Libraries > Runtime Library: `Debug Multithreaded (\libs:static /threads /dbglibs)` or simply `Multithreaded` is set (depending on Debug vs Release mode); the point is to have linking with static libraries rather than with DLLs selected. 
3. under Project > Properties > Linker > Input > Additional Dependencies, set the following: `c:\dislin\disifl_d.lib c:\dislin\disifd_d.lib user32.lib gdi32.lib`. Again, if necessary, adjust in all cases the c:\dislin path parts on that line.

#### ... via command line
A few options for compiling and linking from a command prompt are provided in file [Command_line_compilation.txt](./source_code/Command_line_compilation.txt) from the source_code directory. For example, using gfortran from a (Ubuntu) Linux terminal, one can compile and link the provided example program using the following command: 
`gfortran -o Prog_xy.out -O3  Mod_NumPrec.f90 Mod_Dislin_plots.f90 Prog_Dislin_Examples.f90 -ldislin_d -I/usr/local/dislin/gf/real64`. Then execute the program via `./Prog_xy.out`. The gfortran example assumes that a 64-bit version of Dislin has been installed on the Linux system; [Dislin for Linux distributions](https://www.dislin.de/i586_64.html); read and follow the instructions provided [here](https://www.dislin.de/downloads/linux/i586_64/README.I586_64).

## Structure & options
The module `Mod_Dislin_plots` contains two subroutines:

- subroutine `add_plot_xydata` allows adding and specifying the x&ndash;y data for a curve, with several optional data set characteristics listed below. For adding more than one curve to an existing plot, you simply call this subroutine multiple times (once for each curve).
- subroutine `dislin_plot` is used to generate the plot containing one or more curves. 
- The subroutine call of `dislin_plot` allows for setting arguments for the axis labels, the aspect ratio of the plot, the legend position, and the axis ranges. See the interface details within `Mod_Dislin_plots`.

A number of data set (curve) properties can be controlled via optional arguments in the call of `add_plot_xydata`, these include:

 - arrays of x and y values of data set to be added
 - legend entry text for data set
 - pen width in plot pixels (to set curve thickness)
 - color array of the 3 red, green, blue (RGB) values, each in range [0, 255]
 - line style; options: 'solid', 'dotted', 'dashed', 'dashed_medium'
 - plot curves with or without symbols, or symbols only (options: 'symbols', 'curve', 'both')
 - the symbol ID for dislin (15 = open circle, 5 = open diamond, 3 = +, 4 = X, 16 = filled square, 21 = filled circle, etc.)
 
 Other features from the Dislin graphics library could be added based on your needs.
 
## Editing generated vector graphics
Going from pdf-file version of single plots to publication-quality plots and multipanel arrangements often requires a few additional steps. My preferred way of editing made plots (when saved as .pdf) outside of the Fortran program is by using a vector graphics editing software like the free Inkscape (https://inkscape.org) program. For example, this will allow you to: extract the plot in vector graphics format (i.e. separate it from the background page of the original pdf-file), rearrange several plots into a multipanel figure, change fonts, add other text, and many other things. 
To get started: import the pdf file into inkscape > mark the plot page > ungroup > delete unwanted things such as the page background; re-group and/or rearrange the plot into a multipanel figure, etc. For changing fonts, such as from Helvetica to Arial or Symbol to Times New Roman, use Extensions > Text > Replace font.
