#!/bin/bash
set -euxo pipefail

anylint --strict
swiftlint --strict
