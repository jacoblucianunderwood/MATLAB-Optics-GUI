%Goal: create a generalized Optics program.

%Step 1: Set up constants

n_surroundings = 1; %for now, we are using air as the surroundings
n_lens = 1.5;       %for now, we are using "lens" as the lens.
radius = 30;        %input("Enter radius in meters: ");
                    %Using 10 as radius for testing purposes
distance = 10;     %input("Enter the distance of the object from the lens in meters: ");
                    %Using 10 as radius for testing purposes
height = 30;        %input("Enter the height of the object in meters: ");
                    %Using 10 as the height for testing purposes.
rays = 11;           %input("Enter the number of rays you wish to see. We recommend 11 at minumum: ");
                    %Using 5 for now.

height_array = linspace(-height,height,rays); %The starting points of the light rays entering the lens.

choice = input('1 for thin lens, 2 for planoconvex lens: ');

switch choice
    case 1 %Thin lens case
        %Given the properties of the thin lens approximation, we know the
        %following:
        focal_point = [radius/2, 0]; %Focal prime is just negative of the focal length, so we can reuse this variable

        %For creating the thin lens, we can just use a straight line. For
        %visualization, we want this line to be longer than height_array.
        %We also intialize this as the "origin".
        lens = [zeros(size(height_array))' height_array'];      
        %Column 1: Origin axis
        %Column 2: Y-points for where the lens is struck
                                                               
        lens(1,2) = lens(1,2)- 2;
        lens(end,2) = lens(end,2)+ 2;

        %Now we set up the entering rays at the "plane" face.
        x_range = linspace(-distance,0,2);
        init_rays = height_array'.*ones(size(x_range));

        %Creating the exiting rays
        %For thin lens, we must cross the focal point. Rather than doing
        %complex stuff, we can just construct point-slope equations.
        start_point = init_rays(:,end);
        x_step = linspace(0,2*focal_point(1),10);
        m = (focal_point(2)-start_point)/(focal_point(1));
        exit_rays = m .* x_step + height_array';
       
    case 2 %Plano-Convex Case
        %Designing the lens first
        %Placing the "plane" at origin
        lens = [zeros(size(height_array))' height_array'];
        %Column 1: Origin axis
        %Column 2: Y-points for where the lens is struck
        lens(:,3) = sqrt(radius^2 - lens(:,2).^2);
        %Column 3: X-points for where the lens is struck on the convex side

        %Now we set up the entering rays at the "plane" face.
        x_range = linspace(-distance,0,2);              %Starting to end points.
        init_rays = height_array.*ones(size(x_range')); %The heights of each ray

        %This is all we need as we already have the y-values from init_rays
        
        %Find slopes of the curve:
        Curvature = -lens(:,3)./sqrt(radius^2-lens(:,3).^2);

        %Find the Angle of Incidences wrt Height Array
        angle_incidence = pi/2-atan(Curvature);                 %Angle here is determined by the slope
        angle_incidence(abs(angle_incidence)>pi) = NaN;         %Any angles higher than pi would result in critical angles. We will plot them some other time.
        %largest_angle = find(max(angle_incidence));             %Finding the max angle as it *should* always be the middle point. Will fix later.
                
        %Developing Snell's Law for Exiting Angles
        angle_exiting = asin(n_lens*sin(angle_incidence)/n_surroundings);

        %Correcting for bending towards focal point
        min_angle = find(angle_exiting<=min(angle_exiting));
        angle_exiting(min_angle:end) = - angle_exiting(min_angle:end);

        %Critical Angle
        critical_angle = asin(n_lens*sin(pi/2)/n_surroundings);

        %Dealing with Critical Angle
        angle_exiting(abs(angle_exiting)>=critical_angle) = NaN; %Ignoring these values for now.
        %Will later deal with total internal reflection

        %Setting up plotting values by creating a point-slope equation:
        x_step = [lens(:,3) ones(size(lens(:,3)))*2.5*radius];
        m =      atan(angle_exiting);
        b =      height_array';
        exit_rays = (m .* (x_step-lens(:,3)) + b);

        hold on
        plot(lens(:,3),lens(:,2),'c',linewidth=3)
        plot([lens(:,1) lens(:,3)]',init_rays,'r')
        %2plot(lens(:,1),lens(:,2),'r');
        %plot(lens(:,3)', init_rays,'r')
        



end
plot(lens(:,1),lens(:,2),"c",linewidth = 3)
hold on
plot(x_range,init_rays,'r')
hold on
%if choice ~= 1
   
    
%end
plot(x_step',exit_rays','g')
hold on