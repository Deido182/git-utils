# git-utils
A set of custom commands implementing shortcuts for very common cases.<br>
The ```docs``` directory contains the description of each command.

### Installation
The suggested procedure consists in:
- running ```utils/install``` to install the commands (this utility considers the head of the <b>local</b> ```master``` branch by default, but you can run ```utils/install [<ref>]``` to install the version of the commands present in a given reference)
- adding ```installed-commands``` (generated at the same level of ```commands```) to the ```PATH```

Have a look at the ```README``` file of the ```commands``` directory for a few more details.

Otherwise, you could directly copy the scripts present in ```commands``` into either ```/usr/bin``` or any other directory already part of ```PATH```.

### Development
As for development, after the ```git clone``` would be worth running ```git init --template=template-dir/``` from the root directory of the repository.<br>
Anyway, for each command of the form ```git-<name>``` added to the ```commands``` directory, a description file ```git-<name>.md``` and a unit-tests file ```git-<name>.bats``` must be added to ```docs``` and ```tests``` directories, respectively.<br>
The branch ```factory/commands-features``` should be used as ```scaffolding``` for new commands. Therefore, new ```features``` should be detached from it.<br>
```utils/run-tests``` executes all ```.bats``` files stored in ```tests```.
