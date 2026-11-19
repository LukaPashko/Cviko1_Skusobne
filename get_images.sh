#!/usr/bin/env bash
set -o pipefail

if [[ $# -ne 1 ]]; then
    printf 'Usage: %s URL\n' "$0" >&2
    exit 1
fi

page_url="$1"
base_url=$(printf '%s\n' "${page_url%%[?#]*}" | cut -d '/' -f 1-3)

curl -fsSLg -- "$page_url" |
    tr '\n<' ' \n' |
    sed -nE '
        /^img[[:space:]]/ {
            s#^[^>]*[[:space:]]src[[:space:]]*=[[:space:]]*"([^"]+)".*#\1#p
        }
    ' |
    (
        status=0
        while IFS= read -r src || [[ -n "$src" ]]; do
            case "$src" in
                https://*) image_url="$src" ;;
                //*) continue ;;
                /*) image_url="$base_url$src" ;;
                *) continue ;;
            esac

            curl -fsSLgO --no-clobber --remove-on-error -- "$image_url" || status=1
        done
        exit "$status"
    )


