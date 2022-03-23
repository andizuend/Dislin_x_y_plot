program Prog_Dislin_Example1

use Mod_NumPrec, only : wp

implicit none
!local variables:
integer :: i, npoints
real(kind=wp) :: inc
real(wp),dimension(500) :: xdat, ydat1, ydat2
!...................................

!load/modify data:
npoints = size(xdat)
inc = 1.0_wp/real(npoints -1, kind=wp)
xdat = [(inc*i, i = 0,npoints -1)]          !use of implied loop for array values
ydat1 = 1.0_wp + xdat*(1.0_wp - xdat)**5    !operation on whole array
ydat2 = 1.0_wp + xdat*(1.0_wp - xdat)**4
i = 777     !just for a breakpoint here

!!generate a quick, simple plot using the DISLIN graphics library 
!!       (https://www.dislin.de/index.html);
!!       this requires an installed and linked DISLIN library.
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
    real(wp),dimension(2) :: xax_lim, yax_lim
    !....................................

    !add data for the two x--y curves:
    call add_plot_xydata(xv=xdat, yv=ydat1(:), ltext='ydat1 curve data', pen_wid=8.0_wp, &
        & rgb_col=rgb_blue, lstyle='solid', plot_symb='curve', symb_id=15)

    call add_plot_xydata(xv=xdat, yv=ydat2, ltext='ydat2 data, $y2_{\rm dat}$', pen_wid=8.0_wp, &
        & rgb_col=rgb_green, lstyle='dashed_medium', plot_symb='curve')

    !set overall plot properties and generate Dislin plot:
    xlabel = 'mole fraction of component 1, $x_1$'
    ylabel = '$y_{\rm dat}$'
    
    call dislin_plot(xlabel, ylabel, yaxis_mod=0.6_wp, legend_position=7, metafile='pdf', &
        & out_file_name='example1_curves')
    
    !!optional set x and/or y-axis limits and use below call to dislin_plot (comment-out the previous call):
    !!set/limit x-and y-axis ranges for plot:
    !xax_lim = [0.1_wp, 0.5_wp]
    !yax_lim = [1.0_wp, 1.2_wp]
    !call dislin_plot(xlabel, ylabel, yaxis_mod=0.67_wp, xaxis_limits=xax_lim, yaxis_limits=yax_lim, &
    !    & legend_position=7, metafile='pdf', out_file_name='example1_curves2') 
    
    
    !a second test plot:
    call add_plot_xydata(xv=xdat, yv=ydat2, ltext='ydat2 data, $y2_{\rm dat}$', pen_wid=8.0_wp, &
        & rgb_col=rgb_green, lstyle='dashed_medium', plot_symb='curve')
    
    call add_plot_xydata(xv=xdat, yv=ydat2 +ydat2*(1.0_wp - ydat2), ltext='ydat3 data, $y3_{\rm dat}$', &
        & pen_wid=6.0_wp, rgb_col=rgb_violet, lstyle='dotted', plot_symb='curve')

    !set overall plot properties and generate Dislin plot:
    xlabel = '$x_1$'
    ylabel = '$y_{\rm dat}$'
    
    call dislin_plot(xlabel, ylabel, yaxis_mod=0.6_wp, legend_position=3, metafile='pdf', &
        & out_file_name='example2_curves')
            
end block

!write(*,*) 'end of the program'
!read(*,*)
end program Prog_Dislin_Example1