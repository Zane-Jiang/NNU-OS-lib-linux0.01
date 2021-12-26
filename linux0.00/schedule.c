int current = 0;
int key = 0 ;

int timer_interrupt(){
    if(key == 0){
        if(current == 0){
            current = 1;
            ljmp 1;
        }else{
            if (current == 1)
            {
                current = 2;
                ljmp 2;
            }else{
                if (current == 2)
                {
                    current = 3;
                    ljmp 3;
                }else{
                    // deflut current = 3
                    current =0;
                    ljmp 0;
                }
            }
        }
    }else{
        if(key == 'a'){
            if(current =! 0)
            {current = 0; 
            key = 0;}
        }else if(key = 'b'){
            if(current != 1)
            current = 1;
        }else if(key = 'c'){
            if(current != 2)
            current = 2;
        }else if(key = 'd'){
            if(current != 3)
            current = 3;
        }
    }
}