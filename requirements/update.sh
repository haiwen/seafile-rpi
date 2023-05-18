set -Eeo pipefail

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$ROOT_DIR"

cmd="python3 -m venv /env && source /env/bin/activate \
    && python3 -m pip install --upgrade pip setuptools wheel \
    && python3 -m pip install -r /requirements/upstream.txt \
    && python3 -m pip freeze > /requirements/tmp.txt \
    && chown $(id -u):$(id -g) /requirements/tmp.txt"

(set +x; docker run -it --rm \
    -v "$ROOT_DIR":/requirements \
    python:slim /bin/bash -c "$cmd")

mapfile -t ignored < ignored.txt
(IFS="|"; grep -vE "^(${ignored[*]})==.*$" tmp.txt) > requirements.txt
rm tmp.txt