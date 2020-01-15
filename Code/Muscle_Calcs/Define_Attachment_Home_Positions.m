%% Define the Home Muscle Attachment Point Locations.          ORIGINAL MODEL VALUES.
% 
% %Define the muscle attachment points for front extensor muscles.
% p_Front_Hip_Ext1_Home = [-0.875000; 0.875000; 0];
% p_Front_Hip_Ext2_Home = [-9.875000; 2.562500; 0 ];
% p_Front_Knee_Ext1_Home = [-10.875000; 2.593750; 0];
% p_Front_Knee_Ext2_Home = [-10.875000; -4.375000; 0];
% p_Front_Ankle_Ext1_Home = [-9.125000; -13.875000; 0];
% p_Front_Ankle_Ext2_Home = [-9.125000; -19.750000; 0];
% 
% %Define the muscle attachment points for back extensor muscles.
% p_Back_Hip_Ext1_Home = [0.875000; 0.875000; 0];
% p_Back_Hip_Ext2_Home = [10.000000; 0.5; 0];
% p_Back_Knee_Ext1_Home = [9.125000; -2.250000; 0];
% p_Back_Knee_Ext2_Home = [9.125000; -6.875000; 0];
% p_Back_Ankle_Ext1_Home = [10.875000; -9.312500; 0];
% p_Back_Ankle_Ext2_Home = [10.875000; -15.125000; 0];
% 
% %Define the muscle attachment points for front flexor muscles.
% p_Front_Hip_Flx1_Home = [-0.312500; 0; 0];
% p_Front_Hip_Flx2_Home = [-9.583217; -0.437500; 0];
% p_Front_Knee_Flx1_Home = [-9.125000; 0.875000; 0];
% p_Front_Knee_Flx2_Home = [-9.125000; -6.500000; 0];
% p_Front_Ankle_Flx1_Home = [-10.875000; -13.625000; 0];
% p_Front_Ankle_Flx2_Home = [-10.875000; -21.875000; 0];
% 
% %Define the muscle attachment points for back flexor muscles.
% p_Back_Hip_Flx1_Home = [0.312500; 0; 0];
% p_Back_Hip_Flx2_Home = [9.125000; -1.375000; 0];
% p_Back_Knee_Flx1_Home = [10.875000; -0.375000; 0];
% p_Back_Knee_Flx2_Home = [10.875000; -8.687500; 0];
% p_Back_Ankle_Flx1_Home = [9.125000; -9.250000; 0];
% p_Back_Ankle_Flx2_Home = [9.125000; -17.250000; 0];
% 
% %Define the muscle attachment points for the pantograph mechanism.
% p_Front_Pantograph1_Home = [-9.125000; -4.000000; 0];
% p_Front_Pantograph2_Home = [-9.125000; -11.125000; 0];
% 
% %Store the muscle attachment points for extensor muscles.
% p_Attachments_Front_Ext_Home = [p_Front_Hip_Ext1_Home p_Front_Hip_Ext2_Home p_Front_Knee_Ext1_Home p_Front_Knee_Ext2_Home p_Front_Ankle_Ext1_Home p_Front_Ankle_Ext2_Home];
% p_Attachments_Back_Ext_Home = [p_Back_Hip_Ext1_Home p_Back_Hip_Ext2_Home p_Back_Knee_Ext1_Home p_Back_Knee_Ext2_Home p_Back_Ankle_Ext1_Home p_Back_Ankle_Ext2_Home];
% 
% %Store the muscle attachment points for flexor muscles.
% p_Attachments_Front_Flx_Home = [p_Front_Hip_Flx1_Home p_Front_Hip_Flx2_Home p_Front_Knee_Flx1_Home p_Front_Knee_Flx2_Home p_Front_Ankle_Flx1_Home p_Front_Ankle_Flx2_Home];
% p_Attachments_Back_Flx_Home = [p_Back_Hip_Flx1_Home p_Back_Hip_Flx2_Home p_Back_Knee_Flx1_Home p_Back_Knee_Flx2_Home p_Back_Ankle_Flx1_Home p_Back_Ankle_Flx2_Home];
% 
% %Store the muscle attachment points into arrays.
% p_Attachments_Ext_Home = [p_Attachments_Front_Ext_Home p_Attachments_Back_Ext_Home];
% p_Attachments_Flx_Home = [p_Attachments_Front_Flx_Home p_Attachments_Back_Flx_Home];

