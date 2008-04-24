WHY-SO-BIG

The library is 1.5MB in size because smartlinking was
not enabled. FPC smartlinking did not work properly 
because initialization and finalization were not
triggered in the library if smartlinking was on.
Further testing needs to be done before smartlinking
is enabled on the PWU library.