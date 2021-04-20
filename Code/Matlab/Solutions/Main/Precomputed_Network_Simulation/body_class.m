classdef body_class

    % This class contains properties and methods related to bodies.
    
    % Define the body properties.
    properties
        mass
        length
        width
        Icm
        pcm
        vcm
        wcm
        mesh
        limbs
    end
    
    % Define the body methods.
    methods
        
        % Define the class constructor.
        function self = body_class( mass, length, width, Icm, pcm, vcm, wcm, mesh, limbs )
        
            % Set the class properties.
            if nargin < 9, self.limbs = []; else, self.limbs = limbs; end
            if nargin < 8, self.mesh = []; else, self.mesh = mesh; end
            if nargin < 7, self.wcm = []; else, self.wcm = wcm; end
            if nargin < 6, self.vcm = []; else, self.vcm = vcm; end
            if nargin < 5, self.pcm = []; else, self.pcm = pcm; end
            if nargin < 4, self.Icm = []; else, self.Icm = Icm; end
            if nargin < 3, self.width = []; else, self.width = width; end
            if nargin < 2, self.length = []; else, self.length = length; end
            if nargin < 1, self.mass = []; else, self.mass = mass; end
        
        end

        
        
    end
end

