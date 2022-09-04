FILENAME="$1"

# migration issues:
# - pandoc still tries to be fancy outputting superscript, subscript with unicode or ^()
# - textutil uses one newline per paragraph, pandoc two

pandoc "$FILENAME" -f docx+empty_paragraphs -t plain --wrap=none
