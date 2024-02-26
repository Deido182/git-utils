Given some references ```ref``` or ranges ```ref1..ref2``` (provided that ```ref1``` is an <b>ancestor</b> of ```ref2```) <b>on the current branch</b>, ```git changemessage -m <new-message>``` replaces their messages with ```<new-message>```.
A possible example could be ```git changemessage -m <new-message> HEAD^^^ HEAD^..HEAD``` to alter the messages of 3 of the last 4 commits, keeping ```HEAD^^``` unchanged.
Otherwise, ```git changemessage -r <basic-regex> -w <new-text>``` replaces all the parts matching the specified <b><i>basic</i></b> regex with the provided ```<new-text>```.
Finally, ```git changemessage -p <prefix>``` inserts the provided prefix.
The whole list of commits with their ```refs``` can be retrieved by ```git log```. Otherwise, you can directly use ```HEAD~<n>``` as well (where ```HEAD~1``` is the penultimate commit).

Notice that the command is not going to work for all commits ```ref``` such that there exists a merge-commit ```ref'```, descendent of ```ref```, that involves merge-conflicts. This is due to the fact that the command relies on ```git rebase```.
Consider using ```git rebase -i``` for those cases.
