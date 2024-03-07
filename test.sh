#!/usr/bin/env sh

# Verify that no other processes will interfere with the test

if lsof -i :3000 1> /dev/null ; then
  echo "❌ There is a process listening on port 3000, quit it and try again"
  exit 1
fi

if pgrep next 1> /dev/null ; then
  echo "❌ There are processes matching 'pgrep next', quit these and try again"
  exit 1
fi

if pgrep wrangler 1> /dev/null ; then
  echo "❌ There are processes matching 'pgrep wrangler', quit these and try again"
  exit 1
fi

check_url() {
  url=$1
  expected_status=$2

  actual_status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

  if [ "$expected_status" = "$actual_status" ] ; then
    echo "$actual_status"
  else
    echo "$actual_status ❗️"
  fi
}

# intro

echo
echo "####################################################################################"
echo

echo 1>&2
echo "starting npm run dev…" 1>&2

nohup npm run dev 1>&2 &

sleep 1

# warmup
while [ '000' -eq "$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/")" ] ; do sleep 0.1 ; printf "." 1>&2 ; done

echo
echo "## npm run dev"
printf " * With slash: %s\n" "$(check_url "http://localhost:3000/api/hello/" "308")"
printf " * Without slash:    %s\n" "$(check_url "http://localhost:3000/api/hello" "200")"

pkill next

# wrangler

echo 1>&2
echo "starting wrangler…" 1>&2

nohup npm run preview3000 1>&2 &

sleep 1

# warmup
while [ '000' -eq "$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:3000/")" ] ; do sleep 0.1 ; printf "." 1>&2 ; done

echo
echo
echo "## wrangler"
printf " * With slash: %s\n" "$(check_url "http://localhost:3000/api/hello/" "308")"
printf " * Without slash:    %s\n" "$(check_url "http://localhost:3000/api/hello" "200")"

echo ""
echo ""

pkill -f wrangler
