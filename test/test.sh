#!/bin/sh

foo() {
  echo "hola" 
  return 123
}


bar() {
  local result
  local output
  echo "xx"
  output="$(foo 2> /dev/null)"
  result=$?
  echo "xx"

  echo "result=${result}"
  echo "output=${output}"
}

bar
