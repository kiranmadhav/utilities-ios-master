## utilities-ios

This repository is for utilities meant to be shared across MHE projects.  For a utility to be shareable it should be generally useful without being dependent on an MHE internal module such as StudyWiseKit, EPubReaderSDK, etc.  Nor should it contain code which is only of interest to a specific module.  

## Documentation

[Latest Generated Documentation](http://mini.mhe.mhc:8080/static/build-artifacts/utilities-ios/documentation/)

## Tests

[Test Results from the latest build](http://mini.mhe.mhc:8080/static/build-artifacts/utilities-ios/tests/report.html) 

## Requirements
* XCode 12.5/iOS 14 SDK/Swift 5.3
* minimum deployment target: iOS 12

## Develper Guidelines

A utility should be a relatively small amount of code, with specific functionality.  The filename should reflect that functionality.  In the case of an extension, the name should be "className+functionality".  Avoid omnibus terms like "utils" in a filename.  

A utility should document its interface.  See Views/UIView+Constraints for an example and standard format.  Note that interfaces must be public.  A class is preferably open unless there is a specific reason for it not to be, since it is more useful that way.  

When adding a utility, make sure there isn't something which either already does or could serve the purpose.  If it is needed, add it in an appropriate existing project folder, or create a new folder for it.  Do not leave it outside any folder. 

Avoiding redundancy also means merging some existing utilities, which collectively originated in separate projects, modifying clients to suit.  It's inefficient to maintain multiple versions of utilities that accomplish the same thing.

We may want to standardize some common functionality across MHE projects using a shared utility, such as logging or custom dialogs. 