%% Define the Home Muscle Attachment Point Locations.                       MODIFIED VALUES FOR TESTING.

%Define the muscle attachment points for front extensor muscles.
p_Front_Hip_Ext1_Home = [-0.875000; 0.875000; 0];
% p_Front_Hip_Ext2_Home = [-9.875000; 2.562500; 0 ];                %Front Hip Extensor Required Length = 9.965 [in] (out of bounds).
% p_Front_Hip_Ext2_Home = [-9.875000; 2; 0 ];                         %Front Hip Extensor Required Length = 7.12 [in] (in bounds).              %MOVING ATTACHMENT POINT DOWN 0.5625 [IN].
p_Front_Hip_Ext2_Home = [-9.583217; 2 - 23/32; 0 ];                         %Front Hip Extensor Required Length = 2.303 [in] (in bounds).              %MOVING ATTACHMENT POINT DOWN 0.5625 [IN].
p_Front_Knee_Ext1_Home = [-10.875000; 2.593750; 0];
% p_Front_Knee_Ext2_Home = [-10.875000; -4.375000; 0];              %Front Knee Extensor Required Length = 10.35 [in] (out of bounds).
p_Front_Knee_Ext2_Home = [-10.75000; -5.2500; 0];              %Front Knee Extensor Required Length = 6.181 [in] (in bounds).                  %USING A PULLEY SYSTEM AND PUTTING THE MUSCLE ATTACHMENT DIRECTLY BELOW THE PULLEY AND DIRECTLY LEFT FROM THE KNEE1 HOME JOINT LOCATION.  MOVE TO THE RIGHT 1/8''.
p_Front_Ankle_Ext1_Home = [-9.125000; -13.625000; 0];
% p_Front_Ankle_Ext2_Home = [-9.125000; -19.750000; 0];         %Front Ankle Extensor Required Length = 10.35 [in] (out of bounds).
p_Front_Ankle_Ext2_Home = [-9.375000; -20.6250; 0];             %Front Ankle Extensor Required Length = 6.216 [in] (in bounds).               %USING A PULLEY SYSTEM AND PUTTING THE MUSCLE ATTACHMENT DIRECTLY BELOW THE PULLEY AND DIRECTLY RIGHT FROM THE ANKLE HOME JOINT LOCATION.

%Define the muscle attachment points for back extensor muscles.
p_Back_Hip_Ext1_Home = [0.875000; 0.875000; 0];
% p_Back_Hip_Ext2_Home = [10.000000; 0.5; 0];                     %Back Hip Extensor Required Length = 11.19 [in] (out of bounds).
p_Back_Hip_Ext2_Home = [9.125000; -0.375000; 0];                  %Back Hip Extensor Required Length = 3.639 [in] (in bounds).
p_Back_Knee_Ext1_Home = [9.125000; -2.250000; 0];
% p_Back_Knee_Ext2_Home = [9.125000; -6.875000; 0];                 %Back Knee Extensor Required Length = 10.35 [in] (out of bounds).
p_Back_Knee_Ext2_Home = [9.375000; -7.7500; 0];                 %Back Knee Extensor Required Length = 4.802 [in] (in bounds).           %USING PULLEY.  MUSCLE ATTACHMENT LEFT OF KNEE HOME JOINT LOCATION AND MOVED RIGHT 0.25 [IN].
p_Back_Ankle_Ext1_Home = [10.875000; -9.312500; 0];
% p_Back_Ankle_Ext2_Home = [10.875000; -15.125000; 0];            %Back Ankle Extensor Required Length = 10.35 [in] (out of bounds).
p_Back_Ankle_Ext2_Home = [10.625000; -16.0000; 0];            %Back Ankle Extensor Required Length = 4.748 [in] (in bounds).            %USING PULLEY.  MUSCLE ATTACHMENT RIGHT OF ANKLE HOME JOINT LOCATION AND MOVED LEFT 0.25 [IN].

