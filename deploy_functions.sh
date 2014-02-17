#!/bin/sh

# Check if shell option errexit is set
# return true, if it is set
function isErrexitShelloptSet {
    if [[ "$SHELLOPTS" =~ "errexit" ]]; then
	echo 1
    else
	echo 0
    fi
}

# Checks if jar can extract toc from given file
# Parameters: FILE jar or war to check
# return: true, if artifact is ok
function testWarIntegrity {
    local file=$1
    local exit_code=1
    local errexit=$(isErrexitShelloptSet)

    (( errexit )) && set +e
    jar tf "$file" >/dev/null 2>&1
    exit_code=$?
    (( errexit )) && set -e

    # If exit_code == 0 artifact is OK
    if (( exit_code == 0 )); then
	echo 1
    else
	echo 0
    fi
}

# Check if given port has listener
# Parameters: PORT
# Return true, if port has listener running, otherwice returns false
function isPortListenerUp {
    local PORT=$1
    local return_value=1
    local errexit=$(isErrexitShelloptSet)

    (( errexit )) && set +e
    if [ $(uname) == "Darwin" ]; then
        lsof -sTCP:LISTEN -i :$PORT >/dev/null
        return_value=$?
    else
        netstat -nl| grep ":$PORT" 1> /dev/null 2>&1
        return_value=$?
    fi
    (( errexit )) && set -e

    # return_value == 1 is grep FAILED => no listener found
    if (( return_value )); then
	echo 0
    else
	echo 1
    fi
}

# Wait for given port to STOP listening or timeout
# Parameters: PORT
#             TIMEOUT_SECONDS
# Return: true, if the port is no more listening (SUCCESS)
#         false otherwise
function waitForListenerToClose {
    local PORT=$1
    local TIMEOUT_SECONDS=$2
    local time_now=$(date +%s)
    local deadline=$(( time_now + TIMEOUT_SECONDS ))
    local port_has_listener=$(isPortListenerUp $PORT)

    while (( $(date +%s) < deadline ))
    do
        port_has_listener=$(isPortListenerUp $PORT)
        if (( port_has_listener )); then
            sleep 1
        else
            break
        fi
    done

    if (( port_has_listener )); then
	echo 0
    else
	echo 1
    fi
}

# Wait for given port to START listening or timeout
# Parameters: PORT
#             TIMEOUT_SECONDS
# Return: true, if the port is listening (SUCCESS)
#         false otherwise
function waitForListenerToStart {
    local PORT=$1
    local TIMEOUT_SECONDS=$2
    local time_now=$(date +%s)
    local deadline=$(( time_now + TIMEOUT_SECONDS ))
    local port_has_listener=$(isPortListenerUp $PORT)

    while (( $(date +%s) < deadline ))
    do
        port_has_listener=$(isPortListenerUp $PORT)
        if (( port_has_listener )); then
            break
        else
            sleep 1
        fi
    done

    if (( port_has_listener )); then
    echo 1
    else
    echo 0
    fi
}

function cancelDeploy {
    echo "Deploy cancelled."
    exit 1
}