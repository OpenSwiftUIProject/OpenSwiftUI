#!/bin/zsh

# A `realpath` alternative using the default C implementation.
filepath() {
  [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

OG_ROOT="$(dirname $(dirname $(filepath $0)))"

# Get the language and input file path from the arguments
language=${1:-"swift"}
input_file=${2:-"$(dirname $(filepath $0))/demangle.txt"}

echo "Demangling $input_file using $language mode"

# Read each line of the input file
while IFS= read -r line; do
  # Demangle the line using the appropriate tool based on the language
  if [[ $language == "swift" ]]; then
    xcrun swift-demangle "$line"
  elif [[ $language == "c++" ]]; then
    c++filt "$line"
  else
    echo "Invalid language: $language"
    echo "Usage: demangle.sh <language> <input file>"
    echo "language: swift or c++, [default]: swift"
    echo "input file: [default] demangle.txt"
    exit 1
  fi
done < "$input_file"
