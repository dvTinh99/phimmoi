# 
GREEN='\033[0;32m' #green
NC='\033[0m' # No Color
RED='\033[0;31m' #red

URL_NEED_KEY="https://netphim.site/need-key"

checkNeedKey="$(curl -s -w "\n%{http_code}" $URL_NEED_KEY)";
needKey="$(echo "$checkNeedKey" | sed '$d' | jq .data | sed -e 's/^"//' -e 's/"$//')";
urlRepo="$(echo "$checkNeedKey" | sed '$d' | jq .message | sed -e 's/^"//' -e 's/"$//')";

if(($needKey == 0)) 
then 
    $urlRepo example
else
    ##veryfi code
    echo -e "Bạn đã có key chưa, liên hệ (${GREEN}https://t.me/poketh3${NC}) để lấy key nhé và nhập vào bên dưới ! \n"
    echo -n "Hãy nhập key đi nào : "
    read key_code

    echo "The value is : $key_code" 
    URL="https://netphim.site/verify-code/$key_code" 
    response="$(curl -s -w "\n%{http_code}" $URL)";
    data="$(echo "$response" | sed '$d' | jq .data | sed -e 's/^"//' -e 's/"$//')";
    message="$(echo "$response" | sed '$d' | jq .message | sed -e 's/^"//' -e 's/"$//')";
    http_status_code="$(echo "$response" | tail -n 1)";
    
    if(( $http_status_code != 200 )) 
    then 
        echo -e "${RED}$message${NC}"
        exit 500
    fi

    echo $message
    $data example
fi