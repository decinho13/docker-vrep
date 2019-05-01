#!/bin/bash
set -ex


exec supervisord -c /opt/app-root/bin/supervisord.conf
