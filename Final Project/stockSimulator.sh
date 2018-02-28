#shell script for stock simulator
clear

echo
echo
echo -e "\e[7m Welcome to Stock Simulator! \e[27m"
echo
echo

if [ ! -f portfolio.txt ]
then
    echo "For first time set up, would you like to create a portfolio?"
    echo -n "Press 'y' for yes, 'n' for no: "
    read response

    if [ $response == "y" ]
    then
        echo "Entering portfolio setup..."
        clear
        echo
        echo
        echo -e "\e[7m Welcome to portfolio setup \e[27m"
        echo "To setup your portfolio, enter the stock symbol, number of shares, and buy price as prompted:"

        while [ $response == 'y' ]
        do
            echo
            echo -n "Enter stock symbol: "
            read stock
            echo -n "Enter number of shares: "
            read shares
            echo -n "Enter buy price without commas: "
            read bprice

            echo $stock $shares $bprice >> portfolio.txt

            echo
            echo
            echo -n "Would you like to add another? (y/n): "
            read response
        done
        echo
        echo -n "How much money do you want to start with? $"
        read money
        echo $money > cash2
        mv cash2 cash.txt
        echo
    fi

    if [ $response == "n" ]
    then
        echo "10000" > cash2
        mv cash2 cash.txt
        echo "Entering main program...."
        clear
    fi
fi

menu=m

