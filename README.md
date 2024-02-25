# git-utils
<i>A set of custom commands implementing shortcuts for very common cases</i>.<br><br>
The ```docs``` directory contains the description of each command.

### Installation
The suggested procedure consists in:
- running ```utils/install``` to install the commands (this utility considers the head of the <b>local</b> ```master``` branch by default, but you can run ```utils/install [<ref>]``` to install the version of the commands present in a given reference). Provided that a suitable version of ```docker``` is installed, the containerized version of the commands is available through the ```-c``` option.
- adding ```installed-commands``` (generated and added to the root directory of the repository) to the ```PATH```

Otherwise, you can directly copy the content of either ```containerized-commands/container-context/commands``` (where the real commands reside) or ```containerized-commands``` (for the containerized ones) into either ```/usr/bin``` or any other directory already part of ```PATH```.

### Development
The branch ```factory/commands-features``` should be used as ```scaffolding``` for new commands. Therefore, new ```features``` should be detached from it.<br><br>
For each command of the form ```git-<name>``` added to ```containerized-commands/container-context/commands```, a description file ```git-<name>.md```, a unit-tests file ```git-<name>.bats``` and the containerized-wrapper ```git-<name>``` must be added to the ```docs```, ```tests``` and ```containerized-commands``` directories, respectively.<br><br>
```utils/run-tests [-c]``` executes all ```.bats``` files stored in ```tests```.
