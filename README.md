# trajectory-slicing
Contains R scripts and reproducible examples for the "slicing technique" that allows to analyze, plot, and interpret modelled air mass trajectories (for example with HYSPLIT, FLEXTRA, etc.). In a nutshell, this technique reduces trajectories, which can be considered lines or paths in 3-dimensional space, to points on defined crosscuts through the 3-dimensional space. The crosscuts or __"slices"__ through the 3-dimensional space are defined by the user, and depend on the research question. The technique has already been used in the following publication:
* Koenig, A. M., Sonke, J. E., Magand, O., Andrade, M., Moreno, I., Velarde, F., Forno, R., Gutierrez, R., Blacutt, L., Laj, P., Ginot, P., Bieser, J., Zahn, A., Slemr, F., and Dommergue, A.: Evidence for Interhemispheric Mercury Exchange in the Pacific Ocean Upper Troposphere, JGR Atmospheres, 127, https://doi.org/10.1029/2021JD036283, 2022.
#  

The project contains two main folders, **trajectory-slicing-examples** and **trajectory-slicing-Rpackage**:
* **trajectory-slicing-examples**: Contains example scripts and example data:
  * The folder **example_scripts** contains several self-containing R notebooks that show the general idea of the slicing technique, how it can be used, and what sort of analysis can be done (among them overview plots, and airmass clustering). To use the slicing technique, it should suffice to copy the appropiate example and modify it to your needs. 
  * the folder **example_data** contains short HYSPLIT run results, used in the examples.

* **trajectory-slicing-Rpackage**: Contains two main folders as well: **package_code** and **package_compiled**
  * In **package_compiled**, you find different tarballs (or zips, depending on the operating system) of a lightweight custom R package needed for the examples: the package is called **trajectory.slicing**. As I have a windows machine and can't find how to compile for linux or mac myself, this is currently only offered for windows. 
  * In **package_code**, you find the code used to create the trajectory.slicing R package. This is relevant if you want to make changes, or if you want to compile the code yourself (for example because a compiled version for your operating system is not yet found in "package_compiled"). Note: In case you don't suceed in installing the package trajectory.slicing either way, you can also source (i.e. load) its functions into the example notebooks by using the "source()" function. This is also explained in the examples (you will just have to uncomment the indicated lines).
 
#
How to get started:
1) install the trajectory.slicing package, either by installing a compilled version from *.zip, or by compiling it yourself using the content of the folder __trajectory-slicing-Rpackage/package_code__. Install all the dependencies, if needed.
2) If you're using Rstudio:
    * go into ./trajectory-slicing-examples and open the .Rproj file (the R project). Note that it is important to run the code from this particular R project file, because this way all relative paths used in the example should _just work_.
    * from within this project, open the notebook **./trajectory-slicing-examples/example_scripts/example_1_transformation.Rmd**.
    * Install all the used package in the notebook (check the header cell) and run it. Ideally, this should work and visualize the basic idea of the _slicing_ transformation.
3) If you're not using Rstudio
    * If you're not using Rstudio and don't open code from within an rstudio rproject, then the relative paths will likely not work. You'll have to change paths for data import.
    * open the notebook **./trajectory-slicing-examples/example_scripts/example_1_transformation.Rmd** and modify the relative data import paths so that they fit for your particular case (search for "readRDS" in the code, modify the path so that it points at the adequate example data).
    * proceed as in 2). Install all the used package in the notebook (header cell) and run the notebook.
4) Proceed similarly with the remaining example files! Note that some of them make a while (a minute or more) to run, because some data crunching has to be done.

#
Tips for use after the initial setup:
* In the examples, the transformation to "slice space" is re-calculated each time you run the notebook. If you have lots of data and want to do different analysis then this is pretty inefficient. Ideally, you shouldn't have to do the transformation more often than needed, so I'd suggest to calculate it once you have defined your "slices through the 3-dimensional space", and then save the transformed data somewhere. Later, for the "plotting and analysis steps", you then just have to import this.
* To know what particular functions of trajectory.slicing do, it should suffice to just type: ?function_name into the R console and run it. I wrote a quite detailled description file for each function. Note that this only works if you loaded the trajectory.slicing package. This doesn't work if you directly loaded (with source()) the functions as described above. In the later case, you can still check the function code, which is well commented, but the description will be less nicely formatted.
* The code has been written to follow name conventions of HYSPLIT (i.e. regarding the name of latitude, longitude, datetime columns, etc.). If you use it on output from other models (like FLEXTRA), or different versions of HYSPLIT, you might have to rename some column names in your trajectory data. For this, please check the description of the function: **get_slice_crossing_df**, which can be found in: ./trajectory-slicing-Rpackage/package_code/R
* check out my other project: **HYSPLIT-from-Rstudio** for an efficient way of calculating HYSPLIT trajectories from within Rstudio! 
* If you have problems, doubts or suggestions, don't hesite to write me: alkuin.koenig@gmx.de
