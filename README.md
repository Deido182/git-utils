# git-utils
A set of custom commands implementing shortcuts for very common cases.

Some of the commands here present assume a scenario where ```features``` only come from ```master``` (that is, the default branch) and are merged to both ```releases``` and ```master```. Ideally, no other branch is allowed to be merged to ```master```.
Each ```release``` is the snapshot of the next version of ```master```. When the latter increases, a new ```release``` is created from the last one, with a greater version-code.

After the ```git clone```, it may be worth running ```git init --template=template-dir/``` from the root directory of the repository. Moreover, if your are going to use ```utils/install``` to install the commands present in a given ```ref```, then you should add ```installed-commands``` (at the same level of ```commands```) to the ```PATH```. Have a look to the ```README``` file of the ```commands``` directory for a few more details.

Given any ```ref``` (typically a branch head), ```utils/install``` basically copies all the commands from the homonym directory to ```installed-commands``` (removing the old ones).
