1. Every time need to check when run the Pod inststll/update


* MCSwipeTableViewCell => MCSwipeTableViewCell.m   have local hot fix   TODO::make a folk and let pod read from my repo



 
* need clean and refactor the code, split common to muitple framework



!!!right now the share composer and normal conposer are same code but in two seperate files. everytime change each one should also change the other one.



The Html edtor change to use framework then the code can't load the html file and js files
when people touch those make sure in clude those resources in to main app copy bundle



2. We use xUnique (ver 4.1.4) in order to prevent merge conflicts in ProtonMail.xcodeproj file. Each shared scheme has post-build action, and builds will fail on machenes with no xUnique installed. Please read Installation section: https://github.com/truebit/xUnique