%Define the muscle attachment points for front flexor muscles.
p_Front_Hip_Flx1_Home = [-0.312500; 0; 0];
% p_Front_Hip_Flx2_Home = [-9.583217; -0.437500; 0];                    %Front Hip Flexor Required Length = 8.585 [in] (in bounds).
p_Front_Hip_Flx2_Home = [-9.583217; 0.0625; 0];                         %Front Hip Flexor Required Length = 6.022 [in] (in bounds).       %MOVING ATTACHMENT POINT UP 0.5 [IN].
% p_Front_Knee_Flx1_Home = [-9.125000; 0.875000; 0];
p_Front_Knee_Flx1_Home = [-9.125000; 1.625; 0];                      %MOVING ATTACHMENT POINT UP 0.75 [IN].
% p_Front_Knee_Flx2_Home = [-9.125000; -6.500000; 0];                     %Front Knee Flexor Required Length = 11.94 [in] (out of bounds).
p_Front_Knee_Flx2_Home = [-10; -5.875; 0];                     %Front Knee Flexor Required Length = 6.211 [in] (in bounds).                %USING A PULLEY AND MOVING ATTACHMENT POINT UP 0.375 [IN] AND DIRECTLY UNDER THE KNEE1 HOME JOINT LOCATION.
p_Front_Ankle_Flx1_Home = [-10.875000; -13.125000; 0];
% p_Front_Ankle_Flx2_Home = [-10.875000; -21.875000; 0];         %Front Ankle Flexor Required Length = 11.95 [in] (out of bounds).
p_Front_Ankle_Flx2_Home = [-10.0000; -21.375; 0];         %Front Ankle Flexor Required Length = 6.207 [in] (in bounds).              %USING A PULLEY AND MOVING ATTACHMENT POINT UP 0.375 [IN] AND DIRECLTY UNDER THE ANKEL HOME JOINT LOCATION.

%Define the muscle attachment points for back flexor muscles.
p_Back_Hip_Flx1_Home = [0.312500; 0; 0];
p_Back_Hip_Flx2_Home = [9.125000; -1.375000; 0];                %Back Hip Flexor Required Length = 5.878 [in] (in bounds).
p_Back_Knee_Flx1_Home = [10.875000; -0.375000; 0];
% p_Back_Knee_Flx2_Home = [10.875000; -8.687500; 0];              %Back Knee Flexor Required Length = 10.63 [in] (out of bounds).
p_Back_Knee_Flx2_Home = [10.0000; -8.375; 0];              %Back Knee Flexor Required Length = 4.723 [in] (in bounds).              %USING PULLEY.  mUSCLE ATTACHMENT BELOW KNEE HOME JOINT LOCATION.  MOVED UP 5/16''.
p_Back_Ankle_Flx1_Home = [9.125000; -9.250000; 0];
% p_Back_Ankle_Flx2_Home = [9.125000; -17.250000; 0];         %Back Ankle Flexor Required Length = 11.95 [in] (out of bounds).
p_Back_Ankle_Flx2_Home = [10.0000; -16.875; 0];         %Back Ankle Flexor Required Length = 6.216 [in] (in bounds).

%Define the muscle attachment points for the pantograph mechanism.
p_Front_Pantograph1_Home = [-9.125000; -4.000000; 0];
p_Front_Pantograph2_Home = [-9.125000; -11.125000; 0];

%Store the muscle attachment points for extensor muscles.
p_Attachments_Front_Ext_Home = [p_Front_Hip_Ext1_Home p_Front_Hip_Ext2_Home p_Front_Knee_Ext1_Home p_Front_Knee_Ext2_Home p_Front_Ankle_Ext1_Home p_Front_Ankle_Ext2_Home];
p_Attachments_Back_Ext_Home = [p_Back_Hip_Ext1_Home p_Back_Hip_Ext2_Home p_Back_Knee_Ext1_Home p_Back_Knee_Ext2_Home p_Back_Ankle_Ext1_Home p_Back_Ankle_Ext2_Home];

%Store the muscle attachment points for flexor muscles.
p_Attachments_Front_Flx_Home = [p_Front_Hip_Flx1_Home p_Front_Hip_Flx2_Home p_Front_Knee_Flx1_Home p_Front_Knee_Flx2_Home p_Front_Ankle_Flx1_Home p_Front_Ankle_Flx2_Home];
p_Attachments_Back_Flx_Home = [p_Back_Hip_Flx1_Home p_Back_Hip_Flx2_Home p_Back_Knee_Flx1_Home p_Back_Knee_Flx2_Home p_Back_Ankle_Flx1_Home p_Back_Ankle_Flx2_Home];

%Store the muscle attachment points into arrays.
p_Attachments_Ext_Home = [p_Attachments_Front_Ext_Home p_Attachments_Back_Ext_Home];
p_Attachments_Flx_Home = [p_Attachments_Front_Flx_Home p_Attachments_Back_Flx_Home];





