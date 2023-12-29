Given the reference ```ref``` of a commit <b>on the current branch</b>, ```git changemessage -m <new-message> <ref>``` replaces its message with ```<new-message>```. 
Otherwise, ```git changemessage -r <basic-regex> -w <new-text> <ref>``` replaces all the parts matching the specified <b><i>basic</i></b> regex with the provided ```<new-text>```, from ```<ref>``` on.
Finally, ```git changemessage -p <prefix> <ref>``` inserts the provided prefix, from ```<ref>``` on.
The whole list of commits with their ```refs``` can be retrieved by ```git log```. Otherwise, you can directly use ```HEAD~<n>``` as well (where ```HEAD~1``` is the penultimate commit).
