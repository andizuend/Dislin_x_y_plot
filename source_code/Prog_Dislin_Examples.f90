
!****************************************************************************************
!*   :: Purpose ::                                                                      *
!*  A main program showing two examples for how to use Mod_Dislin_plots to generate 2-D *
!*  scatter plots (or curve plots) using the DISLIN graphics library.                   *
!*  This program requires an installed and linked DISLIN library.                       *
!*  See installation instructions at https://www.dislin.de/index.html.                  *
!*                                                                                      *
!*   :: Authors ::                                                                      *
!*   Andi Zuend (andreas.zuend@mcgill.ca)                                               *
!*   Dept. Atmospheric and Oceanic Sciences, McGill University                          *
!*                                                                                      *
!*   -> created:        2021-06-29                                                      *
!*   -> latest changes: 2023-03-15                                                      *
!*                                                                                      *
!****************************************************************************************
program Prog_Dislin_Examples

use Mod_NumPrec, only : wp

implicit none
!local variables:
integer :: i, npoints
real(kind=wp) :: inc
real(wp),dimension(500) :: xdat, ydat1, ydat2
!...................................

!load/modify data (here just to generate an example):
npoints = size(xdat)
inc = 1.0_wp/real(npoints -1, kind=wp)
xdat = [(inc*i, i = 0,npoints -1)]          !use of implied loop for array values
ydat1 = 1.0_wp + xdat*(1.0_wp - xdat)**5    !operation on whole array
ydat2 = 1.0_wp + xdat*(1.0_wp - xdat)**4

!----------------------------------------------------------------------------------------
!!** EXAMPLE 0: use of the quickplots feature already offered by Dislin **
!
!uncomment the following code block to run this example.
!block
!    integer,parameter :: dp = kind(1.0D0)
!    real(dp),dimension(:),allocatable :: xval, yval
!    external :: metafl, qplot
!    !................
!    xval = real(xdat, kind=dp)               !for correct floating point number conversion
!    yval = real(ydat1, kind=dp)              !to double precision kind used here with Dislin;
!    !simple x--y scatter plot:
!    call metafl('xwin')                      !'xwin' or 'pdf'
!    call qplot(xval, yval, npoints)
!    !plot second curve for yv2:
!    yval = real(ydat2, kind=dp)
!    call metafl('xwin')                      !'xwin' or 'pdf'
!    call qplot(xval, yval, npoints)
!end block


!----------------------------------------------------------------------------------------
!** EXAMPLE 1: plot of two curves with a few set attributes **
!
!Generate a nicer x--y curve plot, showing
!   several curves in the same plot (using Dislin but without use
!   of quick plots). 
!   Here we use a set of module procedures from Mod_Dislin_plots 
!   to make such plots with relatively few statements, while 
!   being able to set various curve and plot properties.
!   The following [block ... end block] code section requires an 
!   installed and linked DISLIN library (double precision version). 
block
    use Mod_Dislin_plots, only : add_plot_xydata, dislin_plot
    character(len=75) :: xlabel, ylabel
    integer,dimension(3),parameter ::   rgb_blue = [40, 40, 255], &
                                    &  rgb_green = [0, 178, 0], &
                                    & rgb_violet = [138, 43, 226]
    !....................................

    !add data for the two x--y curves:
    !note that only xv=..., yv=..., and ltext=... need to be present; other attributes are 
    !optional and, if absent, a default value will be used.
    call add_plot_xydata(xv=xdat, yv=ydat1(:), ltext='ydat1 curve data', pen_wid=8.0_wp, &
        & rgb_col=rgb_blue, lstyle='solid', plot_symb='curve', symb_id=15)

    call add_plot_xydata(xv=xdat, yv=ydat2, ltext='ydat2 data, $y2_{\rm dat}$', pen_wid=8.0_wp, &
        & rgb_col=rgb_green, lstyle='dashed_medium', plot_symb='curve')

    !set overall plot properties and generate Dislin plot:
    xlabel = 'mole fraction of component 1, $x_1$'
    ylabel = '$y_{\rm dat}$'
    call dislin_plot(xlabel, ylabel, yaxis_mod=0.6_wp, legend_position=7, metafile='pdf', &
        & out_file_name='dislin_x_y_plot_example1')    
end block
!----------------------------------------------------------------------------------------


