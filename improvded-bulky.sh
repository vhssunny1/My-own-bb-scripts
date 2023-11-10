#collect all file types from waybackurls #improved from https://github.com/Dheerajmadhukar/back-me-up/tree/main # credit to - https://github.com/Dheerajmadhukar/back-me-up/tree/main 
#!/bin/bash

right=$(printf '\xE2\x9C\x94')
red="\e[31m"
green="\e[32m"
end="\e[0m"
target=$1
out="output"

Usage() {
  echo -e "$green
  Usage: ./bulkyy.sh -f targets.txt
  "$end
  exit 1
}

collect() {
  total_targets=$(wc -l "$target" | awk '{print $1}')
  echo "Total targets: $total_targets"

  current_target=1
  cat "$target" | while read -r domain; do
    echo "Processing domain $current_target of $total_targets: $domain"
    echo "Collecting data for $domain"
    echo "echo '$domain' | waybackurls | tee -a waybackurls.txt > /dev/null"
    echo "$domain" | waybackurls | tee -a waybackurls.txt > /dev/null
    echo "Results for $domain:"
    grep -iaE "([^.]+)\.zip$|([^.]+)\.zip\.[0-9]+$|([^.]+)\.zip[0-9]+$|([^.]+)\.zip[a-z][A-Z][0-9]+$|([^.]+)\.zip\.[a-z][A-Z][0-9]+$|([^.]+)\.rar$|([^.]+)\.tar$|([^.]+)\.tar\.gz$|([^.]+)\.tgz$|([^.]+)\.sql$|([^.]+)\.db$|([^.]+)\.sqlite$|([^.]+)\.pgsql\.txt$|([^.]+)\.mysql\.txt$|([^.]+)\.gz$|([^.]+)\.config$|([^.]+)\.log$|([^.]+)\.bak$|([^.]+)\.backup$|([^.]+)\.bkp$|([^.]+)\.crt$|([^.]+)\.dat$|([^.]+)\.eml$|([^.]+)\.java$|([^.]+)\.lst$|([^.]+)\.key$|([^.]+)\.passwd$|([^.]+)\.pl$|([^.]+)\.pwd$|([^.]+)\.mysql-connect$|([^.]+)\.jar$|([^.]+)\.cfg$|([^.]+)\.dir$|([^.]+)\.orig$|([^.]+)\.bz2$|([^.]+)\.old$|([^.]+)\.vbs$|([^.]+)\.img$|([^.]+)\.inf$|([^.]+)\.sh$|([^.]+)\.py$|([^.]+)\.vbproj$|([^.]+)\.mysql-pconnect$|([^.]+)\.war$|([^.]+)\.go$|([^.]+)\.psql$|([^.]+)\.sql\.gz$|([^.]+)\.vb$|([^.]+)\.webinfo$|([^.]+)\.jnlp$|([^.]+)\.cgi$|([^.]+)\.temp$|([^.]+)\.ini$|([^.]+)\.webproj$|([^.]+)\.xsql$|([^.]+)\.raw$|([^.]+)\.inc$|([^.]+)\.lck$|([^.]+)\.nz$|([^.]+)\.rc$|([^.]+)\.html\.gz$|([^.]+)\.gz$|([^.]+)\.env$|([^.]+)\.yml$" waybackurls.txt | sort -u | httpx -silent -follow-redirects -threads 800 -mc 200 >leaks.txt
    cat leaks.txt
    ((current_target++))
  done

  echo "Data collection completed."
  cut -d"?" -f1 < waybackurls.txt > filtered.txt
  mv waybackurls.txt .waybackurls.txt
}

filter() {
  echo "##############################"
  patterns=(
    "\.zip$|\.zip\.[0-9]+$|\.zip[0-9]+$|\.zip[a-z][A-Z][0-9]+$|\.zip\.[a-z][A-Z][0-9]+$"
    "\.rar$|\.tar$|\.tar\.gz$|\.tgz$|\.sql$|\.db$|\.sqlite$|\.pgsql\.txt$|\.mysql\.txt$|\.gz$"
    "\.config$|\.log$|\.bak$|\.backup$|\.bkp$|\.crt$|\.dat$|\.eml$|\.java$|\.lst$|\.key$|\.passwd$"
    "\.pl$|\.pwd$|\.mysql-connect$|\.jar$|\.cfg$|\.dir$|\.orig$|\.bz2$|\.old$|\.vbs$|\.img$|\.inf$"
    "\.sh$|\.py$|\.vbproj$|\.mysql-pconnect$|\.war$|\.go$|\.psql$|\.sql\.gz$|\.vb$|\.webinfo$|\.jnlp$"
    "\.cgi$|\.temp$|\.ini$|\.webproj$|\.xsql$|\.raw$|\.inc$|\.lck$|\.nz$|\.rc$|\.html\.gz$|\.gz$|\.env$|\.yml$"
  )
  grep -iaE "$(IFS=\|; echo "${patterns[*]}")" filtered.txt | sort -u | httpx -silent -follow-redirects -threads 800 -mc 200 >leaks.txt
  rm filtered.txt
}

found() {
  echo "Results for each pattern:"
  mkdir "$out" 2>/dev/null
  patterns=(
    "zip" "zip.NUM" "zip_NUM" "zip_alpha_ALPHA_NUM" "zip.alpha_ALPHA_NUM"
    "rar" "tar" "tar.gz" "tgz" "sql" "db" "sqlite" "pgsql" "mysql"
    "gz" "config" "log" "bak" "backup" "bkp" "crt" "dat" "eml" "java"
    "lst" "key" "passwd" "pl" "pwd" "mysql-connect" "jar" "cfg" "dir"
    "orig" "bz2" "old" "vbs" "img" "inf" "sh" "py" "vbproj" "mysql-pconnect"
    "war" "go" "psql" "sql.gz" "vb" "webinfo" "jnlp" "cgi" "temp" "ini"
    "webproj" "xsql" "raw" "inc" "lck" "nz" "rc" "html.gz" "gz" "env" "yml"
  )

  for pattern in "${patterns[@]}"; do
    o=$(grep -aiE "([^.]+)\.$pattern" leaks.txt | tee "$out/$pattern.txt" | wc -l)
    if [[ $o -gt 0 ]]; then
      echo -e "💀$green[$o]$red $pattern $end Found.💀$end"
    fi
  done

  find "$out/" -type f -empty -delete
}

target=False
while [ -n "$1" ]; do
  case "$1" in
    -f | --file)
      target=$2
      shift
      ;;
    *)
      echo -e $red"[-]"$end "Unknown Option: $1"
      Usage
      ;;
  esac
  shift
done

[[ $target == "False" ]] && {
  echo -e $red"[-]"$end "Argument: -f/--file targets.txt missing."
  Usage
}

# Use an array to store functions to be executed
functions_to_execute=(
  collect
  filter
  found
)

# Execute the functions in the specified order
for function_name in "${functions_to_execute[@]}"; do
  "$function_name" | pv -l -r -b -F "%t %e $function_name Progress: %p"
done
