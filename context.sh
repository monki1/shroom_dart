# Remove codebase.md if it exists
[ -f codebase.md ] && rm codebase.md

# Initialize codebase.md with a header
echo "Files and Content:" > codebase.md

# Append all file paths excluding specified files and directories to codebase.md
find . -type d \( -path './bin' -o -path './.dart_tool' -o -path './.git'  -o -path './packages' \) -prune -o -type f ! \( -name '.gitignore' -o -name 'codebase.md' -o -name 'pubspec.lock' -o -name 'context.sh' -o -name 'analysis_options.yaml' \) -print | tee -a codebase.md | while read -r file; do
    echo "Content for $file:" >> codebase.md
    # Extract the file extension to use as the markdown code block label
    extension="${file##*.}"
    echo "\`\`\`$extension" >> codebase.md
    cat "$file" >> codebase.md
    echo "\`\`\`" >> codebase.md
    echo "" >> codebase.md
done

# Copy the contents of codebase.md to the clipboard
pbcopy < codebase.md
