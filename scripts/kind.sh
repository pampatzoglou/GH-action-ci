#!/usr/bin/env bash

BASH=$(which bash)
if [ `readlink /proc/$$/exe` != $BASH ];then
  $BASH "$0" "$@"
  exit $?
fi

set -o errexit
set -o nounset
set -o pipefail

DEFAULT_KIND_VERSION=v0.10.0
DEFAULT_CLUSTER_NAME=chart-testing
KUBECTL_VERSION=v1.20.2

show_help() {
cat << EOF
Usage: $(basename "$0") <options>

    -h, --help                              Display help
    -v, --version                           The kind version to use (default: $DEFAULT_KIND_VERSION)"
    -c, --config                            The path to the kind config file"
    -i, --node-image                        The Docker image for the cluster nodes"
    -n, --cluster-name                      The name of the cluster to create (default: chart-testing)"
    -w, --wait                              The duration to wait for the control plane to become ready (default: 60s)"
    -l, --log-level                         The log level for kind [panic, fatal, error, warning, info, debug, trace] (default: warning)

EOF
}

main() {
    args=()

    if [[ -n "${INPUT_VERSION:-}" ]]; then
        args+=(--version "${INPUT_VERSION}")
    fi

    if [[ -n "${INPUT_CONFIG:-}" ]]; then
        args+=(--config "${INPUT_CONFIG}")
    fi

    if [[ -n "${INPUT_NODE_IMAGE:-}" ]]; then
        args+=(--node-image "${INPUT_NODE_IMAGE}")
    fi

    if [[ -n "${INPUT_CLUSTER_NAME:-}" ]]; then
        args+=(--cluster-name "${INPUT_CLUSTER_NAME}")
    fi

    if [[ -n "${INPUT_WAIT:-}" ]]; then
        args+=(--wait "${INPUT_WAIT}")
    fi

    if [[ -n "${INPUT_LOG_LEVEL:-}" ]]; then
        args+=(--log-level "${INPUT_LOG_LEVEL}")
    fi

    local version="$DEFAULT_KIND_VERSION"
    local config=
    local node_image=
    local cluster_name="$DEFAULT_CLUSTER_NAME"
    local wait=60s
    local log_level=

    parse_command_line "$@"

    if [[ ! -d "$RUNNER_TOOL_CACHE" ]]; then
        echo "Cache directory '$RUNNER_TOOL_CACHE' does not exist" >&2
        exit 1
    fi

    local arch
    arch=$(uname -m)

    echo 'Adding kind directory to PATH...'
    echo "/usr/local/bin/kind" >> "$GITHUB_PATH"

    echo 'Adding kubectl directory to PATH...'
    echo "/usr/local/bin/kubectl" >> "$GITHUB_PATH"

    kind version
    kubectl version --client=true

    create_kind_cluster
}

parse_command_line() {
    while :; do
        case "${1:-}" in
            -h|--help)
                show_help
                exit
                ;;
            -v|--version)
                if [[ -n "${2:-}" ]]; then
                    version="$2"
                    shift
                else
                    echo "ERROR: '-v|--version' cannot be empty." >&2
                    show_help
                    exit 1
                fi
                ;;
            -c|--config)
                if [[ -n "${2:-}" ]]; then
                    config="$2"
                    shift
                else
                    echo "ERROR: '--config' cannot be empty." >&2
                    show_help
                    exit 1
                fi
                ;;
            -i|--node-image)
                if [[ -n "${2:-}" ]]; then
                    node_image="$2"
                    shift
                else
                    echo "ERROR: '-i|--node-image' cannot be empty." >&2
                    show_help
                    exit 1
                fi
                ;;
            -n|--cluster-name)
                if [[ -n "${2:-}" ]]; then
                    cluster_name="$2"
                    shift
                else
                    echo "ERROR: '-n|--cluster-name' cannot be empty." >&2
                    show_help
                    exit 1
                fi
                ;;
            -w|--wait)
                if [[ -n "${2:-}" ]]; then
                    wait="$2"
                    shift
                else
                    echo "ERROR: '--wait' cannot be empty." >&2
                    show_help
                    exit 1
                fi
                ;;
            -l|--log-level)
                if [[ -n "${2:-}" ]]; then
                    log_level="$2"
                    shift
                else
                    echo "ERROR: '--log-level' cannot be empty." >&2
                    show_help
                    exit 1
                fi
                ;;
            *)
                break
                ;;
        esac

        shift
    done
}

create_kind_cluster() {
    echo 'Creating kind cluster...'
    local args=(create cluster "--name=$cluster_name" "--wait=$wait")

    if [[ -n "$node_image" ]]; then
        args+=("--image=$node_image")
    fi

    if [[ -n "$config" ]]; then
        args+=("--config=$config")
    fi

    if [[ -n "$log_level" ]]; then
        args+=("--loglevel=$log_level")
    fi

    /usr/local/bin/kind "${args[@]}"
}

main "$@"