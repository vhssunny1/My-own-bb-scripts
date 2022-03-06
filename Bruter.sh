tar=$1

while read -r linen;
do
#target=$( echo $linen | cut -d "/" -f 3)- need to solved to find main domain from subdomains
target=Target(ex-google.com)
echo $target
b1=$( echo $linen | cut -d "/" -f 3)
echo $b1
sleep 10
#b1=$linen
#done < $line-newdomains.txt

echo $b1 | waybackurls |grep -v "*" | grep -v "@" | grep -v "," | grep -v -e '^$' | tee -a ./$target/wordlist-master.txt
cat ./$target/wordlist-master.txt | sort -u | unfurl paths |  sed "s/\///1" | sort -u | grep -v '.jpg$' | grep -v '.jpeg$'| grep -v '.png$' | grep -v '.ttf' | grep -v '.eot' | grep -v '.svg'| grep -v '.css'| grep -v '.woff2'|  grep -v '.gif$'| grep -v -e '^$' | tee -a ./$target/wordlist.txt
cat ./$target/wordlist.txt | ./sprawl.py -s | tee -a ./$target/payloads.txt
#https://github.com/tehryanx/sprawl 

#cat $b1-wordlist.txt | sort -u | tee -a $b1-payloads.txt
#rm $b1-wordlist.txt
#rm $b1-wordlist-master.txt


python3 github-endpoints.py -d $b1 | grep -a -i $b1 | unfurl paths | sort -u | tee -a ./$target/github.txt
cat ./$target/github.txt |  ./sprawl.py -s |  tee -a ./$target/payloads.txt

cat ./$target/payloads.txt  | sort -u | tee -a ./$target/final-payloads.txt
cat ./$target/final-payloads.txt | anew ./$target/new-final-payloads.txt >> ./$target/bruteforce.txt

#cat ./$b1/$b1-bruteforce.txt
rm ./$target/final-payloads.txt
rm ./$target/wordlist-master.txt
rm ./$target/github.txt
rm ./$target/wordlist.txt
rm ./$target/payloads.txt


url1=$(echo $b1 | httpx)
echo $url1


done < $1
