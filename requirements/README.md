# Requirements

Divided in three files:

- `upstream.txt`: Dependencies for [Seahub](https://github.com/haiwen/seahub/blob/master/requirements.txt)
and [Seafdav](https://github.com/haiwen/seafdav/blob/master/requirements.txt) merged and tinkered.
- `ignored.txt`: Ignored dependencies because they all ship binaries bound to a specific python version. Will have to be installed on the runtime environment.
- `requirements.txt`: Result of `pip freeze` after installation of all upstream dependencies, less the ignored ones. Can be updated using `update.sh`.
