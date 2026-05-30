#!/bin/bash

rm -Rf ./lib/api/
dart run swagger_parser
dart run build_runner build -d
