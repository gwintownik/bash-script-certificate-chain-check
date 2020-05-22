#!/bin/bash

function parsercert {
	        CERT=`cat tmp.cert | sed -n $1,$2p`
	        SUBJECT=`echo -e "$CERT" | grep 'subject=CN = ' | awk -F 'CN =' '{print $2'}`
	        ISSUER=`echo -e "$CERT" | grep issuer | awk -F 'O =' '{print $2}'`
	        NOTAFTER=`echo -e "$CERT" | grep notAfter | awk -F '=' '{print $2}'`
	        MD5=`echo -e "$CERT" | grep MD5 | awk -F '=' '{print $2}'`
	        echo "$i ; $SUBJECT ; $ISSUER  ; $MD5 ; $NOTAFTER "
		}

function openssl_connect {
		echo "" | openssl s_client -showcerts -connect $1:443 2>&1 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p;/-END CERTIFICATE-/a\\x0' | sed -e '$ d' | xargs -0rl -I% sh -c "echo '%' |  openssl x509 -subject -issuer -dates -fingerprint -MD5 -noout"  > tmp.cert
		parsercert 1 5
		parsercert 6 10
		parsercert 11 15
		parsercert 16 20 
		rm tmp.cert
		}

function usage {
	echo "usage: [-f file ] | [-h host] | [--help]"
	}



while [ "$1" != "" ]; do
    case $1 in
        -f )	filename=$2
		if [ "$filename" != "" ] 
		then 
			for i in `cat $filename` 
				do 
				openssl_connect $i
			done
		else 
			echo "ERROR Provide filename"
			exit 1 
		fi
		;;
        -h )	hostname=$2
	    	if [ "$hostname" != "" ]
			then 
				openssl_connect $hostname
			else 
				echo "ERROR Provide hostname or IP"
                                exit 1
                        fi

                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done