while true
do
    if [ $menu == "m" ]
    then
        clear
        echo
        echo
        echo -e "\e[7m Welcome to Stock Simulator! \e[0m"
        echo
        echo
        echo -e "\e[4mMain Menu:\e[24m"
        echo "  1) View portfolio"
        echo "  2) View account balance"
        echo "  3) Buy stocks"
        echo "  4) Sell stocks"
        echo "  5) View news"
        echo "  6) Exit"
        echo
        echo -n "Insert selection: "
        read input
        menu=n
    fi

    #portfolio output
    if [ $input -eq 1 ]
    then
        clear
        echo -e "\e[4mYour Portfolio\e[24m"
        echo

        totalRet=0
        totMarketVal=0
        i=2 #horizontal
        j=1 #number of columns
        n=0 #vertical

        cat portfolio.txt | \
        while read line
        do
            stock=''
            shares=''
            bPrice=''
            numbers=1

            for word in $line
            do
                if [ $numbers == 1 ]
                then
                    stock=$word
                elif [ $numbers == 2 ]
                then
                    shares=$word
                elif [ $numbers == 3 ]
                then
                    bPrice=$word
                fi
                numbers=$((numbers+1))
            done

            #formatted output here
            wget -qO- https://api.iextrading.com/1.0/stock/$stock/batch?types=quote\&range=1m\&last=10 > data1
            cat data1 | sed s/","/"\n"/g > data2
            mv data2 data1

            if [ $j -eq 5 ]
            then
                i=2
                n=$((n+6))
                j=1
            fi

            price=`cat data1 | grep latestPrice | awk -F: '{print $2}'`

            ret=`./ret.out $price $bPrice $shares`

            if (( $(echo "$ret < 0" | bc -l) ));
            then
                #1=red, 0=black
                tput setab 1;
                tput setaf 0;
            elif (( $(echo "$ret > 0" | bc -l) ));
            then
                #2 = green, 0 = black
                tput setab 2;
                tput setaf 0;
             else
                #3 = yellow, 0 = black
                tput setab 3;
                tput setaf 0;
            fi


            tput cup $((n+2)) $i;
            echo "                    "
            tput cup $((n+2)) $i;
            echo "         $stock"

            name=`cat data1 | grep companyName | sed s/"\""/""/g | awk -F: '{printf"%-14.14s", $2}'`
            tput cup $((n+3)) $i;
            echo "                    "
            tput cup $((n+3)) $i;
            echo $name

            price=`cat data1 | grep latestPrice | awk -F: '{print $2}'`
            tput cup $((n+4)) $i;
            echo "                    "
            tput cup $((n+4)) $i;
            echo "$"$price "($"$bPrice")"

            tput cup $((n+5)) $i;
            echo "                    "
            tput cup $((n+5)) $i;
            echo "Shares: $shares"

            tput cup $((n+6)) $i;
            echo "                    "
            tput cup $((n+6)) $i;
            echo "Return: $"$ret


            i=$((i+22))
            j=$((j+1))

        done
        tput setaf 7;
        tput setab 0;
        echo
        echo
        echo -n "Press 'm' to return to the main menu: "
        read menu
    fi

    #account balance
    if [ $input -eq 2 ]
    then
        clear
        echo -e "\e[4mAccount Balance\e[24m"
        echo
        echo "----------------------------------"
        echo -n "Your account balance is: $"
        cat cash.txt
        echo "----------------------------------"
        echo
        echo
        echo -n "Would you like to make a deposit? (y/n): "
        read deposit
        if [ $deposit == "y" ]
        then
            echo -n "    How much would you like to deposit? $"
            read money
            cash=`cat cash.txt`
            newCash=`./totalRet.out $money $cash`
            echo $newCash > cash.txt
            echo
            echo -n "    Your new balance is: $"
            cat cash.txt
            echo
        else
            echo "Exiting to main menu"
            menu=m
        fi
    fi

    #buy stocks
    if [ $input -eq 3 ]
    then
        clear
        echo -e "\e[4mBuying Stocks\e[24m"
        echo
        more=1

        while [ $more -eq 1 ]
        do
            echo "------------------------------------"
            cat cash.txt | awk '{printf "You have %s available funds.\n", $1}'
            echo "------------------------------------"
            echo
            echo -n "Stock: "
            read stock
            bprice=`wget -qO- https://api.iextrading.com/1.0/stock/$stock/batch?types=quote\&range=1m\&last=10 | sed -r 's/,/\n/g' | grep latestPrice | cut -d: -f2-`
            echo "    Shares are currently going for $"$bprice
            echo -n "    How many would you like to buy?: "
            read shares

            cash=`cat cash.txt`
            finalCash=`./subtract.out $bprice $cash $shares`

            if (( $(echo "$finalCash < 0" | bc -l) ));
            then
                echo
                echo "Not enough money!"
                echo
            else
                echo $finalCash > cash.txt
                echo $stock $shares $bprice >> portfolio.txt
                sort -k1 -d portfolio.txt > temp.txt
                mv temp.txt portfolio.txt
            fi

            echo
            echo -n "Would you like to buy another? (y/n): "
            read input3
            echo
            echo

            if [ $input3 == "n" ]
            then
               more=0
            fi
        done
        echo "Exiting to main menu"
        menu=m
    fi

    #sell stocks
    if [ $input -eq 4 ]
    then
        clear
        echo -e "\e[4mSelling Stocks\e[24m"
        echo
        more=1

        while [ $more -eq 1 ]
        do
            echo "------------------------------------------"
            echo "The stocks you have available to sell are: "
            cat portfolio.txt | awk '{printf "%8s - %s\n", $1, $2}'
            echo "------------------------------------------"
            echo
            echo -n "Stock: "
            read soldStock
            echo -n "Number of shares: "
            read soldShares

            #code to sell shares here
            cat portfolio.txt | \
            while read line
            do
                stock=''
                shares=''

                for word in $line
                do
                    if [ $word == $soldStock ]
                    then
                        originalLine==$line
                        shares=`echo $line | cut -d' ' -f2`
                        bprice=`echo $line | cut -d' ' -f3`
                        finalShares=$(($shares - $soldShares))

                        if [ $finalShares -lt 0 ]
                        then
                            echo
                            echo "You don't own that many shares!"
                            echo
                        else
                            sed -n "/$line/!p" portfolio.txt > tempPortfolio.txt
                            mv tempPortfolio.txt portfolio.txt
                            #echo $soldStock $finalShares $bprice >> portfolio.txt
                            wget -qO- https://api.iextrading.com/1.0/stock/$soldStock/batch?types=quote\&range=1m\&last=10 | sed -r 's/,/\n/g' | grep latestPrice | cut -d: -f2- > latestPrice.txt
                            curr=`cat latestPrice.txt`
                            cash=`cat cash.txt`
                            newcash=`./sell.out $curr $cash $soldShares`
                            echo $newcash > cash.txt
                            sort -k1 -d portfolio.txt > temp.txt
                            mv temp.txt portfolio.txt
                         fi

                         if [ $finalShares != 0 ] && [ $finalShares -gt 0 ]
                         then
                             echo $soldStock $finalShares $bprice >> portfolio.txt
                         fi
                     fi
                 done
            done


            echo
            echo -n "Would you like to sell another? (y/n): "
            read input3
            echo
            echo

            if [ $input3 == "n" ]
            then
               more=0
            fi
        done
        echo "Exiting to main menu"
        menu=m
    fi

    #news
    if [ $input -eq 5 ]
    then
        clear
        echo -e "\e[4mNews\e[24m"
        echo
        echo "Which company would you like to see headlines about?"
        echo -n "(Stock Symbol): "
        read stock

        wget -qO- https://api.iextrading.com/1.0/stock/$stock/batch?types=news\&range=1m\&last=10 > news.txt
        cat news.txt | sed s/"}"/"}\n"/g | sed s/"\",\""/"\n"/g | sed s/"\""/" "/g | grep 'headline\|source' > news2
        mv news2 news.txt

        echo
        echo
        counter=1
        echo "---------------------------------------------------------"
        cat news.txt | \
        while read line
        do
            if [ $counter -eq 1 ]
            then
                echo $line | awk -F: '{print $2 $3}'
                counter=$((counter+1))
            elif [ $counter -eq 2 ]
            then
                echo $line | awk -F: '{printf "    Source: %s", $2}'
                echo
                echo "---------------------------------------------------------"
                sleep 1
                counter=1
            fi
        done

        echo
        echo
        echo -n "Press 'm' to return to the main menu: "
        read menu
    fi

    if [ $input -eq 6 ]
    then
        clear
        exit
    fi
done
