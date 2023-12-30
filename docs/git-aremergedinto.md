```git aremergedinto [-n <feature1-name>] ... [-n <featureX-name>] [-u <repo1-url>] ... [-u <repoY-url>] <dest>``` is a <i>porcelain</i> command that assess, for each repository, whether the provided features (in the form ```feature/<feature-name>```) have been merged into ```<dest>``` or not. 
It prints up to ```X``` x ```Y``` rows (one for each pair).
