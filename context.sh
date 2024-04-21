# Remove context.txt if it exists
[ -f context.txt ] && rm context.txt

# Initialize context.txt with a header
echo "Files and Content:" > context.txt

# Append all file paths excluding specified files and directories to context.txt
find . -type d \( -path './bin' -o -path './.dart_tool' -o -path './.git' \) -prune -o -type f ! \( -name '.gitignore' -o -name 'context.txt' -o -name 'pubspec.lock' -o -name 'context.sh' -o -name 'analysis_options.yaml' \) -print | tee -a context.txt | while read -r file; do
    echo "Content for $file:" >> context.txt
    cat "$file" >> context.txt
    echo "" >> context.txt
done

# Copy the contents of context.txt to the clipboard
pbcopy < context.txt
