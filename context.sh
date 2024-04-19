rm all_files_content.txt
find . -type d \( -path './bin' -o -path './.dart_tool' -o -path './.git' \) -prune -o \( -name '.gitignore' -prune \) -o -type f -print | xargs -I{} sh -c 'echo "File Path: {}" >> all_files_content.txt; echo "Content:" >> all_files_content.txt; cat "{}" >> all_files_content.txt; echo "" >> all_files_content.txt;'
pbcopy < all_files_content.txt