!----------------------------------------------------------------------------------------
!** EXAMPLE 2: plot of several curves and use of a color palette from a file.    **
!**            Also showing use of set x- and y-axis limits of plot axis system. **
!
block
    use Mod_Dislin_plots, only : add_plot_xydata, dislin_plot
    character(len=75) :: legend_text, xlabel, ylabel
    character(len=300) :: filename, filepath
    integer,parameter :: ncurves = 10
    integer :: i, istat, nc, ncolors, u1
    integer,dimension(3) :: rgb_set
    logical :: fexists
    real(wp),dimension(2) :: xax_lim, yax_lim
    real(wp),dimension(:,:),allocatable :: col_palette
    real(wp),dimension(20, ncurves) :: xvals, yvals
    !....................................
    
    !generate some scaled random data points for this example:
    do nc = 1,ncurves
        call random_number(xvals(:,nc))
        call random_number(yvals(:,nc))
        xvals(1,nc) = xvals(1,nc) +sqrt(real(nc,kind=wp)) * xvals(1,nc)
        yvals(1,nc) = yvals(1,nc) +nc/real(ncurves,kind=wp)*yvals(1,nc)
        xvals(2:,nc) = xvals(1,nc) +xvals(2:,nc)
        yvals(2:,nc) = yvals(1,nc) +yvals(2:,nc)
    enddo
    
    !load an RGB color table for use with the following plot:
    ncolors = 256
    allocate( col_palette(3,ncolors) )
    !currently included options for color palettes (this can be customized easily):
    !./color_palettes/RGBColTabBlackPurpleRedYellow.dat             !256 colors
    !./color_palettes/RGBColTabViridisPurpleBlueGreenYellow.dat     !256 colors
    !./color_palettes/RGBTwentyDistinctCol.dat                      !ncolors = 22 (20 colors plus 2 for white and black)
    filename = 'RGBColTabViridisPurpleBlueGreenYellow.dat'
    filepath = './color_palettes/'//trim(filename)
    inquire(file=filepath, exist=fexists)
    if (.not. fexists) then
        filepath = './source_code/color_palettes/'//trim(filename)    
    endif    
    open(newunit=u1, file=filepath, iostat=istat, action='read', status='old')
    do i = 1,ncolors
        read(u1,*,iostat=istat) col_palette(1:3,i)
        if (istat /= 0) exit
    enddo
    close(u1)
    if (.NOT. any(col_palette > 1.1_wp)) then
        !scale to 0 to 255 range:
        col_palette = col_palette*255.0_wp
    endif

    !add data for multiple x--y data curves using a loop, each with a different color:
    do nc = 1,ncurves
        rgb_set = int(col_palette(1:3, 1+(nc-1)*ncolors/ncurves))  !pick a color with reasonable spacing over whole palette
        write(legend_text,'("data set, ",I0.2)') nc
        call add_plot_xydata(xv=xvals(:,nc), yv=yvals(:,nc), ltext=legend_text, pen_wid=3.0_wp, &
            & rgb_col=rgb_set, lstyle='solid', plot_symb='symbols', symb_id=21)
    enddo
    !add another curve (here the 1:1 line):
    call add_plot_xydata(xv=[0.0_wp, 10.0_wp], yv=[0.0_wp, 10.0_wp], ltext='$1:1$ line', &
        & pen_wid=6.0_wp, lstyle='dotted', plot_symb='curve')   !will use default color

    !set overall plot properties and generate Dislin plot:
    xlabel = '$x$ value'
    ylabel = '$y$ value'
    !optional set x and/or y-axis limits and use below call to dislin_plot
    xax_lim = [0.0_wp, 5.0_wp]
    yax_lim = [0.0_wp, 5.0_wp]
    call dislin_plot(xlabel, ylabel, yaxis_mod=1.0_wp, xaxis_limits=xax_lim, yaxis_limits=yax_lim, &
        & legend_position=3, metafile='cons, pdf', out_file_name='dislin_x_y_plot_example2')
    
    !note: setting metafile = 'xwin, pdf' or = 'cons, pdf' will produce two versions of the same plot, 
    !      one displayed to the screen and one saved as a pdf-file.
            
end block
!----------------------------------------------------------------------------------------

write(*,*) 'end of the program Dislin examples'
read(*,*)

end program Prog_Dislin_Examples