SCRIPTS_ROOT="./scripts"
if ! $SCRIPTS_ROOT/uncrustify_all.sh; then
 echo "Some sources were modified by Uncrustify" 1>&2
 echo "Commiting updated source files" 2>&1
 git commit -am 'Uncrustified';
fi