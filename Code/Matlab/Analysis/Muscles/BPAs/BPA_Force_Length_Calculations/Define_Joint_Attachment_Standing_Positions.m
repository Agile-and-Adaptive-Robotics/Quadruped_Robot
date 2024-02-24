%% Define the Joint Locations and the Muscle Attachment Point Locations.

%Define the origin position.
p_Origin = [0; 0; 0];

%Define the joint locations in a standing position.
p_Front_Hip_Joint_Stand = [-10; 0.875000; 0];
p_Front_Knee1_Joint_Stand = [-9.466171; -5.226693; 0];
p_Front_Knee2_Joint_Stand = [-5.379439; -11.063151; 0];
p_Front_Ankle_Joint_Stand = [-3.902235; -19.179823; 0];
p_Front_Foot_Joint_Stand = [-5.780005; -23.108099; 0];

p_Back_Hip_Joint_Stand = [10; -0.875000; 0];
p_Back_Knee_Joint_Stand = [10.599196; -7.723839; 0];
p_Back_Ankle_Joint_Stand = [16.919062; -13.026836; 0];
p_Back_Foot_Joint_Stand = [12.308060; -17.147546; 0];

%Store the standing joint locations into an array.
p_Front_Joints_Stand = [p_Front_Hip_Joint_Stand p_Front_Knee1_Joint_Stand p_Front_Knee2_Joint_Stand p_Front_Ankle_Joint_Stand p_Front_Foot_Joint_Stand];
p_Back_Joints_Stand = [p_Back_Hip_Joint_Stand p_Back_Knee_Joint_Stand p_Back_Ankle_Joint_Stand p_Back_Foot_Joint_Stand];
p_Joints_Stand = [p_Front_Joints_Stand p_Back_Joints_Stand];

%Define the muscle attachment points for front extensor muscles.
p_Front_Hip_Ext1_Stand = [-0.875000; 0.875000; 0];
p_Front_Hip_Ext2_Stand = [-10.022551; 2.566973; 0];
p_Front_Knee1_Ext1_Stand = [-11.021469; 2.510948; 0];
p_Front_Knee1_Ext2_Stand = [-10.684809; -5.011814; 0];
p_Front_Ankle_Ext1_Stand = [-4.249997; -12.382236; 0];
p_Front_Ankle_Ext2_Stand = [-2.783626; -18.650707; 0];

%Define the muscle attachment points for back extensor muscles.
p_Back_Hip_Ext1_Stand = [0.875000; 0.875000; 0];
p_Back_Hip_Ext2_Stand = [9.880161; 0.494768; 0];
p_Back_Knee_Ext1_Stand = [9.248169; -2.321029; 0];
p_Back_Knee_Ext2_Stand = [9.366468; -7.831688; 0];
p_Back_Ankle_Ext1_Stand = [12.358579; -8.057905; 0];
p_Back_Ankle_Ext2_Stand = [18.081873; -12.603608; 0];

%Define the muscle attachment points for front flexor muscles.
p_Front_Hip_Flx1_Stand = [-0.312500; 0; 0];
p_Front_Hip_Flx2_Stand = [-9.013938; -0.356244; 0];
p_Front_Knee1_Flx1_Stand = [-9.128330; 0.951261; 0];
p_Front_Knee1_Flx2_Stand = [-8.032442; -5.748753; 0];
p_Front_Ankle_Flx1_Stand = [-6.016479; -12.449623; 0];
p_Front_Ankle_Flx2_Stand = [-5.147164; -20.062023; 0];

%Define the muscle attachment points for back flexor muscles.
p_Back_Hip_Flx1_Stand = [0.312500; 0; 0];
p_Back_Hip_Flx2_Stand = [9.171908; -1.449359; 0];
p_Back_Knee_Flx1_Stand = [10.828092; -0.300641; 0];
p_Back_Knee_Flx2_Stand = [11.879802; -7.656163; 0];
p_Back_Ankle_Flx1_Stand = [11.185823; -9.358309; 0];
p_Back_Ankle_Flx2_Stand = [15.597770; -13.789930; 0];

%Define the muscle attachment points for the pantograph mechanism.
p_Front_Pantograph1_Stand = [-8.703445; -3.905188; 0];
p_Front_Pantograph2_Stand = [-4.742399; -9.676679; 0];

%Store the muscle attachment points for extensor muscles.
p_Attachments_Front_Ext_Stand = [p_Front_Hip_Ext1_Stand p_Front_Hip_Ext2_Stand p_Front_Knee1_Ext1_Stand p_Front_Knee1_Ext2_Stand p_Front_Ankle_Ext1_Stand p_Front_Ankle_Ext2_Stand];
p_Attachments_Back_Ext_Stand = [p_Back_Hip_Ext1_Stand p_Back_Hip_Ext2_Stand p_Back_Knee_Ext1_Stand p_Back_Knee_Ext2_Stand p_Back_Ankle_Ext1_Stand p_Back_Ankle_Ext2_Stand];

%Store the muscle attachment points for flexor muscles.
p_Attachments_Front_Flx_Stand = [p_Front_Hip_Flx1_Stand p_Front_Hip_Flx2_Stand p_Front_Knee1_Flx1_Stand p_Front_Knee1_Flx2_Stand p_Front_Ankle_Flx1_Stand p_Front_Ankle_Flx2_Stand];
p_Attachments_Back_Flx_Stand = [p_Back_Hip_Flx1_Stand p_Back_Hip_Flx2_Stand p_Back_Knee_Flx1_Stand p_Back_Knee_Flx2_Stand p_Back_Ankle_Flx1_Stand p_Back_Ankle_Flx2_Stand];

%Store the muscle attachment points into arrays.
p_Attachments_Ext_Stand = [p_Attachments_Front_Ext_Stand p_Attachments_Back_Ext_Stand];
p_Attachments_Flx_Stand = [p_Attachments_Front_Flx_Stand p_Attachments_Back_Flx_Stand];


