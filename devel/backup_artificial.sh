#!/bin/bash
if [ -z "$1" ]
then
  echo "$0: you need to provide database name as an argument"
  exit 1
fi
db=$1
cd /tmp || exit 1
function finish {
  cd /tmp
  rm $db.*
}
trap finish EXIT
sudo -u postgres psql $db -tAc "copy (select * from gha_events where id > 281474976710656) TO '/tmp/$db.events.tsv'" || exit 2
sudo -u postgres psql $db -tAc "copy (select * from gha_payloads where event_id > 281474976710656) TO '/tmp/$db.payloads.tsv'" || exit 3
sudo -u postgres psql $db -tAc "copy (select * from gha_issues where event_id > 281474976710656) TO '/tmp/$db.issues.tsv'" || exit 4
sudo -u postgres psql $db -tAc "copy (select * from gha_pull_requests where event_id > 281474976710656) TO '/tmp/$db.prs.tsv'" || exit 5
sudo -u postgres psql $db -tAc "copy (select * from gha_milestones where event_id > 281474976710656) TO '/tmp/$db.milestones.tsv'" || exit 6
sudo -u postgres psql $db -tAc "copy (select * from gha_issues_labels where event_id > 281474976710656) TO '/tmp/$db.labels.tsv'" || exit 7
sudo -u postgres psql $db -tAc "copy (select * from gha_issues_assignees where event_id > 281474976710656) TO '/tmp/$db.issue_assignees.tsv'" || exit 8
sudo -u postgres psql $db -tAc "copy (select * from gha_pull_requests_assignees where event_id > 281474976710656) TO '/tmp/$db.pr_assignees.tsv'" || exit 9
sudo -u postgres psql $db -tAc "copy (select * from gha_pull_requests_requested_reviewers where event_id > 281474976710656) TO '/tmp/$db.pr_reviewers.tsv'" || exit 10
sudo -u postgres psql $db -tAc "copy (select * from gha_issues_events_labels where event_id > 281474976710656) TO '/tmp/$db.issues_events_labels.tsv'" || exit 11
sudo -u postgres psql $db -tAc "copy (select * from gha_texts where event_id > 281474976710656) TO '/tmp/$db.texts.tsv'" || exit 12
rm -f $db.tar* || exit 13
tar cf $db.tar $db.*.tsv || exit 14
xz $db.tar || exit 15
mv $db.tar.xz /var/www/html/ || exit 16
