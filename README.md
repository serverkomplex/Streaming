# DreamNetwork streaming system

We're currently in the process of open-sourcing code used in our media streaming infrastructure.
Not all code is open-sourced yet, but a few parts of it you can find here.

## Explanation

We're making heavy usage of Liquidsoap and Icecast to produce automated, transcoded livestreams
which can be served to our listeners all around the world from multiple servers. To make sure
we can quickly set up new channels and streams, I (Icedream) wrote together shared functions which
set up proper codec and network settings to save some time.