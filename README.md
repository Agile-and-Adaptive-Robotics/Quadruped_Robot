# AARL Quadruped Robot - Muscle Mutt

## Summary
This repository contains files relevant to the design, analysis, and testing of AARL's canine-inspired quadruped robot named Muscle Mutt.  Our goal in developing Muscle Mutt is for it to serve as a biologically relevant platform for testing embodied synthetic nervous systems pertaining to legged locomotion.  Toward this end, Muscle Mutt features body proportions similar to that of a Whippet, antagonistic pairs of braided pneumatic actuators (BPAs) that serve as proxies for muscles, and a CPG based neural control scheme.  All aspects of Muscle Mutt's design are under active development, including adjusting passive limb dynamics to be congruent with animal models, updating the electrical subsystem to incorporate a wider array of biologically relevant sensory feedback, and designing neural algorithms to generate stable and robust locomotion.

## References
More details on the design and testing of Muscle Mutt can be found in our associated papers.
```
@article{
C. W. Scharzenberger, “Design of a Canine Inspired Quadruped Robot as a Platform for Synthetic Neural Network Control,” Master’s Thesis, Portland State University, Digital, 2019. Accessed: Jun. 18, 2023. [Online]. Available: https://www.proquest.com/docview/2289587100?pq-origsite=gscholar&fromopenview=true
}
```
[Link to paper](https://pdxscholar.library.pdx.edu/cgi/viewcontent.cgi?article=6210&context=open_access_etds)

## Install Instructions
As a comprehensive robotics project, this repository contains information pertaining to three major areas of product development, including: (1) mechanical design, (2) electrical design, and (3) software.  The mechancial design for this project has been completed in Solidworks, while the electrical design has been completed in Eagle.  High level control software has primarily been developed in Matlab, though more recent efforts have been conducted in Python.  Requiste python modules are provided in requirement files in relevant directories.

## Repository Organization
This repository is organized into six primary directories, including: (1) Animatlab, (2) CAD_Electrical, (3) CAD_Mechanical, (4) Code, (5) Documentation, and (6) Manufacturing.  The names of these directories are largely self explanatory, with Animatlab neuromechanical simulations being stored in the Animatlab folder; Eagle CAD documents in the CAD_Electrical folder; Solidworks CAD documents in the CAD_Mechanical folder; Matlab, Python, and C code in the Code folder; supporting documentation and datasheets in the Documentation folder; and 3D printing documentation in the Manufacturing folder.