

if [[ "${2}" ]]; then OUT=${2}; else OUT=${1}.pem; fi

openssl pkcs12 -in ${1} -nokeys -clcerts -out $OUT
openssl pkcs12 -in ${1} -nocerts -nodes >> $OUT

