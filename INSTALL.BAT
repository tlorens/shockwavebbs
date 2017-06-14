@ECHO OFF
md menus
md menudata
md data
md docs
pkunzip data.zip data -o
pkunzip menudata.zip menudata -o
pkunzip ansimenu.zip menus -o
pkunzip shckdoc.zip docs -o
del shkpro10.zip
config
